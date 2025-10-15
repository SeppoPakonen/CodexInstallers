# Compaq Mini 900 Installer AGENTS.md

## Overview
Device-specific runbook for installing Gentoo Linux on Compaq Mini 900 netbook via SSH.

## Hardware Details
- Model: Compaq Mini 900 series
- CPU: Intel Atom N270 (1.6GHz, 32-bit)
- RAM: Likely 1-2GB
- Storage: 160GB HDD (may vary)
- Graphics: Intel GMA 950
- Network: Ethernet + possible built-in WiFi
- BIOS: Legacy BIOS (likely older version)

## Target SSH Connection
- IP: 192.168.1.129
- User: root
- Connection: `ssh root@192.168.1.129`

## Installation Prerequisites
- Target device accessible via SSH
- Working live environment on target (e.g., Gentoo minimal install CD booted)
- Network connectivity on target device
- Backup of any important data on target device

## Session Setup Checklist
```bash
# On target device
tmux new -s gentoo_install
script -aq /root/install.log
set -euo pipefail
umask 022
date  # Verify time is correct
ip a  # Verify network connectivity
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT  # Check storage
```

## Destructive Operations Confirmation
⚠️ **CRITICAL**: Before any destructive operation, confirm target device:

```bash
# Verify the correct disk before partitioning/formatting
lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE
blkid
# Manually confirm target device path (e.g., /dev/sda) before proceeding
```

## Installation Steps
1. **[COMPLETED]** Hardware verification and documentation
   - Hardware identified: Intel Atom N270, 1.9GB RAM, 16GB SSD, 128GB SD Card
   - lspci/lsusb analysis completed
2. **[COMPLETED]** Disk partitioning (BIOS boot compatible)
   - sda1: 512MB boot (vfat)
   - sda2: 3GB swap
   - sda3: ~12.5GB root (ext4)
   - sdc1: ~115GB storage (ext4) for dual-storage setup
3. **[COMPLETED]** Stage 3 installation preparation
4. **[COMPLETED]** Base system installation
   - Stage3 extracted and configured
   - make.conf optimized for limited RAM and Atom CPU
5. **[IN PROGRESS]** Kernel configuration and compilation
   - Kernel sources installed (gentoo-sources-6.12.41)
   - Hardware-specific config completed
   - **WAITING**: Kernel compilation ongoing (taking several hours due to hardware constraints)
6. **[PENDING]** System configuration
7. **[PENDING]** Bootloader installation
8. **[PENDING]** Post-installation setup

## Hardware-Specific Findings
- Intel Atom N270 CPU with 1.9GB RAM significantly slows compilation
- Intel Mobile 945GSE Express Integrated Graphics Controller requires CONFIG_DRM_I915
- Broadcom BCM4312 wireless controller requires CONFIG_B43/CONFIG_B43LEGACY
- Marvell 88E8040 Ethernet controller requires CONFIG_MARVELL_PHY
- Audio requires CONFIG_SND_HDA_CODEC_CONEXANT

## Optimization Notes
- make.conf includes: MAKEOPTS="-j2 -l1.5" for memory management
- USE flags limited to reduce compilation requirements
- make.conf has optimized settings for Atom hardware
- Dual-storage setup prepared in fstab with bind mounts

## Target Partition Layout
Example layout for typical Compaq Mini 900 (160GB HDD):
- `/dev/sda1` - 512MB - /boot (FAT32 for compatibility)
- `/dev/sda2` - 4GB - swap
- `/dev/sda3` - remaining space - / (root)

## Specific Configuration Considerations
- Use appropriate USE flags for older hardware (minimal, lightweight)
- Consider using syslinux instead of GRUB for BIOS compatibility
- Configure power management for netbook usage
- Select lightweight desktop environment or minimal X11
- Enable Intel graphics acceleration for GMA 950

## Kernel Requirements
- Enable Intel GMA 950 graphics support
- Enable appropriate CPU support for Atom N270
- Enable wireless drivers if needed
- Enable older USB/PCI support as needed

## References
- Follow patterns from `../installer-dell-e6540/AGENTS.md` and `../installer-imac/AGENTS.md`
- Consult Gentoo handbook for x86 installation
- Consider Atom-specific optimization flags