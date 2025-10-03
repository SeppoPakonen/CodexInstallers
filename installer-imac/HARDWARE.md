Hardware Inventory — iMac A1228 (Summary)

CPU
- Intel Core 2 Duo (family 6, model 23), x86_64; VT‑x present; x32 ABI supported by kernel.

PCI Devices (essential)
- VGA: AMD/ATI RV630/M76 — Mobility Radeon HD 2600 XT/2700 [1002:9583] (Apple iMac 7,1)
- Wi‑Fi: Broadcom BCM4321 [14e4:4328] — driver: b43 (via ssb/bcma)
- Ethernet: Marvell 88E8058 Yukon2 [11ab:436a] — driver: sky2
- SATA/IDE: Intel ICH8 — currently IDE mode (ata_piix), AHCI supported
- SMBus: Intel ICH8
- FireWire: LSI FW643 (1394b) — driver: firewire_ohci

USB
- Controllers: UHCI/EHCI (Intel ICH8)
- Notables:
  - Bluetooth: btusb
  - Webcam: UVC (uvcvideo)
  - HID: Apple keyboard/mouse via usbhid

Kernel Modules Observed (live session)
- Networking: b43, ssb, bcma, cfg80211, mac80211, sky2, btusb
- Graphics: radeon (expected), fb/console helpers
- Audio: snd_hda_intel (+ Realtek codec)
- Apple: applesmc, apple_bl, hid_apple, hid_appleir
- Storage: ata_piix, usb_storage, uas; firewire_ohci

Notes
- Wi‑Fi requires b43 firmware blobs (installed via `net-wireless/b43-firmware`).
- Radeon RV630 requires firmware from `sys-kernel/linux-firmware` for KMS.
- Switching chipset to AHCI is supported by the kernel; prefer UUIDs in fstab.

