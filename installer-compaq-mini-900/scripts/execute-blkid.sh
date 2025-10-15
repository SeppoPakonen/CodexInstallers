#!/bin/bash
# Execute blkid on Compaq Mini 900 via SSH
#
# This script connects to the target Compaq Mini 900 via SSH and executes
# the blkid command to identify storage devices.

set -euo pipefail
umask 022

TARGET_HOST="192.168.1.129"
TARGET_USER="root"

echo "Connecting to Compaq Mini 900 at $TARGET_HOST"
echo "Executing blkid command..."

# Execute the blkid command on the target system
ssh "$TARGET_USER@$TARGET_HOST" "blkid"

echo ""
echo "blkid command completed."