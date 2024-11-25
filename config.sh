#!/bin/bash

# Debug mode (0=off, 1=on)
export DEBUG=1

# Database Configuration
export DB_NAME="wordpress"
export MYSQL_USER="wordpress_user"
export MYSQL_PASS="wordpress_pass"

# WordPress Configuration
export DOMAIN="example.com"
export WP_SITE_TITLE="My WordPress Site"
export WP_ADMIN_USER="admin"
export WP_ADMIN_PASS="admin_password"
export WP_ADMIN_EMAIL="admin@example.com"

# If a saved config exists, load it
CONFIG_FILE="./install_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi 