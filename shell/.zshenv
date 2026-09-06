# Secrets live in ~/.zshenv.local, which is never committed.
# Add machine-local exports there, not here.
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
