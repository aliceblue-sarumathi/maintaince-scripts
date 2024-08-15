#!/bin/bash

# File to save the output
output_file="user_grants.csv"

# Connect to MySQL and generate the list of SHOW GRANTS statements
mysql -u root -p -Bse "SELECT CONCAT(user, ',', host, ',SHOW GRANTS FOR ''', user, '''@''', host, ''';') FROM mysql.user;" > grants.sql

# Print the header to the CSV file
echo "User,Host,Grants" > $output_file

# Execute each SHOW GRANTS statement and format the output
while IFS=',' read -r user host show_grants_cmd; do
    # Get the grants for the user
    grants=$(mysql -u root -p -Bse "$show_grants_cmd")
    
    # Escape double quotes in grants and replace newlines with spaces
    grants=$(echo "$grants" | sed 's/"/""/g' | tr '\n' ' ')

    # Print the user, host, and grants in CSV format
    echo "\"$user\",\"$host\",\"$grants\"" >> $output_file
done < grants.sql

# Clean up
rm grants.sql

echo "CSV output written to $output_file"
