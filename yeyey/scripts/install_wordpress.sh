#!/bin/bash

# Source logging utilities
source "$(dirname "$0")/utils/logging.sh"

install_wp_cli() {
    debug_log "Checking for WP-CLI installation"
    if ! command -v wp &> /dev/null; then
        info_log "Installing WP-CLI..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >> "${INSTALL_LOG}" 2>&1
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        debug_log "WP-CLI installed successfully"
    else
        debug_log "WP-CLI already installed"
    fi
}

setup_wordpress_files() {
    debug_log "Setting up WordPress directory structure"
    
    # Create and enter web directory
    mkdir -p "/var/www/${DOMAIN}"
    cd "/var/www/${DOMAIN}" || exit 1
    
    # Download WordPress core
    if ! wp core download --allow-root >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to download WordPress core"
        return 1
    fi
    
    debug_log "WordPress core files downloaded successfully"
    return 0
}

configure_wordpress() {
    debug_log "Creating WordPress configuration"
    
    if ! wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASS}" \
        --dbhost="localhost" \
        --allow-root >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to create wp-config.php"
        return 1
    fi
    
    debug_log "WordPress configuration created successfully"
    return 0
}

install_wordpress() {
    debug_log "Installing WordPress"
    
    if ! wp core install \
        --url="http://${DOMAIN}" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to install WordPress"
        return 1
    fi
    
    # Configure permalinks
    debug_log "Configuring permalinks"
    wp rewrite structure '/%postname%/' --allow-root
    
    success_log "WordPress installed successfully"
    success_log "WordPress URL: http://${DOMAIN}"
    success_log "Admin URL: http://${DOMAIN}/wp-admin"
    return 0
}

set_permissions() {
    debug_log "Setting WordPress file permissions"
    
    chown -R www-data:www-data "/var/www/${DOMAIN}"
    find "/var/www/${DOMAIN}" -type d -exec chmod 755 {} \;
    find "/var/www/${DOMAIN}" -type f -exec chmod 644 {} \;
    
    debug_log "Permissions set successfully"
}

verify_php_extensions() {
    debug_log "Verifying PHP extensions"
    
    required_extensions=("mysqli" "imagick")
    
    for ext in "${required_extensions[@]}"; do
        if ! php -m | grep -q "^$ext$"; then
            error_log "Required PHP extension '$ext' is not installed"
            return 1
        fi
    done
    
    debug_log "All required PHP extensions are installed"
    return 0
}

main() {
    start_log "WordPress"
    
    install_wp_cli || exit 1
    setup_wordpress_files || exit 1
    configure_wordpress || exit 1
    install_wordpress || exit 1
    set_permissions || exit 1
    
    # ... rest of the installation process ...
}

main