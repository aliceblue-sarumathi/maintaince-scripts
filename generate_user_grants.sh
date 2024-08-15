#!/bin/bash

# Connect to MySQL and generate the list of SHOW GRANTS statements
mysql -u root -p -Bse "SELECT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') FROM mysql.user;" > grants.sql

# Execute each SHOW GRANTS statement and format the output
while IFS= read -r line; do
    echo "----------------------------------------"
    echo "Executing: $line"
    echo "----------------------------------------"
    mysql -u root -p -Bse "$line"
    echo
done < grants.sql

# Clean up
rm grants.sql
