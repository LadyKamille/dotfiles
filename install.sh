#!/usr/bin/env bash
# Links the tracked config in this repo into the paths each tool expects, then
# runs the agent config installer. Idempotent.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/link.sh
. "$REPO/lib/link.sh"

link "$REPO/git/config" "$HOME/.gitconfig"
link "$REPO/git/ignore" "$HOME/.config/git/ignore"

# VS Code has no overlay file for user settings, so the tracked file is a
# baseline that gets merged in: only keys the machine does not already define
# are added, and nothing local is replaced
VSCODE_USER="$HOME/Library/Application Support/Code/User"
if [ -d "$VSCODE_USER" ]; then
  python3 "$REPO/lib/merge-jsonc.py" "$REPO/vscode/settings.json" "$VSCODE_USER/settings.json" "$DRY_RUN"
fi

# worktrunk: seed the portable settings without clobbering local hooks
[ -d "$HOME/.config/worktrunk" ] && link_if_absent "$REPO/worktrunk/config.toml" "$HOME/.config/worktrunk/config.toml"

# Secret scanning for this repo's own commits; core.hooksPath is left alone so
# other repos keep their own hooks
if [ -d "$REPO/.git" ]; then
  link "$REPO/hooks/pre-commit" "$REPO/.git/hooks/pre-commit"
  command -v gitleaks >/dev/null 2>&1 || log "warn  gitleaks not installed; the hook will pass everything (brew install gitleaks)"
fi

"$REPO/ai/install.sh"
