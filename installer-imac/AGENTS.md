# Agent Task: Remote Gentoo Install (iMac A1228, 2GB RAM)

This file defines the exact plan and commands for installing Gentoo on an iMac A1228 over SSH from a BionicPup live session running dropbear. Default path uses GPT with both EFI (32-bit) and BIOS GRUB installed for maximum flexibility, a single ext4 root, a 2G swap partition, and an additional 4G temporary swap file at `/swap.4g` that can be removed later.

Scope: root of this repo. These instructions govern this iMac install.

Common Practices: This runbook inherits repo-wide guidance from the root `AGENTS.md` — see "Remote Session Practices", "Destructive Ops Checklist", "Filesystem Identifiers", and "Documentation & Logs". Device-specific steps below may further constrain the flow.

## Host Details
- Model: Apple iMac A1228 (2007-era, 64-bit CPU, often 32-bit EFI; assume Legacy BIOS/CSM boot works as with BionicPup)
- Live env: BionicPup with dropbear SSH
- SSH: `ssh -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.1.120`
- Target disk: `/dev/sda` (confirmed by user)
- Partitioning: GPT with ESP + BIOS boot + swap + root
- Filesystems: ext4 (root), linux-swap (2G), additional 4G swapfile `/swap.4g`
- Architecture: i686 (32-bit)
- Init: OpenRC
- Stage3: i686 OpenRC tarball (exact URL below)

Important: All partitioning/formatting is destructive. Double-check `/dev/sda`.

## High-Level Plan
1) Connect, verify environment
2) Partition `/dev/sda` (GPT) — ESP + BIOS boot + 2G swap + rest ext4
3) Make filesystems, mount ESP + root, and enable swap
4) Download and extract stage3 (i686 + OpenRC)
5) Chroot and bootstrap Portage
6) Select i686 OpenRC profile, locale/time
7) Install distribution kernel and firmware
8) Create fstab (ESP, root, swap + 4G swapfile)
9) Install GRUB for both EFI (i386-efi) and BIOS (i386-pc)
10) Finalize and reboot

---

## Step-by-Step Commands

### 1) Connect and prep shell
```
ssh -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa root@192.168.1.120
set -euo pipefail
umask 022
date
ip a
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
```

Optional if tmux exists in the live env:
```
command -v tmux && tmux new -s gentoo || true
```

### 2) Partition disk (DESTRUCTIVE, GPT for EFI + BIOS)
Layout:
- `sda1` ESP 200MiB FAT32 (flag `esp`)
- `sda2` BIOS boot 1MiB (flag `bios_grub`)
- `sda3` Linux swap 2GiB
- `sda4` Linux ext4 root (rest of disk)

Commands:
```
DISK=/dev/sda
wipefs -a "$DISK" || true
parted -s "$DISK" mklabel gpt \
  mkpart ESP fat32 1MiB 201MiB \
  set 1 esp on \
  mkpart biosboot 201MiB 202MiB \
  set 2 bios_grub on \
  mkpart swap linux-swap 202MiB 2250MiB \
  mkpart rootfs ext4 2250MiB 100%

ESP=/dev/sda1
BIOSBOOT=/dev/sda2
SWAP=/dev/sda3
ROOT=/dev/sda4
```

Verify:
```
lsblk -o NAME,SIZE,TYPE "$DISK"
```

### 3) Filesystems and mount
```
mkfs.vfat -F32 "$ESP"
mkswap "$SWAP"
mkfs.ext4 -L gentoo_root "$ROOT"
swapon "$SWAP"
mount "$ROOT" /mnt/gentoo
mkdir -p /mnt/gentoo/boot/efi
mount "$ESP" /mnt/gentoo/boot/efi
```

### 4) Fetch and extract stage3 (i686 OpenRC)
Use the exact tarball provided by the user:
```
cd /mnt/gentoo
STAGE_URL="https://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686-openrc/stage3-i686-openrc-<date>.tar.xz"
wget -O stage3.tar.xz "$STAGE_URL"
tar xpvf stage3.tar.xz --xattrs-include='*.*' --numeric-owner
```

If DNS works in live env, copy resolv.conf:
```
mkdir -p /mnt/gentoo/etc/portage
cp -L /etc/resolv.conf /mnt/gentoo/etc/
```

Bind mounts for chroot:
```
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run || true
```

### 5) Chroot and Portage bootstrap
```
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge-webrsync || emerge --sync
```

### 6) Profile, locales, time (i686 + OpenRC)
Select an i686 OpenRC profile (exact index may vary):
```
eselect profile list | nl -ba
# Look for: default/linux/x86/23.0/i686/openrc (or latest version available)
eselect profile set <index>
```

Baseline build settings (keep light for 2GB RAM):
```
cat >> /etc/portage/make.conf <<'EOF'
COMMON_FLAGS="-O2 -pipe -march=i686"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
CHOST="i686-pc-linux-gnu"
MAKEOPTS="-j2"
GENTOO_MIRRORS="https://mirror.rackspace.com/gentoo/ https://mirror.init7.net/gentoo/"
ACCEPT_KEYWORDS="x86"
EOF
```

Timezone and locale:
```
echo "UTC" > /etc/timezone
emerge --config sys-libs/timezone-data
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/env.d/02locale
env-update && source /etc/profile
passwd  # set root password now
```

### 7) Kernel, firmware (binary kernel to save RAM/CPU)
```
echo 'sys-kernel/gentoo-kernel-bin firmware initramfs' >> /etc/portage/package.use/kernel
emerge --ask --verbose sys-kernel/gentoo-kernel-bin
emerge --ask linux-firmware
```

### 8) fstab and swapfile
Get UUIDs:
```
blkid
```

Create `/etc/fstab` (replace with actual UUIDs from blkid):
```
cat > /etc/fstab <<EOF
# <fs>                                  <mountpoint>  <type>  <opts>                <dump> <pass>
UUID=<ROOT-UUID>                         /             ext4    noatime               0      1
UUID=<SWAP-UUID>                         none          swap    sw                    0      0
/swap.4g                                 none          swap    sw,pri=5              0      0
EOF
```

Create the 4G swapfile (on root filesystem):
```
fallocate -l 4G /swap.4g || dd if=/dev/zero of=/swap.4g bs=1M count=4096
chmod 600 /swap.4g
mkswap /swap.4g
swapon /swap.4g
```

Hostname and hosts:
```
echo 'hostname="gentoo"' > /etc/conf.d/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   gentoo
EOF
```

Networking (optional now; can be configured post-boot):
```
emerge --ask net-misc/networkmanager
rc-update add NetworkManager default
```

Optional user and sudo:
```
emerge --ask app-admin/sudo
useradd -m -G wheel,audio,video,plugdev,usb -s /bin/bash gentoo
passwd gentoo
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
```

### 9) Bootloader (EFI + BIOS GRUB)
Install both targets so either path can boot:
```
emerge --ask sys-boot/grub:2

# BIOS/legacy GRUB (uses bios_grub space for core.img)
grub-install --target=i386-pc /dev/sda

# EFI GRUB for 32-bit firmware, installed to ESP
mkdir -p /boot/efi/EFI/Gentoo
grub-install \
  --target=i386-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=Gentoo \
  --removable

grub-mkconfig -o /boot/grub/grub.cfg
```

`--removable` places `EFI/BOOT/BOOTIA32.EFI` so the Mac’s boot picker can detect it even without NVRAM entries.

### 10) Finalize
```
exit
umount -R /mnt/gentoo
swapoff /dev/sda1 || true
reboot
```

---

## Post-Install Notes
- The `/swap.4g` file supplements the 2G swap partition for the 2GB RAM system. You can remove it later by `swapoff /swap.4g && rm -f /swap.4g` and remove the fstab line.
- If you later decide to use GPT, create a small 1MiB BIOS boot partition (type EF02) and use `grub-install --target=i386-pc /dev/sda` similarly.
- If you want EFI boot later, investigate rEFInd or GRUB for 32-bit EFI specifically; BIOS mode is recommended for simplicity on this model.

---

## EFI (GPT + i386-efi GRUB)
If you want an explicit EFI boot option (without relying on the live-CD’s rEFIt), use GPT and install GRUB for 32-bit EFI. This iMac typically has 32-bit EFI firmware, so the correct GRUB target is `i386-efi`.

Key points:
- Partition with GPT, add an ESP (FAT32) and optionally a BIOS boot partition so you can have both EFI and BIOS GRUB available.
- A 32-bit EFI bootloader can coexist with a BIOS GRUB fallback. The Mac boot picker (hold Alt/Option) should show the EFI entry; BIOS/legacy remains available if needed.

### GPT Partitioning Plan (DESTRUCTIVE)
- `sda1` ESP 200MiB FAT32 (flag `esp`)
- `sda2` BIOS boot 1MiB (flag `bios_grub`)
- `sda3` Linux swap 2GiB
- `sda4` Linux ext4 root (rest of disk)

Commands (from the live environment):
```
DISK=/dev/sda
wipefs -a "$DISK" || true
parted -s "$DISK" mklabel gpt \
  mkpart ESP fat32 1MiB 201MiB \
  set 1 esp on \
  mkpart biosboot 201MiB 202MiB \
  set 2 bios_grub on \
  mkpart swap linux-swap 202MiB 2250MiB \
  mkpart rootfs ext4 2250MiB 100%

ESP=/dev/sda1
BIOSBOOT=/dev/sda2
SWAP=/dev/sda3
ROOT=/dev/sda4

mkfs.vfat -F32 "$ESP"
mkswap "$SWAP"
mkfs.ext4 -L gentoo_root "$ROOT"
swapon "$SWAP"
mount "$ROOT" /mnt/gentoo
mkdir -p /mnt/gentoo/boot/efi
mount "$ESP" /mnt/gentoo/boot/efi
```

Proceed with the same stage3 extraction and chroot steps as above.

### EFI GRUB Install (inside chroot)
Install both BIOS and EFI variants so you always have two ways to boot:
```
emerge --ask sys-boot/grub:2

# BIOS/legacy GRUB (uses the tiny bios_grub partition space for core.img)
grub-install --target=i386-pc /dev/sda

# EFI GRUB for 32-bit firmware, installed to the ESP
mkdir -p /boot/efi/EFI/Gentoo
grub-install \
  --target=i386-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=Gentoo \
  --removable

grub-mkconfig -o /boot/grub/grub.cfg
```

`--removable` places `EFI/BOOT/BOOTIA32.EFI`, which many Macs will autodetect in the boot picker even without NVRAM entries.

### fstab additions
Add the ESP mount (replace UUID with your ESP’s):
```
UUID=<ESP-UUID>   /boot/efi   vfat   umask=0077   0  2
```

### Notes on 32-bit EFI and 64-bit kernel
- GRUB `i386-efi` works on 32-bit EFI and can load a 64-bit Linux kernel directly. This avoids the kernel’s EFI stub bitness mismatch issue.
- If EFI boot fails on this particular Mac, legacy/BIOS GRUB remains available as a fallback via rEFIt’s legacy option.

---

## Optional: rEFInd on ESP (friendly EFI menu)
rEFInd is the maintained successor to rEFIt and works well on older Macs with 32-bit EFI. Install alongside GRUB so you can boot either directly via rEFInd or via GRUB.

Inside the chroot after mounting the ESP at `/boot/efi`:
```
emerge --ask sys-boot/refind
```

Option A — script install (preferred if available):
```
refind-install --alldrivers --yes --esp /boot/efi --usedefault /dev/sda1
```

Option B — manual copy for 32-bit EFI:
```
mkdir -p /boot/efi/EFI/BOOT /boot/efi/EFI/refind
cp /usr/share/refind/refind_ia32.efi /boot/efi/EFI/BOOT/BOOTIA32.EFI
cp -r /usr/share/refind/drivers_ia32 /boot/efi/EFI/refind/
cp -r /usr/share/refind/tools_ia32  /boot/efi/EFI/refind/ || true
cp /usr/share/refind/refind.conf-sample /boot/efi/EFI/refind/refind.conf
```

Add a GRUB entry in `/boot/efi/EFI/refind/refind.conf` (path created by the GRUB EFI install above):
```
menuentry "GRUB (Gentoo)" {
    loader \EFI\Gentoo\grubia32.efi
}
```

Notes:
- With GRUB installed using `--removable`, you can also boot via the default path `\EFI\BOOT\BOOTIA32.EFI` directly from the Mac boot picker (hold Alt/Option at power-on).
- rEFInd provides icons and autodetection of kernels if you later choose to boot the kernel directly without GRUB.
