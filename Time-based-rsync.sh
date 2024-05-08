#!/bin/bash
SOURCE_DIR="/Data/files"
DESTINATION_DIR="ekyc@125.20.29.228:/Temp"

# Define start and end times in the format "YYYY-MM-DD HH:MM:SS"
START_TIME="2024-05-07 09:00:00"
END_TIME="2024-07-08 17:00:00"

# Find files created, modified, or deleted between the specified time range
FILES_TO_TRANSFER=$(sudo find "$SOURCE_DIR/" -type f -newermt "$START_TIME" ! -newermt "$END_TIME")

# Debugging: Print files to transfer
echo "Files to transfer:"
printf '%s\n' "$FILES_TO_TRANSFER"

# Transfer files using rsync
echo "starting to Transfer the files"

# Loop over files to transfer, handling spaces correctly
while IFS= read -r file; do
    # Check if the file is within the excluded directory
        rsync -avz -e "ssh -p 20202" "$file" "$DESTINATION_DIR"
done <<< "$FILES_TO_TRANSFER"
