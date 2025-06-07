# 🔧 dotfiles-rafli

A comprehensive macOS development environment setup featuring Neovim, tmux, SketchyBar, and modern window management tools.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/rafliruslan/dotfiles-rafli.git ~/.dotfiles
cd ~/.dotfiles

# Install applications via Homebrew
brew bundle install

# Backup existing configurations (optional but recommended)
./scripts/backup.sh

# Install dotfiles
./scripts/install.sh

# Setup macOS-specific configurations
./scripts/setup-macos.sh
```

## 📦 What's Included

### **Core Development Tools**
- **Neovim** - Modern Vim-based editor with extensive Lua configuration
- **tmux** - Terminal multiplexer with plugin ecosystem
- **Zsh** - Enhanced shell with Powerlevel10k theme, eza (better ls), and zoxide (better cd)

### **Window Management**
- **AeroSpace** - Modern tiling window manager

### **System Enhancement**
- **SketchyBar** - Customizable status bar
- **Ghostty** - Fast, feature-rich terminal emulator
- **Raycast** - Productivity launcher

## 🛠 Installation

### Prerequisites

- macOS (tested on macOS 14+)
- [Homebrew](https://brew.sh/) (will be installed automatically if not present)

### Step-by-Step Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rafliruslan/dotfiles-rafli.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Install applications**
   ```bash
   brew bundle install
   ```
   This installs all required applications and dependencies listed in the `Brewfile`.

3. **Backup existing configurations** (recommended)
   ```bash
   ./scripts/backup.sh
   ```
   Creates a timestamped backup of your current configurations in `~/.dotfiles-backup-YYYYMMDD_HHMMSS/`.

4. **Install dotfiles**
   ```bash
   ./scripts/install.sh
   ```
   Creates symlinks from the repository to the appropriate locations in your home directory.

5. **Setup macOS configurations**
   ```bash
   ./scripts/setup-macos.sh
   ```
   Configures macOS-specific settings, starts services, and optimizes system preferences.

## 📁 Repository Structure

```
dotfiles-rafli/
├── config/
│   ├── nvim/                    # Complete Neovim configuration
│   ├── sketchybar/              # SketchyBar status bar
│   ├── ghostty/                 # Ghostty terminal
│   ├── aerospace/               # AeroSpace window manager
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
├── DOTFILES_PLAN.md           # Detailed implementation plan
└── README.md                   # This file
```

## ⚙️ Configuration Details

### Neovim
- **Plugin Manager**: Lazy.nvim
- **LSP Support**: Built-in LSP with multiple language servers
- **File Explorer**: Nvim-tree
- **Fuzzy Finding**: Telescope
- **Syntax Highlighting**: Treesitter
- **Git Integration**: Fugitive, Gitsigns
- **Autocomplete**: nvim-cmp with multiple sources

### tmux
- **Plugin Manager**: TPM (tmux Plugin Manager)
- **Session Management**: tmux-resurrect, tmux-continuum
- **Navigation**: vim-tmux-navigator
- **Theme**: tokyo-night theme
- **Enhanced Experience**: tmux-sensible

### SketchyBar
- **Lua Configuration**: Modular setup with separate item configurations
- **System Information**: CPU, memory, battery, network status
- **Workspace Integration**: Integration with AeroSpace
- **Media Controls**: Current playing media information
- **Custom Items**: Calendar, weather, and custom widgets

### Window Management
- **AeroSpace**: Modern tiling window manager with automatic workspace management and native macOS integration

## 🔧 Customization

### Adding New Configurations
1. Add your configuration files to the appropriate directory under `config/`
2. Update `scripts/install.sh` to include the new symlinks
3. Update `Brewfile` if new applications are required
4. Test the installation on a clean system

### Modifying Existing Configurations
All configurations are modular and can be customized:
- **Neovim**: Edit files in `config/nvim/lua/josean/`
- **SketchyBar**: Modify items in `config/sketchybar/items/`
- **Shell**: Update `shell/.zshrc` and `shell/.p10k.zsh`

## 🚨 Important Notes

### Permissions Required
- **Accessibility**: AeroSpace requires accessibility permissions for window management
- **Screen Recording**: Some features may require screen recording permissions

### First-Time Setup
1. Grant necessary permissions in System Preferences > Security & Privacy
2. tmux plugins are installed automatically during setup
   - If needed manually: `tmux source ~/.tmux.conf` then `prefix + I`
3. Restart terminal applications after installation
4. Some configurations may require a logout/restart

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull origin main
./scripts/install.sh
```

## 🔙 Restoring Backups

If you need to restore your original configurations:

```bash
# Navigate to your backup directory
cd ~/.dotfiles-backup-YYYYMMDD_HHMMSS

# Run the generated restore script
./restore.sh
```

## 📖 Troubleshooting

### Common Issues

**tmux plugins not loading**
```bash
# If TPM is missing, install it first:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Then reload configuration and install plugins:
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh

# Or manually with prefix + I in tmux session
```

**SketchyBar not starting**
```bash
brew services restart felixkratz/formulae/sketchybar
```

**AeroSpace not working**
- Check accessibility permissions in System Preferences > Security & Privacy > Accessibility
- Ensure AeroSpace is in the list and enabled

**Neovim LSP not working**
- Ensure language servers are installed via Mason
- Check `:LspInfo` for status

**Telescope FZF extension errors**
```bash
# If you see "fzf extension doesn't exist" errors in Lazy.nvim:
make -C ~/.local/share/nvim/lazy/telescope-fzf-native.nvim clean
make -C ~/.local/share/nvim/lazy/telescope-fzf-native.nvim

# Then restart Neovim or run :Lazy reload telescope.nvim
```

### Getting Help

1. Check the [detailed plan](DOTFILES_PLAN.md) for implementation details
2. Review individual configuration files for specific settings
3. Check application-specific documentation for advanced customization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This dotfiles repository is available under the MIT License. Feel free to use, modify, and distribute as needed.

## 🙏 Acknowledgments

- [Neovim](https://neovim.io/) - The extensible text editor
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) - macOS status bar
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) - Tiling window manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme

---

**Note**: These dotfiles are personalized for my development workflow. Feel free to fork and modify according to your preferences!