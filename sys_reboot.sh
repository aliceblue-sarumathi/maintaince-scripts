#!/bin/bash

# Log file path
LOG_FILE="/Data/files/scripts/log/reboot.log"

# Function to log reboot event
log_reboot() {
    echo "$(date): System rebooted" >> "$LOG_FILE"
}

# Function to perform system reboot
reboot_system() {
    echo "$(date): Rebooting system..." >> "$LOG_FILE"
    sudo reboot
}

# Check if the script is run with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Perform reboot and log event
reboot_system && log_reboot
