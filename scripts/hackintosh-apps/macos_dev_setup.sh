#!/bin/bash

# Placeholder for edit confirmation
# macOS Developer Environment Setup Script
# Purpose: Automate the installation of essential developer tools and utilities
# Author: zx0r
# Last Updated: 2024

# chmod u+x initial-setup-macos.sh

# Set strict error handling
set -euo pipefail

# Print colorful messages
print_message() {
    echo -e "\n\033[1;34m===> $1\033[0m"
}

# Check if Xcode Command Line Tools are installed
install_xcode_tools() {
    print_message "Installing Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        xcode-select --install
    else
        print_message "Xcode Command Line Tools already installed"
    fi
}

# Install Homebrew if not present
install_homebrew() {
    print_message "Installing Homebrew..."
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" <<EOF
        yes
EOF

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo "eval $(/opt/homebrew/bin/brew shellenv)" >>~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_message "Homebrew already installed"
    fi
}

# Install essential developer tools and utilities
install_dev_tools() {
    print_message "Installing developer tools and utilities..."

    # Update Homebrew and upgrade existing packages
    brew update
    brew upgrade

    # Install essential tools
    TOOLS=(
        "atuin"
        "git"
        "gfxutil"
        "wget"
        "curl"
        "tree"
        "htop"
        "jq"
        "bat"
        "ripgrep"
        "fd"
        "fzf"
        "meson"
        "ninja"
        "scdoc"
        "fcft"
        "wayland-protocols"
        "pixman"
        "libxkbcommon"
    )

    for tool in "${TOOLS[@]}"; do
        brew install "$tool"
    done

    # Install GUI applications
    CASKS=(
        "warp"
        #"iterm2"
        "geekbench"
        "hackintool"
        "plistedit-pro"
        "macfuse"
        #"vscodium"
        #"visual-studio-code"
        #"docker"
        #"postman"
    )

    for cask in "${CASKS[@]}"; do
        brew install --cask "$cask"
    done
}

# install foot_termonal() {
# git clone https://codeberg.org/dnkl/foot.git

# }

# brew tap homebrew/services
# brew services start atuin
# brew services list | grep atuin
# atuin login

# Install additional utilities from GitHub releases
install_github_tools() {
    print_message "Installing additional utilities from GitHub releases..."

    # Create temporary directory for downloads
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    https://github.com/acidanthera/MaciASL/releases/download/1.6.5/MaciASL-1.6.5-RELEASE.dmg
    https://github.com/ic005k/OCAuxiliaryTools/releases/download/20240004/OCAT_Mac.dmg

    # IORegistry Explorer
    print_message "Installing IORegistry Explorer..."
    curl -L "https://github.com/utopia-team/IORegistryExplorer/releases/download/2.1/IORegistryExplorer-2.1.dmg" -o IORegistryExplorer.dmg
    yes | hdiutil attach IORegistryExplorer.dmg
    cp -r "/Volumes/IORegistryExplorer 2.1/IORegistryExplorer.app" /Applications/
    hdiutil detach "/Volumes/IORegistryExplorer 2.1"

    # About This Hack
    print_message "Installing About This Hack..."
    curl -L "https://github.com/2009-Nissan-Cube/About-This-Hack/releases/download/2.0.2/About.This.Hack.zip" -o AboutThisHack.zip
    unzip AboutThisHack.zip
    cp -r "About This Hack.app" /Applications/

    # Cleanup
    rm -rf "$TEMP_DIR"

    print_message "GitHub utilities successfully installed in Applications folder!"
}

# # Configure Git global settings
# configure_git() {
#     print_message "Configuring Git..."

#     read -p "Enter your Git username: " git_username
#     read -p "Enter your Git email: " git_email

#     git config --global user.name "$git_username"
#     git config --global user.email "$git_email"
#     git config --global init.defaultBranch main
#     git config --global core.editor "code --wait"
# }

# Main execution
main() {
    print_message "Starting macOS developer environment setup..."

    install_xcode_tools
    install_homebrew
    install_dev_tools
    install_github_tools
    #configure_git

    print_message "Setup completed successfully!"
}

# Run the script
main
