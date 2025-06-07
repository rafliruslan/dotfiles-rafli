# Dotfiles Repository Plan

This document outlines the comprehensive plan for organizing and setting up the dotfiles repository for rafliruslan's development environment.

## Current Configuration Overview

Based on system scan performed on 6/7/2025, the following configuration files and directories were identified:

### **tmux Configuration**
- `/Users/rafli/.tmux.conf` - Main tmux configuration file
- `/Users/rafli/.tmux/plugins/` - Tmux plugins directory containing:
  - `tmux-continuum/`
  - `tmux-resurrect/`
  - `tmux-sensible/`
  - `tmux-tokyo-night/`
  - `tpm/` (Tmux Plugin Manager)
  - `vim-tmux-navigator/`

### **sketchybar Configuration**
- `/Users/rafli/.config/sketchybar/` - Complete sketchybar configuration with:
  - `sketchybarrc` - Main config file
  - `init.lua`, `colors.lua`, `settings.lua`, `icons.lua`, `bar.lua`, `default.lua`
  - `items/` - Individual item configurations (spaces, front_app, calendar, media, widgets, etc.)
  - `helpers/` - Helper scripts and binaries
  - `.luarc.json` - Lua configuration

### **nvim/neovim Configuration**
- `/Users/rafli/.config/nvim/` - Complete Neovim configuration with:
  - `init.lua` - Main init file
  - `lazy-lock.json` - Plugin lockfile
  - `lua/josean/` - Structured Lua configuration:
    - `core/` - Core settings (keymaps, options)
    - `plugins/` - Plugin configurations (50+ plugin files)
    - `plugins/lsp/` - LSP configurations
  - `after/queries/` - Custom queries
  - `.stylua.toml` - Lua formatter config

### **ghostty Configuration**
- `/Users/rafli/.config/ghostty/config` - Main ghostty terminal config
- `/Users/rafli/.config/ghostty/config.8d7ad520.bak` - Backup config file

### **Shell Configuration Files**
- `/Users/rafli/.zshrc` - Zsh configuration
- `/Users/rafli/.zprofile` - Zsh profile
- `/Users/rafli/.p10k.zsh` - Powerlevel10k theme configuration (95KB)
- `/Users/rafli/.bash_history` - Bash history


### **Terminal Emulator Configurations**
- Terminal configurations handled separately

### **Window Manager Configurations**
- `/Users/rafli/.config/aerospace/aerospace.toml` - AeroSpace window manager
- `/Users/rafli/.config/yabai/yabairc` - Yabai tiling window manager
- `/Users/rafli/.config/skhd/skhdrc` - Simple hotkey daemon

### **Other Application Configurations**
- `/Users/rafli/.config/raycast/` - Raycast launcher configuration
- `/Users/rafli/.config/flutter/` - Flutter development configuration

### **Additional Dotfiles**
- `/Users/rafli/.luarc.json` - Lua language server configuration
- `/Users/rafli/.viminfo` - Vim history and settings

## Proposed Repository Structure

```
dotfiles-rafli/
├── config/
│   ├── nvim/                    # Complete Neovim configuration
│   ├── sketchybar/              # SketchyBar status bar
│   ├── ghostty/                 # Ghostty terminal
│   ├── aerospace/               # AeroSpace window manager
│   ├── yabai/                   # Yabai window manager
│   ├── skhd/                    # Hotkey daemon
│   └── raycast/                 # Raycast launcher
├── tmux/
│   ├── .tmux.conf              # Main tmux config
│   └── plugins/                # Tmux plugins
├── shell/
│   ├── .zshrc                  # Zsh configuration
│   ├── .zprofile               # Zsh profile
│   └── .p10k.zsh               # Powerlevel10k theme
├── scripts/
│   ├── install.sh              # Main installation script
│   ├── setup-macos.sh          # macOS-specific setup
│   └── backup.sh               # Backup existing configs
├── Brewfile                    # Homebrew dependencies
├── .gitignore                  # Repository gitignore
└── README.md                   # Setup instructions
```

## Implementation Plan

### **Phase 1: Repository Setup**
1. Create organized directory structure in dotfiles repository
2. Copy all configuration files with proper organization
3. Exclude sensitive files (SSH keys, git credentials, bash history)
4. Create proper .gitignore to prevent accidental commits of sensitive data

### **Phase 2: Installation Automation**
1. Create symlink installation script (`scripts/install.sh`)
   - Automated symlinking of all configuration files
   - Cross-platform compatibility considerations
   - Error handling and validation
2. Add backup functionality for existing configs (`scripts/backup.sh`)
   - Backup existing dotfiles before installation
   - Restore functionality if needed
3. Add macOS-specific setup (`scripts/setup-macos.sh`)
   - Homebrew package installation for all applications
   - Application-specific setup commands
   - System preferences configuration
4. Create Homebrew bundle file (`Brewfile`)
   - List all required applications and dependencies
   - Include formulae, casks, and mas applications
   - Enable one-command installation of all tools

### **Phase 3: Documentation & Git**
1. Create comprehensive README with setup instructions
   - Prerequisites and Homebrew installation
   - Brewfile usage for installing applications
   - Configuration installation steps
   - Customization guide
   - Troubleshooting section
2. Initialize git repository with proper .gitignore
   - Exclude system-specific files
   - Exclude sensitive information
   - Include development artifacts appropriately
3. Push to GitHub (rafliruslan)
   - Set up repository on GitHub
   - Configure appropriate repository settings
   - Add repository description and topics

## Key Features

### **Modular Organization**
- Configuration files grouped by application type
- Clear separation of concerns
- Easy to locate and modify specific configurations

### **Safe Installation**
- Backup of existing configurations before installation
- Non-destructive installation process
- Easy rollback capabilities

### **Cross-Machine Compatibility**
- Conditional setups for different environments
- Machine-specific configuration handling
- Portable installation scripts

### **Security-Conscious**
- Exclusion of SSH private keys
- No git credentials or sensitive tokens
- Proper .gitignore configuration

### **Well-Documented**
- Comprehensive setup instructions
- Configuration explanations
- Troubleshooting guides

## Security Considerations

### **Files to Exclude**
- SSH configurations and keys
- Git credentials and configuration files
- GitHub CLI configuration and tokens
- WezTerm and Alacritty terminal configurations
- Shell history files (`.bash_history`, `.zsh_history`)
- Application-specific tokens and secrets
- System-specific cache files

### **Files to Include Safely**
- Core development environment configurations
- Public configuration files
- Application settings (after review)

## Next Steps

1. **Review and approve this plan**
2. **Execute Phase 1: Repository Setup**
3. **Execute Phase 2: Installation Automation**
4. **Execute Phase 3: Documentation & Git**
5. **Test installation on clean system**
6. **Iterate and improve based on usage**

## Notes

- This plan was generated based on system scan performed on 6/7/2025
- Configuration locations may vary on different systems
- Regular updates to this plan should be made as configurations evolve
- Consider adding automated testing for installation scripts