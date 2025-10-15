#!/bin/bash
# Execute Dual-Storage Setup on Compaq Mini 900 via SSH
#
# This script connects to the target Compaq Mini 900 via SSH and executes
# the dual-storage configuration script.

set -euo pipefail
umask 022

TARGET_HOST="192.168.1.129"
TARGET_USER="root"

echo "Connecting to Compaq Mini 900 at $TARGET_HOST"
echo "Executing dual-storage configuration..."

# Copy the target script to the remote system
scp scripts/dual-storage-target-setup.sh "$TARGET_USER@$TARGET_HOST:/tmp/dual-storage-setup.sh"

# Execute the script on the target system
ssh "$TARGET_USER@$TARGET_HOST" "
    chmod +x /tmp/dual-storage-setup.sh
    /tmp/dual-storage-setup.sh
"

echo ""
echo "Dual-storage setup completed on target system!"
echo "Check the following on the target system:"
echo "1. /root/dual-storage-setup-notes.txt - for next steps"
echo "2. Fstab has been updated with SD card mount"
echo "3. After reboot, implement the bind mounts as documented"