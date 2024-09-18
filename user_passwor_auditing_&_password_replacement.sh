#!/bin/bash

# Define servers with their respective SSH usernames, hostnames, SSH key paths, and custom SSH ports
declare -A SERVERS=(
  ["Testserver"]="root@192.168.40.95:/home/test/audit-bash/test:22"
)

# Get the current date and time to use in the output file name
CURRENT_DATE=$(date '+%Y-%m-%d_%H-%M-%S')

# Define output file for the password expiry details with date and time
OUTPUT_FILE="password_expiry_report_${CURRENT_DATE}.csv"

# Write the CSV header
echo "Server,Username,Last Password Change,Password Expires,Password Inactive,Account Expiration,Min Days Between Change,Max Days Between Change,Warn Days,New Password" > "$OUTPUT_FILE"

# Function to generate a random password with at least 12 characters
generate_random_password() {
  local length=12
  local password

  while :; do
    password=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*()_+[]{}|;:,.<>?~' | head -c $length)
    
    if [[ $password =~ [0-9] ]] && \
       [[ $password =~ [A-Z] ]] && \
       [[ $password =~ [a-z] ]] && \
       [[ $password =~ [[:punct:]] ]]; then
      echo "$password"
      return
    fi
  done
}

# Function to change password on a remote server
change_password() {
  local server="$1"
  local username="$2"
  local new_password="$3"
  local remote_user_host=$(echo "${SERVERS[$server]}" | cut -d: -f1)
  local ssh_key_path=$(echo "${SERVERS[$server]}" | cut -d: -f2)
  local ssh_port=$(echo "${SERVERS[$server]}" | cut -d: -f3)
  
  echo "Changing password for $username on $server..."
  ssh -i "$ssh_key_path" -p "$ssh_port" "$remote_user_host" "echo \"$username:$new_password\" | sudo chpasswd"
  
  # Check if the password change was successful
  if [ $? -ne 0 ]; then
    echo "Error: Password change for $username on $server failed!"
  fi
}

# Function to process each user and get their password details
process_users() {
  local server="$1"
  
  echo "Checking users on $server..."
  
  local remote_user_host=$(echo "${SERVERS[$server]}" | cut -d: -f1)
  local ssh_key_path=$(echo "${SERVERS[$server]}" | cut -d: -f2)
  local ssh_port=$(echo "${SERVERS[$server]}" | cut -d: -f3)
  
  local remote_command="awk -F: '(\$3 >= 1000) && (\$1 != \"nobody\") { print \$1 }' /etc/passwd"
  
  local users=$(ssh -i "$ssh_key_path" -p "$ssh_port" "$remote_user_host" "$remote_command")
  
  if [ $? -ne 0 ]; then
    echo "Error: Unable to fetch users from $server."
    return
  fi
  
  for user in $users; do
    local password_info=$(ssh -i "$ssh_key_path" -p "$ssh_port" "$remote_user_host" "sudo chage -l $user")
    
    if [ $? -ne 0 ]; then
      echo "Error: Failed to fetch password info for $user on $server."
      continue
    fi

    local last_password_change=$(echo "$password_info" | grep 'Last password change' | cut -d: -f2 | xargs)
    local password_expiry=$(echo "$password_info" | grep 'Password expires' | cut -d: -f2 | xargs)
    local password_inactive=$(echo "$password_info" | grep 'Password inactive' | cut -d: -f2 | xargs)
    local account_expiration=$(echo "$password_info" | grep 'Account expires' | cut -d: -f2 | xargs)
    local min_days_change=$(echo "$password_info" | grep 'Minimum number of days between password change' | cut -d: -f2 | xargs)
    local max_days_change=$(echo "$password_info" | grep 'Maximum number of days between password change' | cut -d: -f2 | xargs)
    local warn_days=$(echo "$password_info" | grep 'Number of days of warning before password expires' | cut -d: -f2 | xargs)
    
    last_password_change=$(date -d "$last_password_change" '+%b %d %Y' 2>/dev/null || echo "never")
    password_expiry=$(date -d "$password_expiry" '+%b %d %Y' 2>/dev/null || echo "never")
    password_inactive=$(date -d "$password_inactive" '+%b %d %Y' 2>/dev/null || echo "Sep 17 2024")
    account_expiration=$(date -d "$account_expiration" '+%b %d %Y' 2>/dev/null || echo "never")
    
    # Generate a new random password
    local new_password=$(generate_random_password)
    echo "Generated password for $user: $new_password"
    
    # Save user details and password into CSV
    echo "$server,$user,$last_password_change,$password_expiry,$password_inactive,$account_expiration,$min_days_change,$max_days_change,$warn_days,$new_password" >> "$OUTPUT_FILE"
    
    # Change the user's password
    change_password "$server" "$user" "$new_password"
  done
}

# Main script logic
for server in "${!SERVERS[@]}"; do
  process_users "$server"
done

echo "Password details saved to $OUTPUT_FILE"
