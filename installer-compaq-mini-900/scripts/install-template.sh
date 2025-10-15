#!/bin/bash
# Compaq Mini 900 Installation Script Template
#
# This is a template for installation scripts specific to the Compaq Mini 900.
# Follow the conventions specified in the parent AGENTS.md and repository AGENTS.md:
# - Use set -euo pipefail for error handling
# - Include confirmation prompts before destructive operations
# - Use logging and tmux for session resilience

set -euo pipefail
umask 022

echo "Compaq Mini 900 Installation Script"
echo "==================================="
echo "This is a template script to be customized for specific installation steps."
echo ""
echo "Before proceeding, ensure:"
echo "- You are in a tmux session with logging enabled"
echo "- Target hardware has been verified"
echo "- Destructive operations will require explicit confirmation"
echo ""

# Example function structure
verify_hardware() {
    echo "Verifying hardware..."
    # Add hardware verification commands here
    lscpu
    free -h
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
}

confirm_target_disk() {
    local target_device="$1"
    echo "WARNING: About to perform destructive operations on $target_device"
    echo "Device details:"
    lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE "$target_device"
    read -p "Type the device path again to confirm: " user_input
    if [ "$user_input" != "$target_device" ]; then
        echo "Confirmation failed. Exiting."
        exit 1
    fi
    echo "Confirmation successful. Proceeding with operations on $target_device"
}

# Main execution can be added here
# verify_hardware
# confirm_target_disk /dev/sda

echo "Script template complete. Customize for specific installation steps."