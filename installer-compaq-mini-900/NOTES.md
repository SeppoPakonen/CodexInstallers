# Installation Notes - Compaq Mini 900

## Connection Information
- **Target IP**: 192.168.1.129
- **Connection Method**: SSH
- **Target User**: root
- **Session Management**: Use tmux with logging

## Hardware Verification Commands
When SSH'd to the target device, run these to verify hardware:

```bash
# Basic system info
uname -a
lscpu
free -h
lspci
lsusb
dmesg | grep -i atom
dmesg | grep -i intel

# Storage info
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
fdisk -l
parted -l

# Network info
ip addr show
ip route show
```

## Actual Hardware Information (as of current connection)
- **CPU**: Intel(R) Atom(TM) CPU N270 @ 1.60GHz (i686 architecture, 2 logical processors)
- **Memory**: 1.9 GiB available
- **Graphics**: Intel Mobile 945GSE Express Integrated Graphics Controller
- **Storage**:
  - sda: 15.3GB disk (likely SSD)
    - sda1: 100MB NTFS partition
    - sda2: 15.2GB NTFS partition
  - sdb: 980MB disk (appears to be boot medium, ISO or similar)
  - sdc: 115.9GB disk (SD card or USB storage)

## Disk Partitioning Strategy
For the Compaq Mini 900 with 160GB drive:
- Small /boot partition (512MB, FAT32) for BIOS compatibility
- Swap partition (4GB) for memory management on 1-2GB RAM
- Root partition with remaining space

## WiFi Considerations
- Compaq Mini 900 may have various WiFi cards depending on model
- Check lspci output to identify exact model
- Common models need specific firmware packages
- Consider using wired connection for installation

## BIOS Settings
- Ensure legacy boot is enabled (not UEFI)
- Set SATA mode to AHCI if available
- Disable unnecessary legacy devices to save resources
- Ensure network boot options are set if needed as fallback

## Performance Optimizations
For the limited resources of the Mini 900:
- Use lightweight init system (OpenRC default is fine)
- Choose lightweight DE (XFCE, LXDE, or even just TWM)
- Minimize background services
- Use zram or careful swap management

## Troubleshooting Tips
- If installation hangs: Check memory usage and adjust MAKEOPTS
- If graphics are problematic: Use nomodeset initially, configure later
- If boot fails: Try GRUB legacy instead of GRUB2 (better BIOS compatibility)
- If network drops: Use wired connection if possible

## Package Selection
- Use stable versions for better compatibility
- Avoid experimental drivers
- Keep desktop environment minimal
- Monitor disk space usage during installation

## Command History
Record important commands used during installation:

# Example:
# parted /dev/sda mklabel msdos
# parted /dev/sda mkpart primary fat32 1MiB 513MiB
# parted /dev/sda mkpart primary linux-swap 513MiB 4609MiB
# parted /dev/sda mkpart primary ext4 4609MiB 100%