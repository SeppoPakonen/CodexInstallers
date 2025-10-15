#!/bin/bash
# Post-Installation Dual-Storage Configuration
#
# This script should be run after the base Gentoo system is installed
# to set up the optimal dual-storage configuration:
# - Frequently accessed files on 16GB SSD 
# - Less frequently accessed files on 128GB SD Card

set -euo pipefail
umask 022

echo "Post-Installation Dual-Storage Configuration"
echo "============================================="
echo "Making optimal use of SSD for system and SD Card for storage"
echo ""

# Identify the SD card by size and filesystem characteristics
# This approach finds the SD card regardless of its device name
SD_CARD_DEVICE=$(lsblk -r -o NAME,SIZE,TYPE | grep disk | grep "115." | head -1 | awk '{print "/dev/"$1}')

if [ -z "$SD_CARD_DEVICE"1 ]; then
    # Alternative: Look for the unpartitioned device that's closest to 128GB
    SD_CARD_DEVICE=$(lsblk -r -o NAME,SIZE,TYPE | grep disk | grep -E "(11[5-9]|12[0-8]).*disk" | head -1 | awk '{print "/dev/"$1}')
fi

echo "Identified SD card device as: $SD_CARD_DEVICE"

# Identify the SD card partition (should be the only ext4 partition on that device)
SD_PARTITION=$(lsblk -r -o NAME,FSTYPE | grep ext4 | grep "$(basename $SD_CARD_DEVICE)" | head -1 | awk '{print "/dev/"$1}')

if [ -z "$SD_PARTITION" ]; then
    echo "ERROR: Could not identify SD card partition"
    echo "Available ext4 filesystems:"
    lsblk -r -o NAME,FSTYPE | grep ext4
    exit 1
fi

echo "Identified SD card partition as: $SD_PARTITION"
echo ""

# Mount SD card if not already mounted
SD_MOUNT_POINT="/mnt/sdcard"
if ! mountpoint -q "$SD_MOUNT_POINT"; then
    echo "Mounting SD card ($SD_PARTITION) to $SD_MOUNT_POINT..."
    mkdir -p "$SD_MOUNT_POINT"
    mount "$SD_PARTITION" "$SD_MOUNT_POINT"
fi

# Create the storage directories on SD card if they don't exist
echo "Ensuring SD card storage directories exist..."
mkdir -p "$SD_MOUNT_POINT"/{home,usr/portage,var/cache/distfiles,var/tmp}

# Before creating bind mounts, we need to ensure the target directories exist on the SSD
# and move any existing content to the SD card

# Create the mount points on the SSD if they don't exist
mkdir -p /home /usr/portage /var/cache/distfiles /var/tmp

# Function to migrate data to SD card and set up bind mount
migrate_and_bind_mount() {
    local ssd_path="$1"
    local sd_path="$2"
    local description="$3"
    
    echo "Setting up $description..."
    
    # If the SSD path exists and contains data, move it to SD card
    if [ -d "$ssd_path" ] && [ "$(ls -A "$ssd_path" 2>/dev/null)" ]; then
        echo "  Moving existing data from $ssd_path to $sd_path..."
        rsync -aHAXxSP "$ssd_path"/ "$sd_path"/
    elif [ -d "$ssd_path" ] && [ ! "$(ls -A "$ssd_path" 2>/dev/null)" ]; then
        echo "  No existing data in $ssd_path, creating empty directories on SD card..."
        mkdir -p "$sd_path"
    fi
    
    # Add to fstab for bind mount
    if ! grep -q "$ssd_path none bind" /etc/fstab; then
        echo "$sd_path $ssd_path none bind 0 0" >> /etc/fstab
        echo "  Added bind mount to fstab"
    else
        echo "  Bind mount already in fstab"
    fi
    
    # Mount the bind mount
    mount "$ssd_path"
    echo "  $description bind mount configured and active"
    echo ""
}

# Apply the migration and bind mount setup
migrate_and_bind_mount "/home" "$SD_MOUNT_POINT/home" "User home directories"
migrate_and_bind_mount "/usr/portage" "$SD_MOUNT_POINT/usr/portage" "Portage tree"
migrate_and_bind_mount "/var/cache/distfiles" "$SD_MOUNT_POINT/var/cache/distfiles" "Distfiles cache"
migrate_and_bind_mount "/var/tmp" "$SD_MOUNT_POINT/var/tmp" "Persistent temporary files"

# For /var/log, we'll keep it on the SSD but ensure it's optimized for SSD life
echo "Keeping /var/log on SSD for performance, but optimizing..."
# We'll add log rotation configuration to /etc/logrotate.d/ssd-optimization
cat > /etc/logrotate.d/ssd-optimization << 'EOF'
/var/log/*log {
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    copytruncate  # This helps avoid log file growth issues
}
EOF

# Add tmpfs for /tmp to reduce SSD wear (optional)
if ! grep -q "tmpfs /tmp" /etc/fstab; then
    echo "tmpfs /tmp tmpfs defaults,size=512M,mode=1777 0 0" >> /etc/fstab
    mkdir -p /tmp
    mount /tmp
    echo "Configured tmpfs for /tmp to reduce SSD wear"
fi

# Document the configuration in fstab as a comment
cat >> /etc/fstab << 'EOF'

# Dual-storage configuration notes:
# - Root filesystem (sda3) is used for OS and frequently accessed files
# - SD card (sdc1) is mounted at /mnt/sdcard for extended storage
# - Bind mounts redirect less frequently accessed directories to SD card:
#   * /home -> /mnt/sdcard/home
#   * /usr/portage -> /mnt/sdcard/usr/portage
#   * /var/cache/distfiles -> /mnt/sdcard/var/cache/distfiles
#   * /var/tmp -> /mnt/sdcard/var/tmp
# - /var/log remains on SSD for performance
# - /tmp uses tmpfs to reduce SSD wear
EOF

echo ""
echo "Dual-storage configuration complete!"
echo ""
echo "Configuration summary:"
echo "- Home directories redirected to SD card via bind mount"
echo "- Portage tree stored on SD card via bind mount"
echo "- Distfiles cache stored on SD card via bind mount"
echo "- Temporary files stored on SD card via bind mount"
echo "- Logs kept on SSD for performance"
echo "- Temporary directory uses tmpfs to reduce SSD wear"
echo ""
echo "The system will maintain this configuration across reboots via fstab entries."
echo "To verify the configuration, run: mount | grep bind"