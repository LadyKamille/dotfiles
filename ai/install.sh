#!/usr/bin/env bash
# Links the agent-agnostic config in this directory into each agent's expected paths.
# Idempotent. Existing non-symlink files are backed up to <path>.bak-<timestamp>.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"
# Backups go outside every directory an agent scans; a .bak left next to a
# SKILL.md is discovered as a second copy of the skill
BACKUP_DIR="${BACKUP_DIR:-$HOME/.agent-config-backups}"

log() { printf '%s\n' "$*"; }

# Skills vendored as submodules are symlinks into ai/vendor; a missing checkout
# leaves those links dangling
if [ -f "$REPO/../.gitmodules" ] && [ -z "$(ls -A "$REPO/vendor/explain-diff" 2>/dev/null)" ]; then
  log "warn  ai/vendor/explain-diff is empty; run: git submodule update --init --recursive"
fi

# Seeds a target only when nothing is there, for config an agent or tool may
# extend with machine-specific content
link_if_absent() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    log "skip  $dest (exists; left alone)"
    return
  fi
  link "$src" "$dest"
}

link() {
  local src="$1" dest="$2"
  [ -e "$src" ] || { log "skip  $dest (missing source)"; return; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "ok    $dest"
    return
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log "would link $dest -> $src"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="$BACKUP_DIR/$(printf '%s' "${dest#$HOME/}" | tr '/' '_').bak-$STAMP"
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$backup"
    log "backup $dest -> $backup"
  fi
  ln -s "$src" "$dest"
  log "link  $dest -> $src"
}

# Shared skill store, read by any agent that resolves ~/.agents/skills
link "$REPO/skills" "$HOME/.agents/skills"

# Claude Code
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  link "$REPO/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  link "$REPO/adapters/claude/settings.json" "$HOME/.claude/settings.json"
  link "$REPO/adapters/claude/statusline.sh" "$HOME/.claude/statusline.sh"

  # Claude Code discovers skills under ~/.claude/skills, so point one link per
  # skill at the shared store
  for skill in "$REPO"/skills/*/; do
    [ -d "$skill" ] || continue
    name="$(basename "$skill")"
    link "$HOME/.agents/skills/$name" "$HOME/.claude/skills/$name"
  done
fi

# Copilot CLI reads personal instructions from copilot-instructions.md and
# personal skills from ~/.agents/skills, linked above
[ -d "$HOME/.copilot" ] && link "$REPO/AGENTS.md" "$HOME/.copilot/copilot-instructions.md"

# VS Code, where the Copilot chat settings also live
VSCODE_USER="$HOME/Library/Application Support/Code/User"
[ -d "$VSCODE_USER" ] && link "$REPO/adapters/vscode/settings.json" "$VSCODE_USER/settings.json"

# worktrunk: seed the portable settings without clobbering local hooks
[ -d "$HOME/.config/worktrunk" ] && link_if_absent "$REPO/adapters/worktrunk/config.toml" "$HOME/.config/worktrunk/config.toml"

# herdr keeps one hand-authored file; the rest of its config dir is generated
[ -d "$HOME/.config/herdr" ] && link "$REPO/adapters/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# Cursor reads AGENTS.md directly
[ -d "$HOME/.cursor" ] && link "$REPO/AGENTS.md" "$HOME/.cursor/AGENTS.md"

# Gemini CLI looks for GEMINI.md unless contextFileName is overridden
[ -d "$HOME/.gemini" ] && link "$REPO/AGENTS.md" "$HOME/.gemini/GEMINI.md"

log "done"
