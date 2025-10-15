#!/bin/bash
# Complete Installation Script for Compaq Mini 900 with Dual-Storage Setup
#
# This script will:
# 1. Partition and format the storage devices appropriately
# 2. Set up the dual-storage configuration as requested
# 3. Prepare the system for Gentoo installation

set -euo pipefail
umask 022

echo "Compaq Mini 900 Installation with Dual-Storage Setup"
echo "==================================================="
echo "Storage configuration:"
echo "  sda: 16GB SSD - for root filesystem, logs, frequently accessed files"
echo "  sdc: 128GB SD Card - for home, portage tree, distfiles, rarely accessed data"
echo ""

# Verify devices exist
if [ ! -b /dev/sda ] || [ ! -b /dev/sdc ]; then
    echo "ERROR: Required storage devices not found!"
    echo "Expected: /dev/sda (16GB SSD) and /dev/sdc (128GB SD Card)"
    lsblk
    exit 1
fi

echo "Current storage configuration:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
echo ""

# Function to confirm destructive operations
confirm_operation() {
    local device="$1"
    local operation="$2"
    
    echo "WARNING: About to perform $operation on $device"
    echo "Device details:"
    lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE "$device"
    read -p "Type the device path again to confirm: " user_input
    if [ "$user_input" != "$device" ]; then
        echo "Confirmation failed. Exiting."
        exit 1
    fi
    echo "Confirmation successful. Proceeding with $operation on $device"
}

# Partitioning scheme for sda (16GB SSD):
# - /dev/sda1: 512MB boot partition (FAT32 for BIOS compatibility)
# - /dev/sda2: 3GB swap
# - /dev/sda3: remaining space for root filesystem (~12.5GB)

echo "Partitioning sda (16GB SSD) for Gentoo installation..."
confirm_operation "/dev/sda" "partition for Gentoo installation"

echo "Creating partition table on sda..."
parted /dev/sda mklabel msdos

echo "Creating partitions on sda:"
parted /dev/sda mkpart primary fat32 1MiB 513MiB          # /boot (512MB)
parted /dev/sda mkpart primary linux-swap 513MiB 3649MiB  # swap (3GB)
parted /dev/sda mkpart primary ext4 3649MiB 100%          # root (remaining space)

echo "Setting boot flag on sda1..."
parted /dev/sda set 1 boot on

echo "Partitioning complete for sda:"
parted /dev/sda print
echo ""

# Format sda partitions
echo "Formatting sda partitions..."
mkfs.vfat -F32 /dev/sda1  # boot partition
mkswap /dev/sda2          # swap partition
mkfs.ext4 /dev/sda3       # root partition

echo "sda partitions formatted:"
lsblk -o NAME,SIZE,TYPE,FSTYPE /dev/sda
echo ""

# Partitioning and formatting sdc (128GB SD Card) for storage
echo "Partitioning sdc (128GB SD Card) for storage..."
confirm_operation "/dev/sdc" "partition for storage"

echo "Creating partition table on sdc..."
parted /dev/sdc mklabel gpt

echo "Creating partition on sdc..."
parted /dev/sdc mkpart primary ext4 1MiB 100%

echo "Formatting sdc partition..."
mkfs.ext4 -F /dev/sdc1

echo "SD card partition created and formatted:"
lsblk -o NAME,SIZE,TYPE,FSTYPE /dev/sdc
echo ""

# Create mount points and mount filesystems
echo "Mounting filesystems for installation..."
mount /dev/sda3 /mnt/gentoo  # root
mkdir -p /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot  # boot

# Mount SD card temporarily to prepare storage directories
SD_MOUNT_POINT="/mnt/sdcard"
mkdir -p "$SD_MOUNT_POINT"
mount /dev/sdc1 "$SD_MOUNT_POINT"

# Create directories on SD card for less frequently accessed data
mkdir -p "$SD_MOUNT_POINT"/{home,usr/portage,var/cache/distfiles,var/tmp}

echo "SD card directories created:"
ls -la "$SD_MOUNT_POINT"
echo ""

# Set up swap
swapon /dev/sda2
echo "Swap activated: $(swapon --show)"

# Next steps would be:
echo ""
echo "Storage setup complete!"
echo "Next steps for Gentoo installation:"
echo "1. Download and extract stage3 tarball to /mnt/gentoo"
echo "2. Bind mount necessary filesystems:"
echo "   mount -t proc /proc /mnt/gentoo/proc"
echo "   mount --rbind /sys /mnt/gentoo/sys"
echo "   mount --rbind /dev /mnt/gentoo/dev"
echo "3. Copy DNS settings: cp /etc/resolv.conf /mnt/gentoo/etc/"
echo "4. chroot into /mnt/gentoo and continue with installation:"
echo "   chroot /mnt/gentoo /bin/bash"
echo "5. After installing base system, set up fstab with:"
echo "   - sda3 as root filesystem"
echo "   - sda1 as boot partition" 
echo "   - sdc1 mounted at /mnt/sdcard for storage"
echo "6. After first boot, set up bind mounts for optimal storage usage"

# Wait a moment for the kernel to recognize the new partitions
sleep 2

# Get UUIDs for fstab
ROOT_UUID=$(blkid -s UUID -o value /dev/sda3)
BOOT_UUID=$(blkid -s UUID -o value /dev/sda1)
SD_UUID=$(blkid -s UUID -o value /dev/sdc1)  # SD card partition
SWAP_UUID=$(blkid -s UUID -o value /dev/sda2)

# Create fstab content for reference
cat > /tmp/fstab_content.txt << EOF
# /etc/fstab: static file system information.
#
# noatime: reduces disk writes (good for SSD)
# relatime: compromise between atime and noatime

# Root filesystem
UUID=$ROOT_UUID	/          ext4    noatime	0 1

# Boot partition
UUID=$BOOT_UUID	/boot      vfat    noatime	0 2

# SD Card for storage
UUID=$SD_UUID	/mnt/sdcard ext4    defaults,relatime	0 2

# Swap
UUID=$SWAP_UUID	none       swap    sw	0 0
EOF

echo ""
echo "Sample fstab content saved to /tmp/fstab_content.txt on target system:"
cat /tmp/fstab_content.txt

echo ""
echo "Installation preparation complete!"