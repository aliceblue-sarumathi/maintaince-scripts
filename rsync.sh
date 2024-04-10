#!/bin/bash

# Set source and destination paths
SOURCE_DIR="/path/to/source"
DESTINATION_DIR="remote@ip:/path/to/destination"

# Log file path
LOG_FILE="/path/to/sync_$(date +'%Y-%m-%d_%H-%M-%S').log"
TMP_LOG_FILE="/tmp/sync_tmp_$(date +'%Y-%m-%d_%H-%M-%S').log"

# Run rsync and log output
rsync -aogpvz -e "ssh -p 20202" --exclude='folder/to/skip/' "$SOURCE_DIR" "$DESTINATION_DIR" > "$TMP_LOG_FILE" 2>&1

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "Rsync completed successfully." >> "$TMP_LOG_FILE"
else
    echo "Rsync encountered an error." >> "$TMP_LOG_FILE"
fi

# Report moved files
echo "Moved files:" >> "$TMP_LOG_FILE"
grep -E '^[^\/]+\s+->\s+[^\/]+$' "$TMP_LOG_FILE" >> "$TMP_LOG_FILE"

# Append the temporary log file to the main log file
cat "$TMP_LOG_FILE" >> "$LOG_FILE"

# Remove the temporary log file
rm "$TMP_LOG_FILE"
