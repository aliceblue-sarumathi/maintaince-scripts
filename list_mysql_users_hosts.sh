#!/bin/bash

# File to save the output
output_file="user_host_list.txt"

# Connect to MySQL and retrieve the list of users and hosts
mysql -u root -p -Bse "SELECT user, GROUP_CONCAT(host SEPARATOR ', ') as hosts FROM mysql.user GROUP BY user;" > $output_file

# Determine the maximum length of the user and host fields for formatting
max_user_length=$(awk -F'\t' '{ if (length($1) > max) max = length($1) } END { print max }' $output_file)
max_host_length=$(awk -F'\t' '{ if (length($2) > max) max = length($2) } END { print max }' $output_file)

# Print the header with appropriate padding
printf "| %-*s | %-*s |\n" $max_user_length "User" $max_host_length "Host"
printf "|-%-*s-|-%-*s-|\n" $max_user_length $(head -c $max_user_length < /dev/zero | tr '\0' '-') $max_host_length $(head -c $max_host_length < /dev/zero | tr '\0' '-')

# Read and print the user and host data with appropriate padding
while IFS=$'\t' read -r user hosts; do
    printf "| %-*s | %-*s |\n" $max_user_length "$user" $max_host_length "$hosts"
done < $output_file

# Clean up
rm $output_file
