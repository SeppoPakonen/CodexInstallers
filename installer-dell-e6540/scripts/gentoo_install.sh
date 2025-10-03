#!/usr/bin/env bash
set -euo pipefail

# Gentoo install script for Dell E6540, systemd, LUKS-encrypted /home
# Assumes disk already partitioned as:
#   /dev/sda1 ESP 512M, /dev/sda2 swap 8G, /dev/sda3 root ~100G ext4, /dev/sda4 LUKS for /home

DISK=${DISK:-/dev/sda}
ESP=${ESP:-${DISK}1}
SWAP=${SWAP:-${DISK}2}
ROOT=${ROOT:-${DISK}3}
HOME_LUKS=${HOME_LUKS:-${DISK}4}
DO_LUKS_HOME=${DO_LUKS_HOME:-1}  # 1 to configure encrypted /home

ROOT_MNT=/mnt/gentoo

log() { printf "\n[+] %s\n" "$*"; }
die() { echo "[!] $*" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "Run as root."

log "Disk layout check"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$DISK" | sed -n '1,200p'

log "Mounting target root and ESP"
mkdir -p "$ROOT_MNT"
mountpoint -q "$ROOT_MNT" || mount "$ROOT" "$ROOT_MNT"
mkdir -p "$ROOT_MNT/boot"
mountpoint -q "$ROOT_MNT/boot" || mount "$ESP" "$ROOT_MNT/boot"
swapon --show=NAME | grep -q "^$SWAP$" || swapon "$SWAP"

if [ "$DO_LUKS_HOME" = 1 ]; then
  log "Configuring encrypted /home (LUKS) if needed"
  if ! cryptsetup status home >/dev/null 2>&1; then
    if ! cryptsetup isLuks "$HOME_LUKS" >/dev/null 2>&1; then
      echo "About to initialize LUKS on $HOME_LUKS (this will erase data)."
      echo "You will be prompted for a passphrase."
      cryptsetup luksFormat "$HOME_LUKS"
    fi
    cryptsetup open "$HOME_LUKS" home
  fi
  # Create filesystem inside mapping if missing
  if ! blkid /dev/mapper/home >/dev/null 2>&1; then
    mkfs.ext4 -L home_fs /dev/mapper/home
  fi
  mkdir -p "$ROOT_MNT/home"
  mountpoint -q "$ROOT_MNT/home" || mount /dev/mapper/home "$ROOT_MNT/home"
fi

log "Fetching systemd stage3 if not present"
cd "$ROOT_MNT"
if [ ! -x "$ROOT_MNT/bin/bash" ]; then
  LATEST_TXT=https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt
  wget -O latest.txt "$LATEST_TXT"
  STAGE_TARBALL=$(awk '/stage3-amd64-systemd/ {print $1; exit}' latest.txt)
  BASE_URL=https://distfiles.gentoo.org/releases/amd64/autobuilds
  FILE=$(basename "$STAGE_TARBALL")
  wget -O "$FILE" "$BASE_URL/$STAGE_TARBALL"
  wget -O "$FILE.DIGESTS" "$BASE_URL/$STAGE_TARBALL.DIGESTS"
  # Verify checksum for tarball only
  awk -v f="$FILE" '$2==f {print $1, $2}' "$FILE.DIGESTS" > SHA512SUMS
  sha512sum -c SHA512SUMS
  tar xpvf "$FILE" --xattrs-include='*.*' --numeric-owner
fi

log "Preparing chroot mounts and DNS"
mkdir -p "$ROOT_MNT/etc/portage"
cp -L /etc/resolv.conf "$ROOT_MNT/etc/"
mount -t proc /proc "$ROOT_MNT/proc" || true
mount --rbind /sys "$ROOT_MNT/sys"; mount --make-rslave "$ROOT_MNT/sys"
mount --rbind /dev "$ROOT_MNT/dev"; mount --make-rslave "$ROOT_MNT/dev"
mount --rbind /run "$ROOT_MNT/run" || true; mount --make-rslave "$ROOT_MNT/run" || true

log "Entering chroot for bootstrap and configuration (systemd)"
chroot "$ROOT_MNT" /bin/bash -lc '
  set -euo pipefail
  source /etc/profile
  export PS1="(chroot) $PS1"

  mkdir -p /etc/portage/repos.conf
  cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
  emerge-webrsync || emerge --sync

  # Select systemd profile automatically
  if eselect profile list >/dev/null 2>&1; then
    idx=$(eselect profile list | awk "/amd64/ && /systemd/ {gsub(/[\[\]]/,\"\",\$1); print \$1; exit}")
    [ -n "$idx" ] && eselect profile set "$idx" || echo "WARN: systemd profile not found"
  fi

  # Make defaults sane
  grep -q "^MAKEOPTS=" /etc/portage/make.conf || echo "MAKEOPTS=\"-j$(nproc)\"" >> /etc/portage/make.conf
  grep -q "^GENTOO_MIRRORS=" /etc/portage/make.conf || echo "GENTOO_MIRRORS=\"https://mirror.rackspace.com/gentoo/ https://mirror.init7.net/gentoo/\"" >> /etc/portage/make.conf

  # Timezone and locale
  echo UTC > /etc/timezone
  emerge --config sys-libs/timezone-data || true
  sed -i "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
  locale-gen
  echo LANG=en_US.UTF-8 > /etc/env.d/02locale
  env-update && source /etc/profile

  # Hostname and hosts
  echo gentoo > /etc/hostname
  cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   gentoo
EOF

  # Install kernel, firmware, microcode, tools
  echo "sys-kernel/gentoo-kernel-bin firmware initramfs" >> /etc/portage/package.use/kernel || true
  emerge -v --quiet-build=y sys-kernel/gentoo-kernel-bin linux-firmware sys-firmware/intel-microcode

  # Network manager (systemd)
  emerge -v --quiet-build=y net-misc/networkmanager
  systemctl enable NetworkManager.service
  systemctl enable systemd-timesyncd.service

  # Sudo and user (passwords can be set later)
  emerge -v --quiet-build=y app-admin/sudo
  useradd -m -G wheel,audio,video,plugdev,usb -s /bin/bash gentoo || true
  echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel
  chmod 440 /etc/sudoers.d/10-wheel

  # fstab and crypttab
  ROOT_UUID=$(blkid -s UUID -o value /dev/sda3)
  ESP_UUID=$(blkid -s UUID -o value /dev/sda1)
  SWAP_UUID=$(blkid -s UUID -o value /dev/sda2)
  LUKS_UUID=$(blkid -s UUID -o value /dev/sda4 || true)
  cat > /etc/fstab <<EOF
# <fs>                                  <mountpoint>  <type>  <opts>         <dump> <pass>
UUID=${ROOT_UUID}                        /             ext4    noatime        0      1
UUID=${ESP_UUID}                         /boot         vfat    umask=0077     0      2
UUID=${SWAP_UUID}                        none          swap    sw             0      0
LABEL=home_fs                            /home         ext4    noatime        0      2
EOF
  if [ -n "${LUKS_UUID:-}" ]; then
    echo "home  UUID=${LUKS_UUID}  none  luks" > /etc/crypttab
  fi

  # GRUB (UEFI)
  emerge -v --quiet-build=y sys-boot/grub:2
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Gentoo --recheck
  grub-mkconfig -o /boot/grub/grub.cfg

  echo "\n(chroot) Base system installation finished. Remember to set passwords:"
  echo "  passwd   # set root password"
  echo "  passwd gentoo  # set user password (if created)"
'

log "Done. You can now set passwords and reboot when ready."
echo "Examples:"
echo "  ssh root@<host> 'chroot /mnt/gentoo passwd'"
echo "  ssh root@<host> 'chroot /mnt/gentoo passwd gentoo'"
echo "  ssh root@<host> 'umount -R /mnt/gentoo; swapoff ${SWAP}; reboot'"

