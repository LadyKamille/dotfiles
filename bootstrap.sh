#!/usr/bin/env bash
# Sets up zsh, oh-my-zsh, and the plugins .zshrc expects, then links .zshrc.
# Works on macOS (Homebrew) and Debian/Ubuntu (apt). Idempotent.
# DRY_RUN=1 prints what it would do without changing anything.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/link.sh
. "$REPO/lib/link.sh"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

run() {
  if [ "$DRY_RUN" = "1" ]; then
    log "would run: $*"
    return
  fi
  "$@"
}

case "$(uname -s)" in
  Darwin) PLATFORM=macos ;;
  Linux)  PLATFORM=linux ;;
  *)      log "unsupported platform: $(uname -s)"; exit 1 ;;
esac
log "platform: $PLATFORM"

install_packages() {
  if [ "$PLATFORM" = macos ]; then
    if ! command -v brew >/dev/null 2>&1; then
      log "Homebrew is required: https://brew.sh"
      exit 1
    fi
    # macOS ships zsh, git and curl; only install what is actually missing
    for pkg in zsh git curl gitleaks; do
      if command -v "$pkg" >/dev/null 2>&1; then
        log "ok    $pkg"
      else
        run brew install "$pkg"
      fi
    done
    # Nerd Font for the agnoster theme's glyphs
    if brew list --cask font-meslo-lg-nerd-font >/dev/null 2>&1; then
      log "ok    font-meslo-lg-nerd-font"
    else
      run brew install --cask font-meslo-lg-nerd-font || log "warn  font install failed; not fatal"
    fi
    return
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    log "warn  no apt-get; install zsh, git, curl, gitleaks and a powerline font yourself"
    return
  fi
  run sudo apt-get update
  run sudo apt-get install -y zsh git curl fonts-powerline
  command -v gitleaks >/dev/null 2>&1 || log "warn  gitleaks not in apt on older releases; see github.com/gitleaks/gitleaks"
}

install_oh_my_zsh() {
  if [ -d "$ZSH_DIR" ]; then
    log "ok    oh-my-zsh"
    return
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log "would install oh-my-zsh (unattended)"
    return
  fi
  # KEEP_ZSHRC stops the installer replacing the .zshrc this script links
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_plugin() {
  local repo="$1" name="$2" dest="$ZSH_CUSTOM_DIR/plugins/$2"
  if [ -d "$dest" ]; then
    log "ok    plugin $name"
    return
  fi
  run git clone --depth 1 "$repo" "$dest"
}

install_packages
install_oh_my_zsh
install_plugin https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
install_plugin https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting

# Linked, not appended: appending duplicates on every run and lets the live file
# drift from the tracked one. Machine-specific lines belong in ~/.zshrc.local,
# which the tracked .zshrc sources when present.
link "$REPO/.zshrc" "$HOME/.zshrc"

if [ "$SHELL" != "$(command -v zsh)" ]; then
  log ""
  log "To make zsh your login shell:  chsh -s $(command -v zsh)"
fi
log "done — open a new terminal, or run: exec zsh"
