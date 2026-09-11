# Symlink helpers shared by install.sh and ai/install.sh.
# Backups go outside every directory an agent or tool scans; a .bak left next to
# a SKILL.md is discovered as a second copy of the skill.
STAMP="${STAMP:-$(date +%Y%m%d%H%M%S)}"
DRY_RUN="${DRY_RUN:-0}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.agent-config-backups}"

log() { printf '%s\n' "$*"; }

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

# Seeds a target only when nothing is there, for config a tool may extend with
# machine-specific content
link_if_absent() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    log "skip  $dest (exists; left alone)"
    return
  fi
  link "$src" "$dest"
}
