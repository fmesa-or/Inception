#!/bin/sh
set -e

# BASIC FOR MARIADB

# If this directory doesn't exist, create Database directory
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB server in the background
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

# Wait until MariaDB is ready to accept connections
for i in $(seq 30); do
	if mysqladmin ping -u root --silent; then
		break
	fi
	sleep 1
done

# Configure database and user for wordpress
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASS}';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${SQL_USER}'@'%';"

# Set password for root user
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

# Refresh privileges to ensure all changes take effect
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Shutdown the temporary MariaDB server to restart it properly later
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Wait just in case (although shutdown usually waits)
wait "$pid"

# Launch the final server as main process
exec mysqld --user=mysql --datadir=/var/lib/mysql