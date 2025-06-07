#!/bin/bash

# Backup Script for Existing Configurations
# This script backs up existing dotfiles before installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}Creating backup of existing configurations...${NC}"
echo "Backup directory: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

# Function to backup file or directory
backup_item() {
    local item="$1"
    local backup_path="$2"
    
    if [[ -e "$item" ]]; then
        echo -e "${YELLOW}Backing up: $item${NC}"
        mkdir -p "$(dirname "$backup_path")"
        cp -r "$item" "$backup_path"
    else
        echo -e "${GREEN}No existing file found: $item${NC}"
    fi
}

# Backup configurations
echo -e "${GREEN}Backing up configuration files...${NC}"

# Config directories
backup_item "$HOME/.config/nvim" "$BACKUP_DIR/config/nvim"
backup_item "$HOME/.config/sketchybar" "$BACKUP_DIR/config/sketchybar"
backup_item "$HOME/.config/ghostty" "$BACKUP_DIR/config/ghostty"
backup_item "$HOME/.config/aerospace" "$BACKUP_DIR/config/aerospace"
backup_item "$HOME/.config/raycast" "$BACKUP_DIR/config/raycast"

# tmux configurations
backup_item "$HOME/.tmux.conf" "$BACKUP_DIR/tmux/.tmux.conf"
backup_item "$HOME/.tmux" "$BACKUP_DIR/tmux/.tmux"

# Shell configurations
backup_item "$HOME/.zshrc" "$BACKUP_DIR/shell/.zshrc"
backup_item "$HOME/.zprofile" "$BACKUP_DIR/shell/.zprofile"
backup_item "$HOME/.p10k.zsh" "$BACKUP_DIR/shell/.p10k.zsh"

echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${YELLOW}Your original configurations are saved in: $BACKUP_DIR${NC}"
echo -e "${YELLOW}You can restore them later if needed.${NC}"

# Create restore script
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

# Restore Script
# This script restores the backed up configurations

set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restoring configurations from: $BACKUP_DIR"

# Function to restore item
restore_item() {
    local backup_path="$1"
    local target="$2"
    
    if [[ -e "$backup_path" ]]; then
        echo "Restoring: $target"
        rm -rf "$target"
        cp -r "$backup_path" "$target"
    fi
}

# Restore configurations
restore_item "$BACKUP_DIR/config/nvim" "$HOME/.config/nvim"
restore_item "$BACKUP_DIR/config/sketchybar" "$HOME/.config/sketchybar"
restore_item "$BACKUP_DIR/config/ghostty" "$HOME/.config/ghostty"
restore_item "$BACKUP_DIR/config/aerospace" "$HOME/.config/aerospace"
restore_item "$BACKUP_DIR/config/raycast" "$HOME/.config/raycast"
restore_item "$BACKUP_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
restore_item "$BACKUP_DIR/tmux/.tmux" "$HOME/.tmux"
restore_item "$BACKUP_DIR/shell/.zshrc" "$HOME/.zshrc"
restore_item "$BACKUP_DIR/shell/.zprofile" "$HOME/.zprofile"
restore_item "$BACKUP_DIR/shell/.p10k.zsh" "$HOME/.p10k.zsh"

echo "Restore completed!"
EOF

chmod +x "$BACKUP_DIR/restore.sh"
echo -e "${GREEN}Created restore script: $BACKUP_DIR/restore.sh${NC}"