# Agent Task: Remote Gentoo Install (Dell Latitude E6540)

This file defines the end-to-end plan and commands for installing Gentoo on a Dell Latitude E6540 over SSH. Follow these steps exactly. Destructive actions are clearly marked and require explicit confirmation.

Scope: root of this repository. These instructions govern the remote install workflow performed by the agent.

Common Practices: This runbook inherits repo-wide guidance from `AGENTS.md` at the repo root — see sections "Remote Session Practices", "Destructive Ops Checklist", "Filesystem Identifiers", and "Documentation & Logs".

## Host Details
- Model: Dell Latitude E6540 (Haswell, UEFI capable)
- Target OS: Gentoo Linux (amd64)
- Remote access: `ssh root@192.168.1.119`
- Assumptions:
  - Laptop is booted into a live environment with working network and SSH root access.
  - Power is stable (on AC) and preferably on wired Ethernet.
  - Install target is the internal drive (confirm exact device before proceeding).

## Safety and Approvals
See root AGENTS.md for tmux/transcript practices, destructive-op confirmation, and UUID usage. This runbook enforces explicit disk confirmation before partitioning.

## Defaults (per user selection)
- Init: systemd
- Disk: `/dev/sda`
- Partitioning: GPT + UEFI
  - sda1: EFI 512M FAT32
  - sda2: Swap 8G (or RAM size if known)
  - sda3: Root ext4
  - sda4: Home LUKS (ext4 inside LUKS)
- Timezone: UTC; Locale: en_US.UTF-8
- Kernel: `sys-kernel/gentoo-kernel-bin` (distribution kernel for speed/reliability)
- Bootloader: GRUB (UEFI)
- Network: NetworkManager (with DHCP)

## High-Level Plan
1) Verify remote session and environment
2) Identify and confirm target disk (/dev/sda)
3) Partition and format (DESTRUCTIVE) with encrypted /home
4) Mount filesystems and fetch stage3 (systemd)
5) Chroot and bootstrap Portage
6) Configure system (systemd profile, timezone, locale, user)
7) Install kernel, firmware, microcode
8) Configure fstab, crypttab, network, services
9) Install bootloader (UEFI GRUB)
10) Final checks, unmount, reboot

---

## Step-by-Step Commands

### 1) Connect, harden shell, start tmux
```
ssh -o StrictHostKeyChecking=accept-new root@192.168.1.119
which tmux || (apk add tmux || emerge --ask app-misc/tmux || true)
tmux new -s gentoo || tmux attach -t gentoo
set -euo pipefail
umask 022
```
Optional logging inside tmux:
```
script -aq /root/gentoo-install.log
```

Check basics:
```
date
ip a
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
lscpu | sed -n '1,10p'
```

### 2) Identify and confirm target disk (DESTRUCTIVE)
- Expected: `/dev/sda` (per user). Do NOT guess if mismatch.
- Confirm with:
```
lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE
blkid
```
- BIOS/UEFI: Ensure UEFI mode is enabled; disable Secure Boot; SATA mode AHCI.

### 3) Partition disk (DESTRUCTIVE)
Target: `DISK=/dev/sda` (confirmed).

Create GPT layout with encrypted /home:
```
parted -s "$DISK" mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart swap linux-swap 513MiB 8705MiB \
  mkpart rootfs ext4 8705MiB 100GiB \
  mkpart homeluks 100GiB 100%
```

Partition mapping:
- `ESP=/dev/sda1`
- `SWAP=/dev/sda2`
- `ROOT=/dev/sda3`
- `HOME_LUKS=/dev/sda4`

Format unencrypted partitions:
```
mkfs.vfat -F32 "$ESP"
mkswap "$SWAP"
mkfs.ext4 -L gentoo_root "$ROOT"
```

Create encrypted /home (LUKS) and filesystem:
```
cryptsetup luksFormat "$HOME_LUKS"
cryptsetup open "$HOME_LUKS" home
mkfs.ext4 -L home_fs /dev/mapper/home
```

### 4) Mount filesystems and fetch stage3 (systemd)
```
mount "$ROOT" /mnt/gentoo
mkdir -p /mnt/gentoo/boot
mount "$ESP" /mnt/gentoo/boot
swapon "$SWAP"
mkdir -p /mnt/gentoo/home
mount /dev/mapper/home /mnt/gentoo/home
```

Fetch latest stage3 (systemd):
```
cd /mnt/gentoo
STAGE_URL=$(wget -qO- https://www.gentoo.org/downloads/mirrors/ | \
  sed -n 's/.*href=\"\(https:[^\"]*gentoo\.[^\"]*\/releases\/amd64\)\".*/\1/p' | head -n1)
wget -O - "$STAGE_URL/autobuilds/latest-stage3-amd64-systemd.txt" | tee latest.txt
STAGE_TARBALL=$(awk '/stage3-amd64-systemd/ {print $1; exit}' latest.txt)
BASE_URL=$(dirname "$STAGE_URL/autobuilds/$STAGE_TARBALL")
wget "$STAGE_URL/autobuilds/$STAGE_TARBALL"
wget "$STAGE_URL/autobuilds/$STAGE_TARBALL.DIGESTS"
```
Verify (optional but recommended):
```
grep -A1 -E 'SHA512 HASH' *.DIGESTS | tail -n1 | awk '{print $1"  "$2}' > SHA512SUMS
sha512sum -c SHA512SUMS
```
Extract:
```
tar xpvf stage3-*.tar.* --xattrs-include='*.*' --numeric-owner
```

### 5) Prepare chroot
```
mkdir -p /mnt/gentoo/etc/portage
cp -L /etc/resolv.conf /mnt/gentoo/etc/
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run || true
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

### 6) Portage bootstrap and profile (systemd)
```
mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge-webrsync || emerge --sync
eselect profile list
# Choose a systemd profile, e.g. default/linux/amd64/23.0/systemd
eselect profile set <index-of-systemd-profile>
```

Set build options (example sane defaults):
```
cat >> /etc/portage/make.conf <<'EOF'
COMMON_FLAGS="-O2 -pipe"
# For Haswell (optional):
# CFLAGS="${COMMON_FLAGS} -march=haswell"
# CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j$(nproc)"
GENTOO_MIRRORS="https://mirror.rackspace.com/gentoo/ https://mirror.init7.net/gentoo/"
EOF
```

Time/locale:
```
echo "UTC" > /etc/timezone
emerge --config sys-libs/timezone-data
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/env.d/02locale
env-update && source /etc/profile
```

Root password (set one now):
```
passwd
```

### 7) Kernel, firmware, microcode
Distribution kernel (fastest path):
```
echo 'sys-kernel/gentoo-kernel-bin firmware initramfs' >> /etc/portage/package.use/kernel
emerge --ask --verbose sys-kernel/gentoo-kernel-bin
```
Firmware and microcode:
```
emerge --ask linux-firmware sys-firmware/intel-microcode
```

### 8) fstab, crypttab, host, network (systemd)
Get UUIDs:
```
blkid
```
Create `/etc/fstab` (replace UUIDs accordingly):
```
cat > /etc/fstab <<EOF
# <fs>                                  <mountpoint>  <type>  <opts>         <dump> <pass>
UUID=<ROOT-UUID>                         /             ext4    noatime        0      1
UUID=<ESP-UUID>                          /boot         vfat    umask=0077     0      2
UUID=<SWAP-UUID>                         none          swap    sw             0      0
EOF
```

Create `/etc/crypttab` for LUKS home (use LUKS UUID from `blkid` of `$HOME_LUKS`):
```
echo 'home  UUID=<LUKS-UUID>  none  luks' > /etc/crypttab
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

Network (NetworkManager on systemd):
```
emerge --ask net-misc/networkmanager
systemctl enable NetworkManager.service
```

User and sudo:
```
emerge --ask app-admin/sudo
useradd -m -G wheel,audio,video,plugdev,usb -s /bin/bash gentoo
passwd gentoo
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
```

### 9) Bootloader (UEFI GRUB)
```
emerge --ask sys-boot/grub:2
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Gentoo --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

### 10) Finalize
```
exit
umount -R /mnt/gentoo
swapoff "$SWAP" || true
reboot
```

---

## Variations
- OpenRC: use `stage3-amd64-openrc`, select an OpenRC profile, and enable services via `rc-update`.
- Full-disk LUKS: place LUKS on root, open as `cryptroot`, ensure initramfs has cryptsetup, and update GRUB cmdline and `/etc/crypttab` and `/etc/fstab`.

## Post-Install Checklist
- Verify networking, audio (ALSA/PulsePipe), graphics (Intel i915; discrete AMD if present), suspend/resume.
- `emerge --ask app-portage/cpuid2cpuflags` then add `CPU_FLAGS_X86` to `/etc/portage/make.conf`.
- Update microcode in early boot if desired (initramfs hooks).
- Enable power management: `tlp` or tuned settings.

## Required Confirmations Before Proceeding
All confirmations received from user:
1) Disk: `/dev/sda`
2) Init: systemd
3) Encryption: encrypted `/home` via LUKS separate partition

Proceed with caution. The agent will verify remotely, then execute.
