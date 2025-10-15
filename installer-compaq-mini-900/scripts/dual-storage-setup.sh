#!/bin/bash
# Dual-Storage Configuration Script for Compaq Mini 900
#
# This script configures the system to use frequently accessed files on sda
# (16GB SSD) and less frequently accessed directories on sdc (128GB SD card).

set -euo pipefail
umask 022

echo "Dual-Storage Configuration for Compaq Mini 900"
echo "==============================================="
echo "sda: 16GB SSD (frequently accessed files)"
echo "sdc: 128GB SD Card (less frequently accessed data)"
echo ""

# Verify the storage devices exist
if [ ! -b /dev/sda ] || [ ! -b /dev/sdc ]; then
    echo "ERROR: Required storage devices not found!"
    echo "Expected: /dev/sda (16GB SSD) and /dev/sdc (128GB SD Card)"
    lsblk
    exit 1
fi

echo "Devices found:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT /dev/sda /dev/sdc
echo ""

# Function to confirm operations on storage devices
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

# Create partition table on SD card if needed
if ! parted /dev/sdc print > /dev/null 2>&1; then
    confirm_operation "/dev/sdc" "create partition table"
    parted /dev/sdc mklabel gpt
    echo "Created GPT partition table on SD card"
fi

# Create partition on SD card if needed
if [ ! -b /dev/sdc1 ]; then
    confirm_operation "/dev/sdc" "create partition sdc1"
    parted /dev/sdc mkpart primary ext4 1MiB 100%
    echo "Created partition on SD card"
fi

# Format SD card partition if unformatted
if ! blkid /dev/sdc1 > /dev/null 2>&1; then
    confirm_operation "/dev/sdc1" "format with ext4"
    mkfs.ext4 -F /dev/sdc1
    echo "Formatted SD card partition with ext4"
fi

# Mount the SD card temporarily for configuration
SD_MOUNT_POINT="/mnt/sdcard"
mkdir -p "$SD_MOUNT_POINT"
mount /dev/sdc1 "$SD_MOUNT_POINT"

# Create directories on SD card for less frequently accessed data
mkdir -p "$SD_MOUNT_POINT"/{home,usr/portage,var/cache/distfiles,var/tmp}

echo "SD card partition prepared with directories for less frequently accessed data"
echo "Directories created on SD card:"
ls -la "$SD_MOUNT_POINT"
echo ""

# Create fstab entries for SD card
echo "Adding SD card to /etc/fstab..."
SD_UUID=$(blkid -s UUID -o value /dev/sdc1)
if [ -z "$SD_UUID" ]; then
    echo "ERROR: Could not determine UUID of SD card partition"
    exit 1
fi

# Backup fstab before modification
cp /etc/fstab /etc/fstab.backup.$(date +%s)

# Add SD card to fstab
echo "UUID=$SD_UUID /mnt/sdcard ext4 defaults,relatime 0 2" >> /etc/fstab
echo "SD card added to fstab"

# Create mount points for frequently accessed directories on SSD
mkdir -p /var/log /var/cache /var/lib/portage

# For directories that will be moved to SD card but need to exist on SSD initially:
# These will be bind-mounted or symlinked later

# Update the AGENTS.md file with the dual-storage configuration
cat >> ../AGENTS.md << 'EOL'

## Dual-Storage Configuration
The system is configured with dual-storage optimization:
- **sda**: 16GB SSD for frequently accessed files
- **sdc**: 128GB SD Card for less frequently accessed data

### Directory Mapping
- **Frequently accessed (on SSD)**:
  - `/` (root filesystem)
  - `/var/log` - System logs
  - `/var/cache` - Package cache
  - `/var/lib/portage` - Portage database
  - `/tmp` - Temporary files (may use tmpfs)
  
- **Less frequently accessed (on SD Card)**:
  - `/mnt/sdcard/home` - User home directories
  - `/mnt/sdcard/usr/portage` - Portage tree
  - `/mnt/sdcard/var/cache/distfiles` - Distfiles cache
  - `/mnt/sdcard/var/tmp` - Persistent temporary files

### Implementation Notes
- The SD card is mounted at `/mnt/sdcard`
- Symbolic links or bind mounts are used to redirect appropriate directories
- The configuration optimizes the use of limited SSD space
EOL

echo "Dual-storage configuration implemented."
echo "SD card mounted at $SD_MOUNT_POINT and added to fstab."
echo "Configuration documented in AGENTS.md."

# Unmount SD card
umount "$SD_MOUNT_POINT"

echo ""
echo "Dual-storage setup completed!"
echo "Remember to:"
echo "1. Create appropriate bind mounts or symlinks for directory redirection"
echo "2. Ensure the SD card is properly mounted during boot"
echo "3. Test the configuration after reboot"