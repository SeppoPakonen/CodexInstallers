#!/bin/bash
# Hardware Information Gathering Script for Compaq Mini 900
#
# This script connects to the Compaq Mini 900 and gathers hardware information
# via SSH, then saves it to appropriate documentation files.

set -euo pipefail
umask 022

TARGET_HOST="192.168.1.129"
TARGET_USER="root"

echo "Connecting to Compaq Mini 900 at $TARGET_HOST"
echo "Gathering hardware information..."

# Create a temporary directory for collected data
TEMP_DIR=$(mktemp -d)

# Collect hardware information
ssh "$TARGET_USER@$TARGET_HOST" "
    echo '=== System Information ===' > /tmp/hwinfo.txt
    uname -a >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== CPU Information ===' >> /tmp/hwinfo.txt
    lscpu >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== Memory Information ===' >> /tmp/hwinfo.txt
    free -h >> /tmp/hwinfo.txt
    cat /proc/meminfo | grep -i total >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== Storage Devices ===' >> /tmp/hwinfo.txt
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== Detailed Storage Information ===' >> /tmp/hwinfo.txt
    lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== Partition Information ===' >> /tmp/hwinfo.txt
    fdisk -l >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== PCI Devices ===' >> /tmp/hwinfo.txt
    lspci >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== USB Devices ===' >> /tmp/hwinfo.txt
    lsusb >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
    
    echo '=== DMI/SMBIOS Information ===' >> /tmp/hwinfo.txt
    dmidecode -s system-product-name 2>/dev/null || echo 'DMI decode not available' >> /tmp/hwinfo.txt
    dmidecode -s system-manufacturer 2>/dev/null || echo 'DMI decode not available' >> /tmp/hwinfo.txt
    dmidecode -s system-version 2>/dev/null || echo 'DMI decode not available' >> /tmp/hwinfo.txt
    dmidecode -s bios-version 2>/dev/null || echo 'DMI decode not available' >> /tmp/hwinfo.txt
    dmidecode -s bios-release-date 2>/dev/null || echo 'DMI decode not available' >> /tmp/hwinfo.txt
    echo '' >> /tmp/hwinfo.txt
" || {
    echo "Error connecting to $TARGET_HOST. Please verify SSH access and credentials."
    exit 1
}

# Copy the collected information to local files
scp "$TARGET_USER@$TARGET_HOST:/tmp/hwinfo.txt" "$TEMP_DIR/hwinfo.txt"
ssh "$TARGET_USER@$TARGET_HOST" "rm /tmp/hwinfo.txt"

# Update the NOTES.md file with the collected information
cat >> NOTES.md << 'EOL'

## Hardware Information Collected on $(date)

### System Information
EOL

# Append collected data to NOTES.md
tail -n +4 "$TEMP_DIR/hwinfo.txt" >> NOTES.md

echo "Hardware information has been collected and added to NOTES.md"
echo "Storage devices identified:"
grep -A 20 "Storage Devices" "$TEMP_DIR/hwinfo.txt"
echo ""
echo "Partition information:"
grep -A 50 "Partition Information" "$TEMP_DIR/hwinfo.txt"

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "Hardware information collection completed."