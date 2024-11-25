#!/bin/bash

# Source logging utilities
source "$(dirname "$0")/utils/logging.sh"

# Create Nginx configuration
create_nginx_config() {
    debug_log "Creating Nginx configuration for ${DOMAIN}"
    
    local nginx_conf="/etc/nginx/sites-available/${DOMAIN}"
    cat > "$nginx_conf" << EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/${DOMAIN};
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    debug_log "Nginx configuration created at ${nginx_conf}"
}

# Main installation function
main() {
    start_log "Installing Nginx"

    # Install Nginx
    debug_log "Installing Nginx package"
    if ! apt-get install -y nginx >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to install Nginx"
        exit 1
    fi
    success_log "Nginx package installed"

    # Create site configuration
    create_nginx_config
    success_log "Nginx configuration created"

    # Enable site
    debug_log "Enabling Nginx site configuration"
    if ! ln -sf "/etc/nginx/sites-available/${DOMAIN}" "/etc/nginx/sites-enabled/${DOMAIN}"; then
        error_log "Failed to enable Nginx site"
        exit 1
    fi
    success_log "Nginx site enabled"

    # Test Nginx configuration
    debug_log "Testing Nginx configuration"
    if ! nginx -t >> "${INSTALL_LOG}" 2>&1; then
        error_log "Nginx configuration test failed"
        exit 1
    fi
    success_log "Nginx configuration test passed"

    # Restart Nginx
    debug_log "Restarting Nginx service"
    if ! systemctl restart nginx >> "${INSTALL_LOG}" 2>&1; then
        error_log "Failed to restart Nginx"
        exit 1
    fi
    success_log "Nginx service restarted"
    rm /etc/nginx/sites-enabled/default
    service nginx restart
    success_log "Nginx installation completed"
}

main