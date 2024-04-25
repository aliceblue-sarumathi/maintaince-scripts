#!/bin/bash

# Define log file path
LOG_FILE="/var/log/service_restart.log"

# Redirect stdout and stderr to the log file
exec >> "$LOG_FILE" 2>&1

# Print date and time of script execution
echo "----------------------------------------"
echo "$(date): Restarting SSH and systemd-login services..."

# Restart SSH service
echo "Restarting SSH service..."
sudo systemctl restart sshd

# Restart systemd-login service
echo "Restarting systemd-login service..."
sudo systemctl restart systemd-logind

# Print completion message
echo "Services restarted successfully."
echo "----------------------------------------"
