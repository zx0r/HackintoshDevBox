#!/bin/bash

# NOTE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#      __ __         __    _      __           __     __
#     / // /__  ____/ /__ (_)__  / / ___  ___ / /    / /  ___  ___ ____
#    / _  / _ `/ __/  '_// / _ \/ __/ _ \(_-</ _ \  / /__/ _ \/ _ `(_-<
#   /_//_/\_,_/\__/_/\_\/_/_//_/\__/\___/___/_//_/ /____/\___/\_, /___/
#   Copyright (c) 2024 for the Hackintosh community          /___/
#
#  Author       : zx0r
#  License      : MIT License
#  Description  : Stay hungry; Stay foolish
#  Contact Info : https://github.com/zx0r

# ━━━ Dump Logs ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Script:  Hardware Information Script
# A script to display detailed hardware information

# 1. Interactive menu mode (recommended for first use):
#   ./hardware_info.sh
#
# 2. Direct commands for specific hardware info:
#   - CPU info: ./hardware_info.sh -c
#   - Memory info: ./hardware_info.sh -m
#   - GPU info: ./hardware_info.sh -g
#   - Storage info: ./hardware_info.sh -s
#   - Network info: ./hardware_info.sh -n
#   - System info: ./hardware_info.sh -b
#   - USB devices: ./hardware_info.sh -u
#   - PCI devices: ./hardware_info.sh -p
#   - Full system report: ./hardware_info.sh -f
#
# 3. Show help menu:
#   ./hardware_info.sh -h
#
# The script will display colored, formatted output for better readability.


# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
set -e
trap 'echo -e "${RED}An error occurred. Exiting...${NC}"; exit 1' ERR

# Function to check if required commands exist
check_commands() {
    local missing_commands=()
    for cmd in system_profiler diskutil ioreg; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        echo -e "${RED}Error: Required commands not found: ${missing_commands[*]}${NC}"
        exit 1
    fi
}

# Function to check CPU information
check_cpu() {
    echo -e "\n${BLUE}=== CPU Information ===${NC}"
    system_profiler SPHardwareDataType | grep -A 5 "Processor"
    echo -e "\n${GREEN}Additional CPU Details:${NC}"
    sysctl -n machdep.cpu.brand_string
}

# Function to check memory information
check_memory() {
    echo -e "\n${BLUE}=== Memory Information ===${NC}"
    system_profiler SPMemoryDataType
}

# Function to check GPU information
check_gpu() {
    echo -e "\n${BLUE}=== GPU Information ===${NC}"
    system_profiler SPDisplaysDataType
}

# Function to check storage information
check_storage() {
    echo -e "\n${BLUE}=== Storage Information ===${NC}"
    echo -e "${GREEN}Disk List:${NC}"
    diskutil list
    
    echo -e "\n${GREEN}Storage Details:${NC}"
    system_profiler SPNVMeDataType SPSerialATADataType
}

# Function to check network information
check_network() {
    echo -e "\n${BLUE}=== Network Information ===${NC}"
    system_profiler SPNetworkDataType
}

# Function to check motherboard/system information
check_system() {
    echo -e "\n${BLUE}=== System Information ===${NC}"
    system_profiler SPHardwareDataType
}

# Function to check USB devices
check_usb() {
    echo -e "\n${BLUE}=== USB Devices ===${NC}"
    system_profiler SPUSBDataType
}

# Function to check PCI devices
check_pci() {
    echo -e "\n${BLUE}=== PCI Devices ===${NC}"
    system_profiler SPPCIDataType
    echo -e "\n${GREEN}Additional PCI Details:${NC}"
    ioreg -l | grep -i PCI
}

# Function to generate full system report
full_system_report() {
    echo -e "${YELLOW}Generating full system report...${NC}"
    check_system
    check_cpu
    check_memory
    check_gpu
    check_storage
    check_network
    check_usb
    check_pci
}

# Function to display help
show_help() {
    echo -e "${GREEN}Hardware Information Script${NC}"
    echo -e "Usage: $0 [OPTION]"
    echo -e "\nOptions:"
    echo -e "  -h, --help     Display this help message"
    echo -e "  -c, --cpu      Check CPU information"
    echo -e "  -m, --memory   Check memory information"
    echo -e "  -g, --gpu      Check GPU information"
    echo -e "  -s, --storage  Check storage information"
    echo -e "  -n, --network  Check network information"
    echo -e "  -b, --system   Check system/motherboard information"
    echo -e "  -u, --usb      Check USB devices"
    echo -e "  -p, --pci      Check PCI devices"
    echo -e "  -f, --full     Generate full system report"
}

# Main menu function
show_menu() {
    echo -e "${GREEN}Hardware Information Menu${NC}"
    echo "1) CPU Information"
    echo "2) Memory Information"
    echo "3) GPU Information"
    echo "4) Storage Information"
    echo "5) Network Information"
    echo "6) System Information"
    echo "7) USB Devices"
    echo "8) PCI Devices"
    echo "9) Full System Report"
    echo "0) Exit"
    echo "h) Help"
}

# Main script execution
if [ $# -eq 0 ]; then
    while true; do
        echo
        show_menu
        read -p "Select an option: " choice
        case $choice in
            1) check_cpu ;;
            2) check_memory ;;
            3) check_gpu ;;
            4) check_storage ;;
            5) check_network ;;
            6) check_system ;;
            7) check_usb ;;
            8) check_pci ;;
            9) full_system_report ;;
            0) exit 0 ;;
            h|H) show_help ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
else
    case "$1" in
        -h|--help) show_help ;;
        -c|--cpu) check_cpu ;;
        -m|--memory) check_memory ;;
        -g|--gpu) check_gpu ;;
        -s|--storage) check_storage ;;
        -n|--network) check_network ;;
        -b|--system) check_system ;;
        -u|--usb) check_usb ;;
        -p|--pci) check_pci ;;
        -f|--full) full_system_report ;;
        *) echo -e "${RED}Invalid option${NC}"; show_help ;;
    esac
fi

