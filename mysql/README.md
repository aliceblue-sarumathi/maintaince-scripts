# MySQL User and Host Scripts

This repository contains two scripts for listing MySQL users and their hosts, with different output formats:

1. `list_mysql_user_hosts.sh` - Outputs user and host information in a tabular format.
2. `list_mysql_user_hosts_csv.sh` - Outputs user and host information in CSV format.

## Prerequisites

- MySQL client must be installed on your system.
- You need MySQL root access or sufficient privileges to query the `mysql.user` table.
- You need to provide the MySQL root password when running the scripts.

## Script Descriptions

### `list_mysql_user_hosts.sh`

This script retrieves a list of MySQL users and their hosts and prints the information in a tabular format.

#### Usage

1. Save the script to a file, e.g., `list_mysql_user_hosts.sh`.
2. Make the script executable:
    ```sh
    chmod +x list_mysql_user_hosts.sh
    ```
3. Run the script:
    ```sh
    ./list_mysql_user_hosts.sh
    ```
4. Enter the MySQL root password when prompted.

#### Output

The script will print the user and host information in a tabular format:

