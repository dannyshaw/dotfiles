#!/usr/bin/env bash
# desc: Link Sublime Text User packages (macOS)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
: "${DOTFILES_DIR:=$(cd "$HERE/../.." && pwd)}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

SUBLIME_PACKAGES="$HOME/Library/Application Support/Sublime Text/Packages"
USER_PACKAGES="$SUBLIME_PACKAGES/User"
DOTFILES_USER_PACKAGES="$DOTFILES_DIR/sublime/User"

[[ -d "$DOTFILES_USER_PACKAGES" ]] || { log "no sublime/User in dotfiles — skipping"; exit 0; }
mkdir -p "$SUBLIME_PACKAGES"

if [[ ! -L "$USER_PACKAGES" && -d "$USER_PACKAGES" ]]; then
  log2 "Backing up existing Sublime User packages"
  mv "$USER_PACKAGES" "$USER_PACKAGES.bak"
fi
if [[ -L "$USER_PACKAGES" ]]; then
  target="$(readlink -- "$USER_PACKAGES")"
  [[ "$target" != "$DOTFILES_USER_PACKAGES" ]] && rm -f "$USER_PACKAGES"
fi
[[ -e "$USER_PACKAGES" ]] || ln -s "$DOTFILES_USER_PACKAGES" "$USER_PACKAGES"
log "OK"
