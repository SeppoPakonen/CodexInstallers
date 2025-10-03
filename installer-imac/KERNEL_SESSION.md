Kernel Task Session — Wrap‑Up

Scope: Final notes to close the kernel configuration/build task for the iMac A1228 Gentoo install.

What Was Done
- Collected hardware inventory from the remote iMac (CPU, PCI, USB, modules).
- Prepared kernel configuration in the Gentoo target tree:
  - Path: `/mnt/gentoo/usr/src/linux/.config`
  - Backup: `/mnt/gentoo/root/kernel-config-imac-YYYYMMDD-HHMM.txt`
- Enabled drivers and options matching detected hardware and systemd requirements (see KERNEL.md for the exact list).

Key Hardware Identifiers
- GPU: AMD/ATI Mobility Radeon HD 2600 (RV630/M76) [1002:9583]
- Wi‑Fi: Broadcom BCM4321 [14e4:4328] (b43 + ssb/bcma)
- Ethernet: Marvell Yukon2 88E8058 [11ab:436a] (sky2)
- Chipset/Storage: Intel ICH8 (ata_piix; AHCI also enabled)
- Audio: Intel HDA (ICH8) — likely Realtek codec
- FireWire: LSI FW643 (firewire_ohci)
- Apple: applesmc, apple backlight, hid_apple/ir

Build Checklist (for operator)
1) Enter chroot and build:
   - `chroot /mnt/gentoo /bin/bash`
   - `env-update && source /etc/profile`
   - `cd /usr/src/linux && make -j2 && make modules_install`
   - Optional initramfs: `dracut --kver "$(make kernelrelease)"`
   - Install kernel: `cp arch/x86/boot/bzImage /boot/vmlinuz-"$(make kernelrelease)"`
   - Save config: `cp .config /boot/config-"$(make kernelrelease)"`
2) Firmware:
   - `emerge --ask sys-kernel/linux-firmware net-wireless/b43-firmware`
   - Verify Radeon RV630 firmware and b43 firmware files exist under `/lib/firmware/`
3) Bootloader:
   - Ensure `/boot` and `/boot/efi` mounted
   - `grub-mkconfig -o /boot/grub/grub.cfg`

Post‑Boot Verification
- GPU (radeon KMS, firmware load), Wi‑Fi up with b43, Ethernet sky2 link, Audio HDA initialized, applesmc hwmon present.

References
- Detailed options and rationale: `KERNEL.md`

