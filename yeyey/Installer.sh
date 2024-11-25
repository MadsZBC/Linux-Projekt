#!/bin/bash

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source logging utilities
source "${SCRIPT_DIR}/scripts/utils/logging.sh"

# Source configuration
source "${SCRIPT_DIR}/config.sh"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error_log "Please run as root (use sudo)"
    exit 1
fi

# Function to save configuration
save_configuration() {
    cat > "${SCRIPT_DIR}/install_config" << EOF
export DB_NAME="${DB_NAME}"
export MYSQL_USER="${MYSQL_USER}"
export MYSQL_PASS="${MYSQL_PASS}"
export DOMAIN="${DOMAIN}"
export WP_SITE_TITLE="${WP_SITE_TITLE}"
export WP_ADMIN_USER="${WP_ADMIN_USER}"
export WP_ADMIN_PASS="${WP_ADMIN_PASS}"
export WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"
export DEBUG="${DEBUG}"
EOF
    chmod 600 "${SCRIPT_DIR}/install_config"
}

# Configuration menu
configure_settings() {
    echo -e "\n${BOLD}Configure Installation Settings${NC}"
    echo "----------------------------------------"
    
    # Domain configuration
    read -p "Enter Domain Name (e.g., example.com) [${DOMAIN}]: " input
    if [ ! -z "$input" ]; then
        # Remove http:// or https:// if present
        input=$(echo "$input" | sed 's#^https\?://##')
        # Remove trailing slash if present
        input=$(echo "$input" | sed 's#/$##')
        DOMAIN=$input
    fi
    
    # Site title configuration
    read -p "Enter Site Title [${WP_SITE_TITLE}]: " input
    WP_SITE_TITLE=${input:-$WP_SITE_TITLE}
    
    # Database configuration
    read -p "Enter Database Name [${DB_NAME}]: " input
    DB_NAME=${input:-$DB_NAME}
    
    read -p "Enter MySQL Username [${MYSQL_USER}]: " input
    MYSQL_USER=${input:-$MYSQL_USER}
    
    read -s -p "Enter MySQL Password: " input
    echo
    MYSQL_PASS=${input:-$MYSQL_PASS}
    
    # WordPress admin configuration
    read -p "Enter WordPress Admin Username [${WP_ADMIN_USER}]: " input
    WP_ADMIN_USER=${input:-$WP_ADMIN_USER}
    
    read -s -p "Enter WordPress Admin Password: " input
    echo
    WP_ADMIN_PASS=${input:-$WP_ADMIN_PASS}
    
    read -p "Enter WordPress Admin Email [${WP_ADMIN_EMAIL}]: " input
    WP_ADMIN_EMAIL=${input:-$WP_ADMIN_EMAIL}
    
    # Save all configuration
    save_configuration
    success_log "Configuration saved"
}

# Function to run installation scripts
run_installation() {
    info_log "Starting installation process"
    
    # Export all variables
    export DB_NAME MYSQL_USER MYSQL_PASS DOMAIN WP_ADMIN_USER WP_ADMIN_PASS WP_ADMIN_EMAIL DEBUG
    
    # Run installations in order
    bash "${SCRIPT_DIR}/scripts/install_mariadb.sh" || { error_log "MariaDB installation failed"; exit 1; }
    bash "${SCRIPT_DIR}/scripts/install_php.sh" || { error_log "PHP installation failed"; exit 1; }
    bash "${SCRIPT_DIR}/scripts/install_nginx.sh" || { error_log "Nginx installation failed"; exit 1; }
    bash "${SCRIPT_DIR}/scripts/install_wordpress.sh" || { error_log "WordPress installation failed"; exit 1; }
    
    success_log "Installation completed successfully"
}

# Show current configuration
show_configuration() {
    echo -e "\n${BOLD}Current Configuration${NC}"
    echo "----------------------------------------"
    echo -e "Domain Name: ${BLUE}${DOMAIN}${NC}"
    echo -e "Site Title: ${BLUE}${WP_SITE_TITLE}${NC}"
    echo -e "Database Name: ${BLUE}${DB_NAME}${NC}"
    echo -e "MySQL Username: ${BLUE}${MYSQL_USER}${NC}"
    echo -e "MySQL Password: ${BLUE}[HIDDEN]${NC}"
    echo -e "WordPress Admin: ${BLUE}${WP_ADMIN_USER}${NC}"
    echo -e "WordPress Admin Password: ${BLUE}[HIDDEN]${NC}"
    echo -e "WordPress Admin Email: ${BLUE}${WP_ADMIN_EMAIL}${NC}"
    echo -e "Debug Mode: ${BLUE}${DEBUG}${NC}"
    echo "----------------------------------------"
    
    read -p "Press Enter to continue..."
}

# Show logs
show_logs() {
    while true; do
        echo -e "\n${BOLD}Installation Logs${NC}"
        echo "----------------------------------------"
        echo "1) View main installation log"
        echo "2) View MariaDB installation log"
        echo "3) View Nginx installation log"
        echo "4) View WordPress installation log"
        echo "5) View error log"
        echo "6) View debug log"
        echo "7) Back to main menu"
        echo "----------------------------------------"
        
        read -p "Choose an option [1-7]: " log_choice
        
        case $log_choice in
            1) less "${SCRIPT_DIR}/logs/installation.log" ;;
            2) less "${SCRIPT_DIR}/logs/install_mariadb.log" ;;
            3) less "${SCRIPT_DIR}/logs/install_nginx.log" ;;
            4) less "${SCRIPT_DIR}/logs/install_wordpress.log" ;;
            5) less "${SCRIPT_DIR}/logs/error.log" ;;
            6) less "${SCRIPT_DIR}/logs/debug.log" ;;
            7) return ;;
            *) error_log "Invalid option" ;;
        esac
    done
}

# Function to check logs directory
check_logs_directory() {
    if [ ! -d "${SCRIPT_DIR}/logs" ]; then
        mkdir -p "${SCRIPT_DIR}/logs"
        info_log "Created logs directory at ${SCRIPT_DIR}/logs"
    fi
}

# Initialize logging
check_logs_directory

# Progress bar function
progress_bar() {
    local duration=$1
    local width=50
    local progress=0
    local fill
    local empty
    
    while [ $progress -le 100 ]; do
        let fill=($progress*$width/100)
        let empty=($width-$fill)
        printf "\r[${BLUE}"
        printf "%-${fill}s" '' | tr ' ' '='
        printf "${NC}"
        printf "%-${empty}s" '' | tr ' ' '-'
        printf "] ${BOLD}$progress%%${NC}"
        progress=$((progress + 2))
        sleep $duration
    done
    echo
}

# Function to show step progress
show_step() {
    local message="$1"
    echo -e "\n${BOLD}${BLUE}➜ ${message}${NC}"
}

# Function to toggle debug mode
toggle_debug() {
    if [ "$DEBUG" = "1" ]; then
        DEBUG=0
        echo -e "${GREEN}Debug mode disabled${NC}"
    else
        DEBUG=1
        echo -e "${GREEN}Debug mode enabled${NC}"
    fi
    # Update config file with new debug setting
    sed -i "s/DEBUG=./DEBUG=$DEBUG/" "${SCRIPT_DIR}/config.sh"
    export DEBUG
}

# Updated main menu
while true; do
    echo -e "\n${BOLD}WordPress Installer${NC}"
    echo "----------------------------------------"
    echo "1) Configure Installation Settings"
    echo "2) Start Installation"
    echo "3) View Current Configuration"
    echo "4) View Logs"
    echo "5) Toggle Debug Mode (currently: ${DEBUG:-0})"
    echo "6) Exit"
    echo "----------------------------------------"
    
    read -p "Choose an option [1-6]: " CHOICE
    
    case $CHOICE in
        1) configure_settings ;;
        2) run_installation ;;
        3) show_configuration ;;
        4) show_logs ;;
        5) toggle_debug ;;
        6) 
            echo -e "\n${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *) error_log "Invalid option" ;;
    esac
done
