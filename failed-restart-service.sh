#!/bin/bash

# Define the syslog file to monitor
SYSLOG_FILE="/var/log/syslog"

# Define the error message to search for
ERROR_MESSAGE="pam_systemd(sshd:session): Failed to create session: Connection timed out"

# Define the service to restart
SERVICE_TO_RESTART="sshd"

# Function to check if the error message is present in the syslog file
check_error() {
    if grep -q "$ERROR_MESSAGE" "$SYSLOG_FILE"; then
        return 0  # Error found
    else
        return 1  # Error not found
    fi
}

# Main loop
while true; do
    if check_error; then
        echo "Error found in syslog. Restarting $SERVICE_TO_RESTART service..."
        systemctl restart "$SERVICE_TO_RESTART"
    fi
    sleep 40  # Check every 40 seconds (adjust as needed)
done
