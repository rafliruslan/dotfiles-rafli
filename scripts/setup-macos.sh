#!/bin/bash

# macOS-specific Setup Script
# This script sets up macOS-specific configurations and services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up macOS-specific configurations...${NC}"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}This script is designed for macOS only.${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not present
if ! command_exists brew; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}Homebrew is already installed.${NC}"
fi

# Install packages from Brewfile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    echo -e "${GREEN}Installing packages from Brewfile...${NC}"
    cd "$DOTFILES_DIR"
    brew bundle install
else
    echo -e "${YELLOW}Brewfile not found, skipping package installation.${NC}"
fi

# Setup yabai (requires SIP to be disabled for some features)
if command_exists yabai; then
    echo -e "${GREEN}Setting up yabai...${NC}"
    yabai --install-sa
    sudo yabai --load-sa
    
    # Start yabai service
    brew services start yabai
    echo -e "${YELLOW}Note: For full yabai functionality, you may need to disable SIP.${NC}"
    echo -e "${YELLOW}See: https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection${NC}"
fi

# Setup skhd
if command_exists skhd; then
    echo -e "${GREEN}Setting up skhd...${NC}"
    brew services start skhd
fi

# Setup SketchyBar (manual installation if not available via Homebrew)
if ! command_exists sketchybar; then
    echo -e "${YELLOW}SketchyBar not found via Homebrew. Installing manually...${NC}"
    git clone https://github.com/FelixKratz/SketchyBar.git /tmp/SketchyBar
    cd /tmp/SketchyBar
    make
    sudo make install
    cd -
    rm -rf /tmp/SketchyBar
fi

# Start SketchyBar
if command_exists sketchybar; then
    echo -e "${GREEN}Starting SketchyBar...${NC}"
    brew services start sketchybar
fi

# Setup tmux plugin manager
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo -e "${GREEN}Installing tmux plugin manager (TPM)...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${YELLOW}Run 'tmux source ~/.tmux.conf' and then 'prefix + I' to install tmux plugins.${NC}"
fi

# Configure macOS defaults
echo -e "${GREEN}Configuring macOS defaults...${NC}"

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Restart affected applications
killall Dock
killall Finder

echo -e "${GREEN}macOS setup completed!${NC}"
echo -e "${YELLOW}Some changes may require a logout/restart to take effect.${NC}"
echo -e "${YELLOW}Don't forget to configure accessibility permissions for yabai and skhd in System Preferences.${NC}"