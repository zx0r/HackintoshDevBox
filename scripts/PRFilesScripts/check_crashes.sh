#!/bin/bash

# Crash Log Checker for macOS
# MIT License
# Copyright (c) 2024
# A tool to check and analyze crash logs and kernel panics

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
HOURS=24

# Main directories for crash logs
SYSTEM_LOGS="/Library/Logs/DiagnosticReports"
USER_LOGS="$HOME/Library/Logs/DiagnosticReports"

# Function to print error messages
error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

# Function to print success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print info messages
info() {
    echo -e "${BLUE}$1${NC}"
}

# Function to print warnings
warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to check if directories exist
check_directories() {
    local missing=0
    if [ ! -d "$SYSTEM_LOGS" ]; then
        error "System logs directory not found: $SYSTEM_LOGS"
        missing=1
    fi
    if [ ! -d "$USER_LOGS" ]; then
        error "User logs directory not found: $USER_LOGS"
        missing=1
    fi
    [ $missing -eq 1 ] && exit 1
}

# Function to list recent crashes
list_recent_crashes() {
    local hours=${1:-$HOURS}
    info "Checking for crashes in the last $hours hours..."
    
    # Find files modified in the last $hours hours
    find "$SYSTEM_LOGS" "$USER_LOGS" -type f -mtime -$((hours/24)) \
        \( -name "*.crash" -o -name "*.ips" -o -name "*.panic" \) 2>/dev/null | \
    while read -r file; do
        printf "${GREEN}%s${NC}: %s\n" "$(basename "$file")" "$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")"
    done
}

# Function to show kernel panics
show_kernel_panics() {
    info "Checking for kernel panics..."
    find "$SYSTEM_LOGS" "$USER_LOGS" -type f -name "*.panic" 2>/dev/null | \
    while read -r file; do
        printf "${RED}%s${NC}: %s\n" "$(basename "$file")" "$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")"
    done
}

# Function to view crash log details
view_crash_log() {
    local log_file="$1"
    if [ -f "$log_file" ]; then
        less "$log_file"
    else
        # Try to find the file in both directories
        local found_file
        found_file=$(find "$SYSTEM_LOGS" "$USER_LOGS" -type f -name "$log_file"* 2>/dev/null | head -n 1)
        if [ -n "$found_file" ]; then
            less "$found_file"
        else
            error "Crash log not found: $log_file"
            return 1
        fi
    fi
}

# Function to show usage
show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Options:
-h, --help           Show this help message
-l, --list [hours]   List crashes from the last N hours (default: 24)
-k, --kernel         Show only kernel panics
-v, --view <file>    View details of a specific crash log

Examples:
$(basename "$0") -l 48        # List crashes from the last 48 hours
$(basename "$0") -k           # Show kernel panics
$(basename "$0") -v crash.log # View specific crash log
EOF
}

# Main script
main() {
    check_directories

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--list)
                if [[ $2 =~ ^[0-9]+$ ]]; then
                    HOURS=$2
                    shift
                fi
                list_recent_crashes "$HOURS"
                ;;
            -k|--kernel)
                show_kernel_panics
                ;;
            -v|--view)
                if [ -z "$2" ]; then
                    error "Please specify a crash log file"
                    exit 1
                fi
                view_crash_log "$2"
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    # If no arguments provided, show help
    if [ $# -eq 0 ]; then
        show_help
    fi
}

# Run main function
main "$@"

