NOTES — Miscellaneous Configuration

Locale & Time
- Previously generated (x32 install): fi_FI.UTF-8, en_US.UTF-8, C.UTF-8
- Planned default LANG: keep fi_FI.UTF-8 or switch to en_US.UTF-8 during i686 reinstall
- Timezone target: UTC (`/etc/localtime` via timezone-data)

Networking (post‑boot)
- Optional: `emerge net-misc/networkmanager && systemctl enable NetworkManager`

Users & Sudo (optional)
```
emerge app-admin/sudo
useradd -m -G wheel,audio,video,plugdev,usb -s /bin/bash gentoo
passwd gentoo
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel && chmod 440 /etc/sudoers.d/10-wheel
```

Swapfile maintenance
- Created: `/swap.4g` (mode 600). In fstab.
- Remove later if desired:
```
swapoff /swap.4g && rm -f /swap.4g
sed -i '/\/swap\.4g/d' /etc/fstab
```

Handy commands
- Check UUIDs: `blkid`
- Confirm profile: `eselect profile list`
- Sync tree: `emerge --sync` (or `emerge-webrsync`)
- Clean root before re-extract: `rm -rf /mnt/gentoo/*` (double-check mounts!)

Known blockers/quirks
- x32 profile issues:
  - Building gnu-efi/GRUB failed (`X32 does not support 'ms_abi' attribute`).
  - Several packages expect pure amd64 or x86 ABIs; maintenance overhead too high.
  - Decision: redo installation with pure i686 stage, dropping x32 entirely.
- EFI bootloaders:
  - rEFIt 0.14 IA32 is now primary (`EFI/BOOT/BOOTIA32.EFI`). rEFInd also present; keep or remove post-install.
- BIOS path:
  - LILO installed to MBR; rerun `lilo -v` after every kernel update.

i686 reinstall checklist
1. Stage3: `https://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686-systemd/stage3-i686-systemd-<date>.tar.xz`
2. Profile: `default/linux/x86/23.0/systemd` (or latest) via `eselect profile`.
3. `make.conf` baseline:
```
COMMON_FLAGS="-O2 -pipe -march=native"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
CHOST="i686-pc-linux-gnu"
MAKEOPTS="-j2"
ACCEPT_KEYWORDS="x86"
GENTOO_MIRRORS="https://mirror.rackspace.com/gentoo/ https://mirror.init7.net/gentoo/"
ACCEPT_LICENSE="linux-fw-redistributable @BINARY-REDISTRIBUTABLE"
```
4. Kernel: prefer `sys-kernel/gentoo-kernel-bin` (i686) or `gentoo-sources` + `genkernel` inside new chroot.
5. Bootloader: verify `/etc/lilo.conf` matches i686 kernel names; run `lilo -v`.
6. Firmware: `emerge sys-kernel/linux-firmware` and `net-wireless/b43-firmware` (required for Wi-Fi).
