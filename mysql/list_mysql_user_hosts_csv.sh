#!/bin/bash

# File to save the output
output_file="user_host_list.csv"

# Connect to MySQL and retrieve the list of users and hosts
mysql -u root -p -Bse "SELECT user, GROUP_CONCAT(host SEPARATOR ', ') AS hosts FROM mysql.user GROUP BY user;" > user_host_list.txt

# Print the header to the CSV file
echo "User,Host" > $output_file

# Read and write the user and host data to the CSV file
while IFS=$'\t' read -r user hosts; do
    # Escape double quotes in user and hosts
    user=$(echo "$user" | sed 's/"/""/g')
    hosts=$(echo "$hosts" | sed 's/"/""/g')
    # Write to the CSV file
    echo "\"$user\",\"$hosts\"" >> $output_file
done < user_host_list.txt

# Clean up
rm user_host_list.txt

echo "CSV output written to $output_file"

