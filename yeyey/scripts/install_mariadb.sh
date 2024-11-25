#!/bin/bash

# Source logging utilities
source "$(dirname "$0")/utils/logging.sh"

create_database() {
    debug_log "Creating database: ${DB_NAME}"
    
    # Create a temporary SQL file
    local sqlfile="/tmp/wp_db_setup.sql"
    cat > "$sqlfile" << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

    debug_log "Executing SQL setup..."
    if ! mysql -u root < "$sqlfile" 2>> "${INSTALL_LOG}"; then
        error_log "MySQL command failed. Check the logs for details."
        cat "$sqlfile" >> "${INSTALL_LOG}"
        return 1
    fi

    # Verify database exists
    if ! mysql -u root -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep -q "${DB_NAME}"; then
        error_log "Database ${DB_NAME} was not created"
        return 1
    fi

    # Verify user exists
    if ! mysql -u root -e "SELECT User FROM mysql.user WHERE User='${MYSQL_USER}';" | grep -q "${MYSQL_USER}"; then
        error_log "User ${MYSQL_USER} was not created"
        return 1
    fi

    # Test user access
    if ! mysql -u "${MYSQL_USER}" -p"${MYSQL_PASS}" -e "USE ${DB_NAME};" 2>> "${INSTALL_LOG}"; then
        error_log "Unable to access database with new user credentials"
        return 1
    fi

    success_log "Database and user created successfully"
    return 0
}

main() {
    start_log "Installing MariaDB"

    # Check if MariaDB is already installed
    if systemctl is-active --quiet mariadb; then
        debug_log "MariaDB is already installed and running"
    else
        debug_log "Installing MariaDB packages"
        if ! DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server >> "${INSTALL_LOG}" 2>&1; then
            error_log "Failed to install MariaDB"
            exit 1
        fi
        success_log "MariaDB packages installed"

        # Start MariaDB service
        debug_log "Starting MariaDB service"
        if ! systemctl start mariadb >> "${INSTALL_LOG}" 2>&1; then
            error_log "Failed to start MariaDB service"
            exit 1
        fi
    fi

    # Wait for MariaDB to be ready
    debug_log "Waiting for MariaDB to be ready..."
    for i in {1..30}; do
        if mysql -u root -e "SELECT 1;" &>/dev/null; then
            break
        fi
        sleep 1
        if [ $i -eq 30 ]; then
            error_log "MariaDB did not become ready in time"
            exit 1
        fi
    done

    # Verify variables
    if [ -z "$DB_NAME" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASS" ]; then
        error_log "Required database variables are not set"
        debug_log "DB_NAME=${DB_NAME:-<not set>}"
        debug_log "MYSQL_USER=${MYSQL_USER:-<not set>}"
        debug_log "MYSQL_PASS=<hidden>"
        exit 1
    fi

    # Create database and user
    if ! create_database; then
        error_log "Database setup failed"
        exit 1
    fi

    success_log "MariaDB installation and setup completed successfully"
}

main



