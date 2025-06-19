#!/bin/bash

# NOTE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#      __ __         __    _      __           __     __
#     / // /__  ____/ /__ (_)__  / / ___  ___ / /    / /  ___  ___ ____
#    / _  / _ `/ __/  '_// / _ \/ __/ _ \(_-</ _ \  / /__/ _ \/ _ `(_-<
#   /_//_/\_,_/\__/_/\_\/_/_//_/\__/\___/___/_//_/ /____/\___/\_, /___/
#   Copyright (c) 2024 for the Hackintosh community          /___/
#
#  Author       : zx0r
#  License      : MIT License
#  Contact Info : https://github.com/zx0r
#  Description  : Stay Hungry, Stay Foolish" - Steve Jobs

# ━━━ Dump Logs ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Script: hackintosh-logs.sh
# Purpose: Creates a directory structure for organizing Hackintosh log files
# The script creates a main directory and subdirectories for different types of logs
# including system logs, boot logs, kernel logs, and crash reports
# Change if you USE SATA drives > # Collect trim status and settings

#system_profiler \
#SPHardwareDataType \
#SPProcessorDataType \
#SPDisplaysDataType \
#SPNVMeDataType \
#SPSerialATADataType \
#SPNetworkDataType \
#SPMemoryDataType \
#SPUSBDataType \
#SPPCIDataType \
#-detailLevel basic

# Exit on any error
set -e

#username='x0r'

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root or with sudo${NC}"
  exit 1
fi

# Banner function
print_banner() {
  local text="$1"
  local padding="$(printf '%*s' 50)"
  local border="${MAGENTA}═══════════════════════════════════════════════════════════════════════${NC}"

  echo -e "${border}"
  echo -e "${CYAN}   __ __         __    _      __           __     __${NC}"
  echo -e "${CYAN}  / // /__  ____/ /__ (_)__  / / ___  ___ / /    / /  ___  ___ ____${NC}"
  echo -e "${CYAN} / _  / _  / __/  '_// / _ \/ __/ _ \(_-</ _ \  / /__/ _ \/ _  (_-<${NC}"
  echo -e "${CYAN}/_//_/\_,_/\__/_/\_\/_/_//_/\__/\___/___/_//_/ /____/\___/\_, /___/${NC}"
  echo -e "${CYAN}Copyright (c) 2024 for the Hackintosh community          /___/${NC}"
  echo -e "${WHITE}${text}${NC}"
  echo -e "\n${CYAN}  Author       : zx0r${NC}"
  echo -e "${CYAN}  License      : MIT License${NC}"
  echo -e "${CYAN}  Contact Info : https://github.com/zx0r${NC}"
  echo -e "${CYAN}  Description  : \"Stay Hungry, Stay Foolish\" - Steve Jobs  ${NC}"
  echo -e "\n${MAGENTA}                      Think Different                     ${NC}"
  echo -e "${MAGENTA}  ▸ Stay Hungry: Never be satisfied with what you know    ${NC}"
  echo -e "${MAGENTA}  ▸ Stay Foolish: Never be afraid to take risks           ${NC}"
  echo -e "${MAGENTA}  ▸ Stay Creative: Innovation distinguishes leaders       ${NC}"
  echo -e "${MAGENTA}  ▸ Stay Passionate: Love what you do                     ${NC}"
  echo -e "${MAGENTA}                                                          ${NC}"
  echo -e "${MAGENTA}   \"Your time is limited, don't waste it living someone else's life.\"   ${NC}"
  echo -e "${border}"
  echo -e "${WHITE}${text}${NC}"

}
print_banner

# Function to get and validate username
get_username() {
  while true; do
    echo -e "${BLUE}╔═════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                         User Configuration                          ║${NC}"
    echo -e "${BLUE}╚═════════════════════════════════════════════════════════════════════╝${NC}"

    # Ask for username
    read -p $'\033[0;36mPlease enter your username: \033[0m' username

    # Check if input is empty
    if [[ -z "$username" ]]; then
      echo -e "${RED}Username cannot be empty. Please try again.${NC}"
      continue
    fi

    # Confirm the username
    echo -e "${GREEN}Username set to: ${CYAN}$username${NC}"

    # Ask for confirmation
    read -p $'\033[0;36mIs this correct? (y/n): \033[0m' confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      break
    fi
  done

  # Export the username variable
  export username
}

# Run the function
get_username

# Define main directory name
MAIN_DIR="${username}-PRFiles"

# Create main directory if it doesn't exist
if [ ! -d "$MAIN_DIR" ]; then
  echo -e "\n${GREEN}Creating main directory: $MAIN_DIR${NC}"
  mkdir -m 755 "$MAIN_DIR"
else
  echo -e "${RED}Main directory $MAIN_DIR already exists${NC}"
  exit 1
fi

# List of subdirectories to create
SUBDIRS=("acpi" "boot" "kernel" "system" "crash")

# Create subdirectories
for subdir in "${SUBDIRS[@]}"; do
  if [ ! -d "$MAIN_DIR/$subdir" ]; then
    echo -e "${GREEN}Creating subdirectory: $MAIN_DIR/$subdir${NC}"
    mkdir -m 755 "$MAIN_DIR/$subdir"
  else
    echo -e "${RED}Subdirectory $MAIN_DIR/$subdir already exists${NC}"
  fi
done

chown -R "$(id -u):$(id -g)" "$MAIN_DIR"
# find "$MAIN_DIR" -type d -exec chmod 755 {} \;
# find "$MAIN_DIR" -type f -exec chmod 644 {} \;
echo -e "${GREEN}Directory structure creation completed successfully${NC}"

# Function to handle errors and provide feedback
handle_error() {
  echo -e "${RED}Error: $1${NC}" >&2
  return 1
}

# Function to save command output to file
save_output() {
  local cmd="$1"
  local output_file="$2"
  local description="$3"

  echo "Collecting $description..."
  if ! eval "$cmd" >"$output_file" 2>&1; then
    handle_error "Failed to collect $description"
  else
    echo "Successfully saved $description to $output_file"
  fi
}

# Collect DSDT dump
echo -e "${GREEN}Dumping DSDT...${NC}"
save_output "ioreg -lw0 -p IOACPIPlane -n IOACPIPlatformDevice | grep DSDT | sed 's/.*= //' | xxd -r -p" "$MAIN_DIR/acpi/dsdt.aml" "acpi dump"

# Collect boot logs
echo -e "\n${GREEN}Collecting system diagnostic information...${NC}"
save_output "log show --last boot | head -1500" "$MAIN_DIR/boot/boot.log" "boot logs"

# Collect power management settings
save_output "pmset -g" "$MAIN_DIR/system/power_settings.log" "power management settings"
save_output "pmset -g assertions" "$MAIN_DIR/system/power_assertions.log" "power assertions"
save_output "pmset -g log | grep -e 'Sleep.*due to' -e 'Wake.*due to'" "$MAIN_DIR/system/power_sleep.log" "power sleep settings"

# Collect kernel extension information
save_output "kextstat" "$MAIN_DIR/kernel/kext_status.log" "kernel extension status"
save_output "kextcache -i /" "$MAIN_DIR/kernel/kext_cache.log" "kernel cache status"
save_output "kextstat | grep -E 'AppleSMBusController|AppleSMBusPCI'" "$MAIN_DIR/kernel/kext_sbus-mchc.log" "kernel smbus support"

# Collect trim status and settings
save_output "log show --last boot | grep 'trims took'" "$MAIN_DIR/system/trim_status.log" "TRIM status"
# For NVMe drives
save_output "system_profiler SPNVMeDataType | grep 'TRIM'" "$MAIN_DIR/system/trim_status_nvme.log" "TRIM status"
# For SATA drives
#save_output "system_profiler SPSerialATADataType | grep "TRIM"" "$MAIN_DIR/system/trim_status_nvme.log" "TRIM status"

# Check bootloader
get_opencore_version() {
  nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version 2>/dev/null
}

get_clover_version() {
  nvram -p | grep "Clover-revision" | awk '{print $2}' 2>/dev/null
}

get_bootloader_info() {
  local opencore_ver=$(get_opencore_version)
  local clover_ver=$(get_clover_version)

  if [ ! -z "$opencore_ver" ]; then
    echo "OpenCore"
  elif [ ! -z "$clover_ver" ]; then
    echo "Clover"
  else
    echo "Unknown bootloader"
  fi
}

get_hardware_information() {

  # Motherboard Information
  BOARD_MODEL=$(system_profiler SPHardwareDataType | grep "Model Name:" | sed 's/.*: //')
  BOARD_MODEL_IDENTIFIER=$(system_profiler SPHardwareDataType | grep "Model Identifier:" | sed 's/.*: //')
  OS_LOADER_VERSION=$(system_profiler SPHardwareDataType | grep "OS Loader Version:" | sed 's/.*: //')
  SYSTEM_FIRMWARE_VERSION=$(system_profiler SPHardwareDataType | grep "System Firmware Version:" | sed 's/.*: //')

  # CPU Information
  CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)

  # GPU Information
  GPU_INFO=$(system_profiler SPDisplaysDataType | grep "Chipset Model" | cut -d":" -f2 | sed 's/^[ \t]*//')

  # Storage Information
  STORAGE_INFO=$(system_profiler SPNVMeDataType SPSerialATADataType | grep -E "Model:|Serial Number:|Capacity:|Medium Type:|Location:|Link Speed:" | sed 's/^[ \t]*//')

  # Memory Information
  MEMORY_SPECS=$(system_profiler SPMemoryDataType | grep -E "Type:|Speed:|Size:|Manufacturer:|Part Number:|BANK|DIMM" | sed 's/^[ \t]*//')

  # Network Information
  ETHERNET_INFO=$(system_profiler SPNetworkDataType | grep -v -E "Ethernet:|Network:|en[0-9]:" | sed 's/^[ \t]*//')

  # WiFI Information
  WIFI_INFO=(system_profiler SPAirPortDataType)

  # Blutooth Information
  BLUETOOTH_INFO=(system_profiler SPBluetoothDataType)

  # Network Information
  PCI_DATA=(system_profiler SPPCIDataType)

  # USB Data
  USB_DATA=(system_profiler SPUSBDataType)

  # Export variables for use in other scripts
  export CPU_MODEL GPU_INFO MEMORY_SPECS STORAGE_INFO
  export BOARD_MODEL BOARD_MODEL_IDENTIFIER OS_LOADER_VERSION SYSTEM_FIRMWARE_VERSION
  export NETWORK_CONTROLLERS
}
get_hardware_information

# Create a summary file
echo -e "\n${GREEN}Creating summary file...${NC}"
{
  echo -e "\n━━━━━━━━━━━━━━━━━ General Info ━━━━━━━━━━━━━━━━━"
  echo "Generated on: $(date)"
  echo "User: ${username}"

  echo "Board Model: $BOARD_MODEL"
  echo "Board Model Identifier: $BOARD_MODEL_IDENTIFIER"
  echo "OS Loader Version: $OS_LOADER_VERSION"
  echo "System Firmware Version: $SYSTEM_FIRMWARE_VERSION"
  echo "Bootloader: $(get_bootloader_info)"
  echo "macOS Version: $(sw_vers -productVersion)"
  echo "Build: $(sw_vers -buildVersion)"

  echo -e "\n━━━━━━━━━ Hardware Information Summary ━━━━━━━━━"
  echo "CPU: $CPU_MODEL"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "GPU: $GPU_INFO"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Storage info: $STORAGE_INFO"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Memory: $MEMORY_SPECS"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$ETHERNET_INFO"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$WIFI_INFO"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$BLUETOOTH_INFO"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$PCI_DATA"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$USB_DATA"
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
} >"$MAIN_DIR/summary.log"

# Display the final directory structure
echo -e "\n${GREEN}Directory structure:${NC}"
tree "$MAIN_DIR" || ls -R "$MAIN_DIR"

echo -e "\n${GREEN}[Success] Diagnostic information collection completed${NC}"

#!/bin/bash
#
# Hackintosh Diagnostic Log Collector (Refactored)
# Author: zx0r | License: MIT | https://github.com/zx0r
#
# Description: Modular, scalable, and maintainable script to collect Hackintosh diagnostics.
# "Stay Hungry, Stay Foolish" - Steve Jobs

# set -euo pipefail

# # ━━━ Color Output ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
# BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
# WHITE='\033[1;37m'; NC='\033[0m'

# log()     { echo -e "${CYAN}[➤ ]${NC} $*"; }
# success() { echo -e "${GREEN}[✓ ]${NC} $*"; }
# warn()    { echo -e "${YELLOW}[⚠ ]${NC} $*"; }
# error()   { echo -e "${RED}[✗ ] $*${NC}" >&2; exit 1; }

# # ━━━ Root Check ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# if [[ "$EUID" -eq 0 ]]; then
#   error "Please run this script as a normal user, not as root!"
# fi

# # ━━━ Banner ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# print_banner() {
#   local border="${MAGENTA}═══════════════════════════════════════════════════════════════════════${NC}"
#   cat <<EOF
# ${border}
# ${CYAN}   __ __         __    _      __           __     __
#   / // /__  ____/ /__ (_)__  / / ___  ___ / /    / /  ___  ___ ____
#  / _  / _  / __/  '_// / _ \/ __/ _ \(_-</ _ \  / /__/ _ \/ _  (_-<
# /_//_/\_,_/\__/_/\_\/_/_//_/\__/\___/___/_//_/ /____/\___/\_, /___/
# Copyright (c) 2024 for the Hackintosh community          /___/
# ${WHITE}Stay Hungry, Stay Foolish${NC}
# ${CYAN}  Author       : zx0r${NC}
# ${CYAN}  License      : MIT License${NC}
# ${CYAN}  Contact Info : https://github.com/zx0r${NC}
# ${MAGENTA}                      Think Different                     ${NC}
# ${MAGENTA}  ▸ Stay Hungry: Never be satisfied with what you know    ${NC}
# ${MAGENTA}  ▸ Stay Foolish: Never be afraid to take risks           ${NC}
# ${MAGENTA}  ▸ Stay Creative: Innovation distinguishes leaders       ${NC}
# ${MAGENTA}  ▸ Stay Passionate: Love what you do                     ${NC}
# ${MAGENTA}   "Your time is limited, don't waste it living someone else's life."   ${NC}
# ${border}
# EOF
# }

# # ━━━ User Prompt ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# get_username() {
#   local username
#   while :; do
#     echo -e "${BLUE}╔═════════════════════════════════════════════════════════════════════╗${NC}"
#     echo -e "${BLUE}║                         User Configuration                          ║${NC}"
#     echo -e "${BLUE}╚═════════════════════════════════════════════════════════════════════╝${NC}"
#     read -rp $'\033[0;36mPlease enter your username: \033[0m' username
#     [[ -n "$username" ]] || { echo -e "${RED}Username cannot be empty.${NC}"; continue; }
#     echo -e "${GREEN}Username set to: ${CYAN}$username${NC}"
#     read -rp $'\033[0;36mIs this correct? (y/n): \033[0m' confirm
#     [[ "$confirm" =~ ^[Yy]$ ]] && break
#   done
#   printf "%s" "$username"
# }

# # ━━━ Directory and Permissions ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# setup_directories() {
#   local userdir="$1"
#   local basedir="$PWD/$userdir"
#   local subdirs=(acpi boot kernel system crash)
#   if [[ -d "$basedir" ]]; then
#     error "Main directory $userdir already exists."
#   fi
#   mkdir -m 755 "$basedir"
#   for subdir in "${subdirs[@]}"; do
#     mkdir -m 755 "$basedir/$subdir"
#   done
#   chown -R "$(id -u):$(id -g)" "$basedir"
#   find "$basedir" -type d -exec chmod 755 {} \;
#   find "$basedir" -type f -exec chmod 644 {} \;
#   echo "$basedir"
# }

# # ━━━ Hardware Information ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# collect_hw_info() {
#   local -n _info=$1
#   _info[DATE]="$(date)"
#   _info[USER]="$USER"
#   _info[BOARD_MODEL]="$(system_profiler SPHardwareDataType | awk -F': ' '/Model Name/ {print $2}')"
#   _info[BOARD_ID]="$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')"
#   _info[OS_LOADER]="$(system_profiler SPHardwareDataType | awk -F': ' '/OS Loader Version/ {print $2}')"
#   _info[FIRMWARE]="$(system_profiler SPHardwareDataType | awk -F': ' '/System Firmware Version/ {print $2}')"
#   _info[CPU]="$(sysctl -n machdep.cpu.brand_string)"
#   _info[GPU]="$(system_profiler SPDisplaysDataType | awk -F': ' '/Chipset Model/ {print $2}' | xargs)"
#   _info[STORAGE]="$(system_profiler SPNVMeDataType SPSerialATADataType | grep -E 'Model:|Serial Number:|Capacity:|Medium Type:|Location:|Link Speed:' | xargs)"
#   _info[MEMORY]="$(system_profiler SPMemoryDataType | grep -E 'Type:|Speed:|Size:|Manufacturer:|Part Number:|BANK|DIMM' | xargs)"
#   _info[ETHERNET]="$(system_profiler SPNetworkDataType | grep -v -E 'Ethernet:|Network:|en[0-9]:' | xargs)"
#   _info[WIFI]="$(system_profiler SPAirPortDataType 2>/dev/null | xargs)"
#   _info[BLUETOOTH]="$(system_profiler SPBluetoothDataType 2>/dev/null | xargs)"
#   _info[PCI]="$(system_profiler SPPCIDataType 2>/dev/null | xargs)"
#   _info[USB]="$(system_profiler SPUSBDataType 2>/dev/null | xargs)"
#   _info[MACOS_VER]="$(sw_vers -productVersion)"
#   _info[MACOS_BUILD]="$(sw_vers -buildVersion)"
# }

# # ━━━ Bootloader Detection ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# get_bootloader_info() {
#   local opencore
#   local clover
#   opencore=$(nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version 2>/dev/null || true)
#   clover=$(nvram -p | awk '/Clover-revision/ {print $2}' 2>/dev/null || true)
#   [[ -n "$opencore" ]] && echo "OpenCore" && return
#   [[ -n "$clover" ]] && echo "Clover" && return
#   echo "Unknown bootloader"
# }

# # ━━━ Output Utilities ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# save_cmd_output() {
#   local cmd="$1" file="$2" desc="$3"
#   log "Collecting $desc..."
#   if ! eval "$cmd" >"$file" 2>&1; then
#     warn "Failed to collect $desc"
#   else
#     success "Saved $desc: $file"
#   fi
# }

# write_summary() {
#   local file="$1"
#   declare -n hwinfo=$2
#   cat >"$file" <<EOF

# ━━━━━━━━━━━━━━━━━ General Info ━━━━━━━━━━━━━━━━━
# Generated on: ${hwinfo[DATE]}
# User: ${hwinfo[USER]}
# Board Model: ${hwinfo[BOARD_MODEL]}
# Board Model Identifier: ${hwinfo[BOARD_ID]}
# OS Loader Version: ${hwinfo[OS_LOADER]}
# System Firmware Version: ${hwinfo[FIRMWARE]}
# Bootloader: $(get_bootloader_info)
# macOS Version: ${hwinfo[MACOS_VER]}
# Build: ${hwinfo[MACOS_BUILD]}

# ━━━━━━━━━ Hardware Information Summary ━━━━━━━━━
# CPU: ${hwinfo[CPU]}
# GPU: ${hwinfo[GPU]}
# Storage: ${hwinfo[STORAGE]}
# Memory: ${hwinfo[MEMORY]}
# Ethernet: ${hwinfo[ETHERNET]}
# WiFi: ${hwinfo[WIFI]}
# Bluetooth: ${hwinfo[BLUETOOTH]}
# PCI: ${hwinfo[PCI]}
# USB: ${hwinfo[USB]}
# EOF
# }

# # ━━━ Main ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# main() {
#   print_banner
#   local username
#   username=$(get_username)
#   local main_dir
#   main_dir=$(setup_directories "${username}-PRFiles")

#   # Collect logs
#   save_cmd_output "ioreg -lw0 -p IOACPIPlane -n IOACPIPlatformDevice | grep DSDT | sed 's/.*= //' | xxd -r -p" "$main_dir/acpi/dsdt.aml" "ACPI DSDT dump"
#   save_cmd_output "log show --last boot | head -1500" "$main_dir/boot/boot.log" "boot logs"
#   save_cmd_output "pmset -g" "$main_dir/system/power_settings.log" "power management settings"
#   save_cmd_output "pmset -g assertions" "$main_dir/system/power_assertions.log" "power assertions"
#   save_cmd_output "pmset -g log | grep -e 'Sleep.*due to' -e 'Wake.*due to'" "$main_dir/system/power_sleep.log" "power sleep settings"
#   save_cmd_output "kextstat" "$main_dir/kernel/kext_status.log" "kernel extension status"
#   save_cmd_output "kextcache -i /" "$main_dir/kernel/kext_cache.log" "kernel cache status"
#   save_cmd_output "kextstat | grep -E 'AppleSMBusController|AppleSMBusPCI'" "$main_dir/kernel/kext_sbus-mchc.log" "kernel smbus support"
#   save_cmd_output "log show --last boot | grep 'trims took'" "$main_dir/system/trim_status.log" "TRIM status"
#   save_cmd_output "system_profiler SPNVMeDataType | grep 'TRIM'" "$main_dir/system/trim_status_nvme.log" "TRIM status (NVMe)"
#   # SATA drives (uncomment if needed)
#   #save_cmd_output "system_profiler SPSerialATADataType | grep 'TRIM'" "$main_dir/system/trim_status_sata.log" "TRIM status (SATA)"

#   # Collect hardware info
#   declare -A hwinfo
#   collect_hw_info hwinfo
#   write_summary "$main_dir/summary.log" hwinfo

#   echo -e "\n${GREEN}Directory structure:${NC}"
#   command -v tree >/dev/null && tree -L 3 "$main_dir" || ls -R "$main_dir"
#   success "Diagnostic information collection completed"
# }

# main "$@"
