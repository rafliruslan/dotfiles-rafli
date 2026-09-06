#!/usr/bin/env bash
# Refuse to commit anything that looks like a credential.
#
# The .gitignore already excludes *token*, *secret*, *key* and friends, and
# that was not enough: config/raycast/config.json carried two live tokens
# past it for five months, because the giveaway was inside the file and the
# filename was innocent. Patterns on names cannot see contents.
#
# So this reads the staged content instead. Case-insensitive, because the
# first scan that missed HEROUI_AUTH_TOKEN was not.
set -uo pipefail

# Assignments and JSON fields whose NAME says credential, holding a value
# long enough to be one. Short values are placeholders and config keys.
NAMED='(api[-_]?key|auth[-_]?token|access[-_]?token|refresh[-_]?token|client[-_]?secret|password|passwd|credential)'
ASSIGN="${NAMED}[\"']?[[:space:]]*[:=][[:space:]]*[\"']?[A-Za-z0-9/+_.-]{16,}"

# Formats that are a credential whatever they are called.
SHAPES='(-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{20,})'

staged=$(git diff --cached --name-only --diff-filter=ACM)
[ -z "$staged" ] && exit 0

fail=0
while IFS= read -r file; do
    [ -f "$file" ] || continue
    # Skip this scanner: it necessarily contains every pattern it hunts for.
    case "$file" in scripts/secret-scan.sh) continue ;; esac

    if hit=$(git show ":$file" 2>/dev/null | grep -nEi "$ASSIGN|$SHAPES" | head -3); then
        [ -n "$hit" ] || continue
        [ "$fail" -eq 0 ] && printf '\nRefusing to commit - possible credentials:\n\n'
        fail=1
        printf '  %s\n' "$file"
        # Show where, never what.
        printf '%s\n' "$hit" | sed -E 's/^([0-9]+):.*/    line \1/'
    fi
done <<< "$staged"

if [ "$fail" -eq 1 ]; then
    cat <<'MSG'

Move the value into a file the repo ignores - ~/.zshenv.local for shell
exports, *.local for anything else - and source it. If this is a false
positive, commit with --no-verify and say why in the message.

MSG
    exit 1
fi
exit 0
