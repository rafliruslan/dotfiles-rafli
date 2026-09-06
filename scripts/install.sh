#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks from the dotfiles repository to the appropriate locations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}Starting dotfiles installation...${NC}"
echo "Dotfiles directory: $DOTFILES_DIR"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # If target exists and is not a symlink, back it up
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo -e "${YELLOW}Backing up existing $target${NC}"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Remove existing symlink if it exists
    if [[ -L "$target" ]]; then
        rm "$target"
    fi
    
    # Create the symlink
    ln -sf "$source" "$target"
    echo -e "${GREEN}Created symlink: $target -> $source${NC}"
}

# Install Neovim configuration
echo -e "${GREEN}Installing Neovim configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# Install SketchyBar configuration
echo -e "${GREEN}Installing SketchyBar configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/sketchybar" "$HOME/.config/sketchybar"

# Install Ghostty configuration
echo -e "${GREEN}Installing Ghostty configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"

# Install AeroSpace configuration
echo -e "${GREEN}Installing AeroSpace configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/aerospace" "$HOME/.config/aerospace"

# Install Raycast configuration
# Install tmux configuration
echo -e "${GREEN}Installing tmux configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/tmux" "$HOME/.config/tmux"

# Install TheFuck configuration
echo -e "${GREEN}Installing TheFuck configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/thefuck" "$HOME/.config/thefuck"

# Install shell configuration
echo -e "${GREEN}Installing shell configuration...${NC}"
create_symlink "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/shell/.zprofile" "$HOME/.zprofile"
create_symlink "$DOTFILES_DIR/shell/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$DOTFILES_DIR/shell/.zshenv" "$HOME/.zshenv"
create_symlink "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_DIR/shell/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/shell/.gitconfig-personal" "$HOME/.gitconfig-personal"
create_symlink "$DOTFILES_DIR/.markdownlint-cli2.yaml" "$HOME/.markdownlint-cli2.yaml"

# Window-manager borders and the global git ignore
echo -e "${GREEN}Installing borders and git configuration...${NC}"
create_symlink "$DOTFILES_DIR/config/borders" "$HOME/.config/borders"
mkdir -p "$HOME/.config/git"
create_symlink "$DOTFILES_DIR/config/git/ignore" "$HOME/.config/git/ignore"

# Claude Code: config only. Skills are re-installed, state is never restored.
echo -e "${GREEN}Installing Claude Code configuration...${NC}"
mkdir -p "$HOME/.claude"
create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
create_symlink "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"

# Secrets never live in the repo. Seed the local file the shell sources.
if [[ ! -f "$HOME/.zshenv.local" ]]; then
    echo "# Machine-local secrets. Never committed." > "$HOME/.zshenv.local"
    chmod 600 "$HOME/.zshenv.local"
    echo -e "${YELLOW}Created ~/.zshenv.local - put your tokens there, not in .zshenv${NC}"
fi

# Refuse commits that carry credentials.
git -C "$DOTFILES_DIR" config core.hooksPath scripts/hooks

echo -e "${GREEN}Dotfiles installation completed!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or source your configuration files.${NC}"
echo -e "${YELLOW}Run 'source ~/.zshrc' to reload your shell configuration.${NC}"