#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Get the script name for individual log files
SCRIPT_NAME=$(basename "${0%.*}")

# Get the root directory (where Installer.sh is located)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Create logs directory structure
LOGS_DIR="${ROOT_DIR}/logs"
mkdir -p "${LOGS_DIR}"

# Individual log files for each component
INSTALL_LOG="${LOGS_DIR}/${SCRIPT_NAME}.log"
MAIN_LOG="${LOGS_DIR}/installation.log"
ERROR_LOG="${LOGS_DIR}/error.log"
DEBUG_LOG="${LOGS_DIR}/debug.log"

# Create log files if they don't exist
touch "${MAIN_LOG}" "${ERROR_LOG}" "${DEBUG_LOG}"
touch "${INSTALL_LOG}"

# Logging functions
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to script-specific log
    echo "[${timestamp}] [${level}] ${message}" >> "${INSTALL_LOG}"
    
    # Also log to main installation log
    echo "[${timestamp}] [${SCRIPT_NAME}] [${level}] ${message}" >> "${MAIN_LOG}"
}

debug_log() {
    local message="$1"
    if [ "${DEBUG}" = "1" ]; then
        echo -e "${BLUE}[DEBUG] ${message}${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${SCRIPT_NAME}] [DEBUG] ${message}" >> "${DEBUG_LOG}"
    fi
    log_message "DEBUG" "${message}"
}

error_log() {
    local message="$1"
    echo -e "${RED}[ERROR] ${message}${NC}" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${SCRIPT_NAME}] [ERROR] ${message}" >> "${ERROR_LOG}"
    log_message "ERROR" "${message}"
}

info_log() {
    local message="$1"
    echo -e "${BOLD}[INFO] ${message}${NC}"
    log_message "INFO" "${message}"
}

success_log() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS] ${message}${NC}"
    log_message "SUCCESS" "${message}"
}

start_log() {
    local component="$1"
    echo -e "\n${YELLOW}=== Starting ${component} Installation ===${NC}"
    log_message "START" "Beginning ${component} installation"
}

# Function to show the current log file
show_current_log() {
    if [ -f "${INSTALL_LOG}" ]; then
        echo -e "\n${BOLD}Current log file (${INSTALL_LOG}):${NC}"
        tail -n 10 "${INSTALL_LOG}"
    fi
} 