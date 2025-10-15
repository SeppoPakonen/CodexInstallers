# Hardware Specifications - Compaq Mini 900

## System Information
- **Model**: Compaq Mini 900 series
- **Form Factor**: Netbook
- **Release Year**: ~2009
- **Chassis**: Plastic, compact design

## Processor
- **CPU**: Intel(R) Atom(TM) CPU N270 @ 1.60GHz
- **Architecture**: i686 (32-bit)
- **CPU Family**: 6, Model: 28, Stepping: 2
- **Cores**: 1 physical core with 2 logical processors (hyper-threading)
- **Clock Speed**: 1.6GHz (max), 800MHz (min)
- **TDP**: 2.5W (typical for N270)
- **Virtualization**: No VT-x support
- **Cache**: L1d 24KiB, L1i 32KiB, L2 512KiB

## Memory
- **RAM**: 1.9 GiB available
- **Type**: DDR2 SO-DIMM (estimated based on typical configurations)
- **Slots**: 1 (estimated)
- **Max**: 2GB max supported (estimated)

## Storage
- **sda**: SanDisk pSSD 16G, 15.27 GiB (16,391,208,960 bytes)
  - Disk model: SanDisk pSSD 16G
  - Sector size: 512 bytes logical/physical
  - Disklabel type: dos (MBR)
  - Partitions:
    - sda1: 100MB NTFS partition, bootable (204,800 sectors)
    - sda2: 15.2GB NTFS partition (31,803,392 sectors)
- **sdb**: TS1GJF150, 980 MiB - Appears to be current boot medium (Gentoo live USB)
  - Disk model: TS1GJF150
  - Sector size: 512 bytes logical/physical
  - Disklabel type: gpt
- **sdc**: Flash Reader, 115.94 GiB (124,486,942,720 bytes) - SD Card
  - Disk model: Flash Reader (likely an SD card reader)
  - Sector size: 512 bytes logical/physical
  - Currently unpartitioned or has GPT with mismatched PMBR
- **Interface**: SATA for sda, USB for sdb and sdc

## Graphics
- **GPU**: Intel Mobile 945GSE Express Integrated Graphics Controller (rev 03)
- **Shared Memory**: Uses system RAM
- **Display Output**: VGA, internal LCD
- **Resolution Support**: Up to 1024x600 native on screen

## Display
- **Screen Size**: 10.2 inches
- **Native Resolution**: 1024x600 (WSVGA)
- **Aspect Ratio**: 16:10
- **Touchscreen**: No

## Networking
- **Ethernet**: 10/100 Fast Ethernet
- **WiFi**: Built-in (varies by configuration)
  - Common: Atheros or Intel wireless
  - Standards: 802.11b/g
  - No 802.11n support
- **Bluetooth**: May not be available on all units

## Audio
- **Speakers**: Built-in stereo speakers
- **Audio Chip**: Likely Intel HD Audio
- **Ports**: 3.5mm headphone jack

## Ports & Connectors
- **USB**: 3x USB 2.0 ports
- **Video**: VGA output port
- **Network**: RJ45 Ethernet
- **Audio**: Headphone jack
- **Power**: DC power connector

## Input Devices
- **Keyboard**: Full-size keyboard with function keys
- **Touchpad**: Integrated touchpad with left/right buttons
- **Pointing Stick**: Not available

## Power
- **Battery**: 6-cell Li-ion (varies)
- **AC Adapter**: Standard laptop brick adapter
- **Power Requirements**: ~65W

## Boot Firmware
- **BIOS**: Legacy BIOS (not UEFI)
- **Boot Modes**: BIOS boot only
- **Secure Boot**: Not supported

## Installation Implications
- **Architecture**: 32-bit (x86) Gentoo required
- **Memory**: Consider 64MB or smaller filesystem journal sizes
- **Compilation**: Use -j1 or -j2 for make to avoid memory pressure
- **Kernel**: No VT-x for KVM/QEMU support
- **Graphics**: Intel i915/i965 drivers needed
- **Bootloader**: Use GRUB legacy or SYSLINUX (BIOS support)