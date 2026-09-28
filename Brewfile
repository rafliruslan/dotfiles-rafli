# Brewfile for dotfiles-rafli
# Install with: brew bundle install
#
# Homebrew refuses untrusted third-party taps. On a fresh machine run first:
#   brew trust felixkratz/formulae

# Taps
tap "nikitabobko/tap"
tap "felixkratz/formulae"

# Core development tools
brew "neovim"
brew "tree-sitter-cli"  # LazyVim treesitter parsers
brew "tmux"

# Terminal and shell enhancements
brew "powerlevel10k"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "thefuck"
brew "mise"
brew "yazi"

# Fonts
cask "font-meslo-lg-nerd-font"
cask "font-jetbrains-mono-nerd-font"  # Ghostty, SketchyBar
cask "font-sketchybar-app-font"
cask "font-sf-pro"  # SketchyBar icons are SF Symbols glyphs
cask "sf-symbols"

# Window management
cask "nikitabobko/tap/aerospace"
brew "felixkratz/formulae/borders"

# Applications
cask "ghostty"
cask "raycast"

# SketchyBar status bar (the Lua config also needs SbarLua, which is not
# packaged: https://github.com/FelixKratz/SbarLua)
brew "felixkratz/formulae/sketchybar"
cask "corelocationcli"  # location for the prayer and weather widgets
brew "lua"

# Additional useful tools for development
brew "git"
brew "git-lfs"  # .gitconfig requires the lfs filter
brew "gh"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "fzf"
brew "zoxide"

# Optional: Additional development tools
# Uncomment as needed
# brew "node"
# brew "python"
# brew "rust"
# brew "go"