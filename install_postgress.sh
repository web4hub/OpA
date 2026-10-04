#!/bin/sh

# Get database name from user
read -p "Enter database name: " dbname

# Prompt user for the password for the default PostgreSQL user (postgres)
read -s -p "Enter password for the default PostgreSQL user (postgres): " password
echo

# Update package lists
apt update

# Install PostgreSQL
apt install -y postgresql

# PostgreSQL should be automatically started after installation, but let's ensure it's running
systemctl start postgresql

# Enable PostgreSQL to start on boot
systemctl enable postgresql

# Check the status of PostgreSQL
systemctl status postgresql

echo "Creating a postgres user with 'postgres' as the username"

sudo -u postgres createuser -s postgres

# Set password for the postgres user
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$password';"

# Create a database
sudo -u postgres createdb $dbname

# Making database open to all connections
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/14/main/postgresql.conf

# Allowing all local connections
sudo sh -c "echo 'host    all             all             192.168.50.0/24         trust' >> /etc/postgresql/14/main/pg_hba.conf"

sudo systemctl restart postgresql

echo "Postgres installed"
