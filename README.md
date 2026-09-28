# dotfiles-rafli

macOS setup: Zsh, Neovim (LazyVim), herdr, Ghostty, AeroSpace and a Lua SketchyBar.
One script installs it, and you choose which parts.

## Install

```bash
git clone https://github.com/rafliruslan/dotfiles-rafli.git ~/.dotfiles
cd ~/.dotfiles
./install
```

`./install` shows a checklist. Type numbers to toggle components, then press Enter.
Homebrew is installed first if it is missing.

```text
./install                  checklist
./install shell herdr      only these components
./install --defaults       the default selection, no questions
./install --all            everything
./install --dry-run ...    print what would happen, change nothing
./install --list           list components
```

Re-running is safe. Installed packages are skipped, existing links are left
alone, and any file a link would replace is moved to
`~/.dotfiles-backup/<timestamp>/` first.

## Components

| Component    | Default | What it sets up |
|--------------|---------|-----------------|
| `shell`      | on  | `.zshrc`, `.zprofile`, `.zshenv`, Powerlevel10k, fzf + fzf-git, zoxide, eza, bat, thefuck, mise, yazi |
| `git`        | on  | `.gitconfig`, global ignore, gh, git-lfs. Your identity goes in `~/.gitconfig.local` |
| `neovim`     | on  | LazyVim config, ripgrep, fd, tree-sitter CLI; plugins installed on the spot |
| `herdr`      | on  | herdr, a terminal multiplexer for AI coding agents, and its `config.toml` |
| `ghostty`    | on  | Ghostty and JetBrains Mono Nerd Font |
| `aerospace`  | on  | AeroSpace tiling window manager and JankyBorders |
| `sketchybar` | on  | SketchyBar (Lua) with SbarLua, SF Pro / SF Symbols fonts, and the tools its widgets call |
| `raycast`    | on  | Raycast (the app only; its settings are not synced) |
| `macos`      | off | Dock autohide, Finder path and status bars, fast key repeat |
| `brave`      | off | Brave profile launchers that AeroSpace can tile (needs Brave) |
| `claude`     | off | Claude Code `settings.json`, hooks and `CLAUDE.md`. Replaces yours |

## After installing

- **AeroSpace:** allow it in System Settings → Privacy & Security → Accessibility.
- **SketchyBar:** allow `CoreLocationCLI` in Privacy & Security → Location Services
  for the prayer-times and weather widgets. If it is not listed, run
  `CoreLocationCLI --json` once to get the prompt.
- **macos component:** log out and back in for the key repeat change.
- **herdr:** `herdr integration install claude` (or another agent) shows agent
  status in its panes.

## Machine-local files

These files are never committed. Put anything personal or secret in them:

- `~/.zshenv.local`: tokens and machine-specific exports (for example `AWS_PROFILE`).
- `~/.gitconfig.local`: your git name and email, plus any `includeIf` rules.
  If you already had a `~/.gitconfig`, the installer keeps it here.

A pre-commit hook (`scripts/secret-scan.sh`) refuses commits that look like
they contain credentials.

## Layout

```text
install                  the installer
config/                  linked into ~/.config/<name>
  aerospace/ borders/ ghostty/ git/ herdr/ nvim/ sketchybar/ thefuck/
shell/                   linked into ~ (.zshrc, .zprofile, .zshenv, .p10k.zsh, .gitconfig)
claude/                  Claude Code config (claude component)
applications/, local/    Brave launchers (brave component)
scripts/                 secret scan and git hooks
```

## Updating

```bash
cd ~/.dotfiles
git pull
./install --defaults     # or name the components you use
```

## Troubleshooting

- **Bar icons show `?`:** the SF fonts are missing, or SketchyBar started before
  they were installed. Run `./install sketchybar`, which installs them and
  restarts the bar.
- **Prayer or weather shows "location unknown":** see Location Services above.
- **herdr shows no agent status:** run `herdr integration install claude`
  (or `codex`, `cursor`, ...).

## License

MIT
