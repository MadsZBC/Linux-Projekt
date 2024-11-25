#!/bin/bash

# Source logging utilities
source "$(dirname "$0")/utils/logging.sh"

main() {
    start_log "Installing PHP"

    # Add PHP repository
    debug_log "Adding PHP repository"
    if ! apt-get install -y software-properties-common >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to install software-properties-common"
        exit 1
    fi

    # Install PHP and required extensions
    debug_log "Installing PHP and extensions"
    if ! apt-get install -y php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php-intl \
        php8.2-simplexml \
        php8.2-xml \
        php8.2-zip >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to install PHP packages"
        exit 1
    fi
    success_log "PHP packages installed"

    # Configure PHP
    debug_log "Configuring PHP"
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/8.2/fpm/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.2/fpm/php.ini
    success_log "PHP configured"

    # Restart PHP-FPM
    debug_log "Restarting PHP-FPM service"
    if ! systemctl restart php8.2-fpm >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to restart PHP-FPM"
        exit 1
    fi
    success_log "PHP-FPM service restarted"

    success_log "PHP installation completed"
}

main
