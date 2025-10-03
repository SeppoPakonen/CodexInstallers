Kernel Configuration — iMac A1228 (i686 reboot)

Scope: guidance for rebuilding Gentoo’s kernel on the 2007 iMac A1228 when switching to a pure 32-bit (`i686`) userland. Use these notes inside the target chroot (`/mnt/gentoo`).

Hardware snapshot
- CPU: Intel Core 2 Duo (Merom, model 23) — 64-bit capable but we’ll run an i686 kernel
- GPU: AMD/ATI RV630/M76 — Mobility Radeon HD 2600 XT
- Wi-Fi: Broadcom BCM4321 (needs b43 firmware)
- Ethernet: Marvell Yukon2 88E8058 (`sky2` driver)
- Storage: Intel ICH8 (IDE mode now; AHCI available)
- Audio: Intel HDA (`snd_hda_intel`)
- Extras: FireWire 800 (`firewire_ohci`), Apple SMC/backlight, USB UVC webcam

Kernel sources
- `/usr/src/linux` should point to the active 32-bit tree (e.g. `linux-6.12.x-gentoo`).
- Save configs under `/root/kernel-config-imac-YYYYMMDD-HHMM.txt` after each successful build.
- If using `sys-kernel/gentoo-kernel-bin`, most settings below are preconfigured; still verify modules you need.

Key config targets (menuconfig)
- Processor/ABI
  - `CONFIG_X86_32=y`
  - `CONFIG_X86_PAE=y` and `CONFIG_HIGHMEM64G=y` (gives PAE + >4 GiB support; harmless on 2 GB machines)
  - Processor type: `CONFIG_MCORE2=y`
  - `CONFIG_SMP=y`, `CONFIG_X86_LOCAL_APIC=y`, `CONFIG_X86_MCE=y`
  - Disable `CONFIG_X86_X32` / `CONFIG_X86_64`
- Core/systemd requirements
  - `CONFIG_DEVTMPFS=y`, `CONFIG_DEVTMPFS_MOUNT=y`
  - `CONFIG_CGROUPS=y`, `CONFIG_NAMESPACES=y`, `CONFIG_USER_NS=y`
  - `CONFIG_FHANDLE=y`, `CONFIG_FANOTIFY=y`, `CONFIG_INOTIFY_USER=y`
  - `CONFIG_TMPFS_POSIX_ACL=y`, `CONFIG_DEVPTS_MULTIPLE_INSTANCES=y`
  - `CONFIG_BLK_DEV_INITRD=y`
- Firmware/EFI/ACPI
  - `CONFIG_EFI=y`, `CONFIG_EFI_STUB=y`, `CONFIG_EFI_VARS=y`, `CONFIG_EFIVAR_FS=m`
  - `CONFIG_EFI_PARTITION=y`, ACPI button/fan/thermal/processor
  - Include `CONFIG_APPLE_PROPERTIES=y` if available
- Storage/network
  - `CONFIG_ATA_PIIX=m`, `CONFIG_SATA_AHCI=y`
  - `CONFIG_SCSI=y`, `CONFIG_BLK_DEV_SD=y`, `CONFIG_BLK_DEV_SR=m`, `CONFIG_CHR_DEV_SG=m`
  - `CONFIG_EXT4_FS=y`, `CONFIG_VFAT_FS=y`, `CONFIG_MSDOS_FS=y`, `CONFIG_FAT_DEFAULT_UTF8=y`
  - `CONFIG_ISO9660_FS=m`, `CONFIG_UDF_FS=m`, `CONFIG_HFSPLUS_FS=m`
  - Networking core + drivers: `CONFIG_INET=y`, `CONFIG_IPV6=m`, `CONFIG_SKY2=m`
  - Wi-Fi stack: `CONFIG_CFG80211=m`, `CONFIG_MAC80211=m`, `CONFIG_B43=m`, `CONFIG_BCMA=m`, `CONFIG_SSB=m`
- Graphics/Desktop
  - `CONFIG_DRM=y`, `CONFIG_DRM_RADEON=m`, `CONFIG_DRM_TTM=y`, `CONFIG_DRM_KMS_HELPER=y`
  - `CONFIG_FRAMEBUFFER_CONSOLE=y`, optional `CONFIG_FB_EFI=m`
- Audio & peripherals
  - `CONFIG_SND_HDA_INTEL=m`
  - USB host: EHCI/OHCI/UHCI + `CONFIG_USB_STORAGE=m`, `CONFIG_USB_UAS=m`
  - HID: `CONFIG_HID=y`, `CONFIG_HID_GENERIC=y`, `CONFIG_USB_HID=y`, `CONFIG_HID_APPLE=m`, `CONFIG_HID_APPLEIR=m`, `CONFIG_HIDRAW=y`
  - `CONFIG_APPLE_SMC=m`, `CONFIG_APPLE_BL=m`, `CONFIG_SENSORS_CORETEMP=m`, `CONFIG_USB_VIDEO_CLASS=m`
  - FireWire: `CONFIG_FIREWIRE_OHCI=m`

Build workflow (manual kernel)
1. Inside chroot: `chroot /mnt/gentoo /bin/bash`, `env-update && source /etc/profile`.
2. Ensure `/boot` (and `/boot/efi` when needed) is mounted.
3. Select kernel: `eselect kernel list` / `eselect kernel set <target>`.
4. `cd /usr/src/linux`.
5. Configure: `make menuconfig` (or reuse saved config).
6. Compile & install:
   - `make -j2`
   - `make modules_install`
   - Initramfs via `dracut --kver "$(make kernelrelease)"` or `genkernel initramfs`
   - `cp arch/x86/boot/bzImage /boot/vmlinuz-"$(make kernelrelease)"`
   - `cp .config /boot/config-"$(make kernelrelease)"`
7. Rebuild bootloader map: `lilo -v` (rerun every time kernel/initramfs names change).

Using gentoo-kernel-bin
- `emerge --ask sys-kernel/gentoo-kernel-bin` automatically installs kernel + initramfs into `/boot` with predictable names.
- Check `/etc/kernel/postinst.d/zz-runlilo` (installed with LILO) to confirm automatic map rebuild; if it triggers, ensure `/etc/lilo.conf` paths match the names shipped by gentoo-kernel-bin (usually `vmlinuz-*` / `initramfs-*`).
- After emerge completes, run `lilo -v` manually once to confirm.

Firmware & extras
- `emerge --ask sys-kernel/linux-firmware`
- `emerge --ask net-wireless/b43-firmware`
- Radeon blobs come with linux-firmware; without them KMS will fall back to unaccelerated modes.

Notes & troubleshooting
- BIOS is currently in IDE mode; once the OS is stable consider switching the firmware to AHCI (kernel already supports it).
- PAE (`CONFIG_X86_PAE`) slightly increases overhead but allows using >3 GiB swap effectively; keep enabled for compatibility.
- Taint sources (e.g. proprietary Broadcom `wl`) not needed—stick to b43 for simplicity.
- No more x32 ABI: remove stale options or package.env entries referencing x32.
- After any kernel install, double-check `/etc/lilo.conf` to ensure the `image` paths are correct before running `lilo -v`.
