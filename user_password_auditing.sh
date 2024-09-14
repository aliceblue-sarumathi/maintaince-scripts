#!/bin/bash

# Define servers with their respective SSH usernames, hostnames, SSH key paths, and custom SSH ports
declare -A SERVERS=(
  ["Testserver"]="root@192.168.40.95:/home/test/audit-bash/test:22"
  ["EKYC_BCP"]="nallen@14.141.117.141:/home/test/audit-bash/ekycp:20202"
)

# Define output file for the password expiry details
OUTPUT_FILE="password_expiry_report.csv"

# Initialize output file with headers
echo "Server,Username,Last Password Change,Password Expires,Password Inactive,Account Expires,Min Days Between Change,Max Days Between Change,Days Warning Before Expiry" > "$OUTPUT_FILE"

# Loop over the servers and fetch the password details
for SERVER in "${!SERVERS[@]}"; do
  echo "Checking users on $SERVER..."

  # Parse the remote SSH user, host, key path, and port
  REMOTE_USER_HOST=$(echo "${SERVERS[$SERVER]}" | cut -d: -f1)
  SSH_KEY_PATH=$(echo "${SERVERS[$SERVER]}" | cut -d: -f2)
  SSH_PORT=$(echo "${SERVERS[$SERVER]}" | cut -d: -f3)

  # Command to fetch usernames with UID >= 1000 excluding 'nobody'
  REMOTE_COMMAND="awk -F: '(\$3 >= 1000) && (\$1 != \"nobody\") { print \$1 }' /etc/passwd"

  # Fetch the list of users with UID >= 1000 (excluding nobody)
  USERS=$(ssh -i "$SSH_KEY_PATH" -p "$SSH_PORT" "$REMOTE_USER_HOST" "$REMOTE_COMMAND")

  # Loop through each user and get the detailed password information
  for USER in $USERS; do
    # Fetch detailed password expiry info using chage command
    PASSWORD_INFO=$(ssh -i "$SSH_KEY_PATH" -p "$SSH_PORT" "$REMOTE_USER_HOST" "sudo chage -l $USER")

    # Extract necessary details from the output
    LAST_PASSWORD_CHANGE=$(echo "$PASSWORD_INFO" | grep 'Last password change' | cut -d: -f2 | xargs)
    PASSWORD_EXPIRY=$(echo "$PASSWORD_INFO" | grep 'Password expires' | cut -d: -f2 | xargs)
    PASSWORD_INACTIVE=$(echo "$PASSWORD_INFO" | grep 'Password inactive' | cut -d: -f2 | xargs)
    ACCOUNT_EXPIRATION=$(echo "$PASSWORD_INFO" | grep 'Account expires' | cut -d: -f2 | xargs)
    MIN_DAYS_CHANGE=$(echo "$PASSWORD_INFO" | grep 'Minimum number of days between password change' | cut -d: -f2 | xargs)
    MAX_DAYS_CHANGE=$(echo "$PASSWORD_INFO" | grep 'Maximum number of days between password change' | cut -d: -f2 | xargs)
    WARN_DAYS=$(echo "$PASSWORD_INFO" | grep 'Number of days of warning before password expires' | cut -d: -f2 | xargs)

    # Ensure date fields are formatted as 'MMM DD YYYY' (e.g., 'Jul 17 2024')
    LAST_PASSWORD_CHANGE=$(date -d "$LAST_PASSWORD_CHANGE" '+%b %d %Y' 2>/dev/null || echo "never")
    PASSWORD_EXPIRY=$(date -d "$PASSWORD_EXPIRY" '+%b %d %Y' 2>/dev/null || echo "never")
    PASSWORD_INACTIVE=$(date -d "$PASSWORD_INACTIVE" '+%b %d %Y' 2>/dev/null || echo "never")
    ACCOUNT_EXPIRATION=$(date -d "$ACCOUNT_EXPIRATION" '+%b %d %Y' 2>/dev/null || echo "never")

    # Append the details to the output file, including the server name
    echo "$SERVER,$USER,$LAST_PASSWORD_CHANGE,$PASSWORD_EXPIRY,$PASSWORD_INACTIVE,$ACCOUNT_EXPIRATION,$MIN_DAYS_CHANGE,$MAX_DAYS_CHANGE,$WARN_DAYS" >> "$OUTPUT_FILE"
  done
done

echo "Password details saved to $OUTPUT_FILE"