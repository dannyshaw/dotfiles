#!/usr/bin/env bash
# desc: Install Linux GUI apps via Flatpak (brew bundle, ubuntu only)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

ensure_brew || die "Homebrew not found."

# Flatpak + the Flathub remote must exist before brew bundle installs apps.
if ! command -v flatpak >/dev/null 2>&1; then
  log "Installing flatpak"
  sudo apt-get update -qq
  sudo apt-get install -y flatpak
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

BREWFILE="$HERE/../Brewfile.linux"
log "brew bundle (Linux Flatpak apps) from $BREWFILE"
brew bundle --file="$BREWFILE"
log2 "Flatpak apps may need a logout/login (or a reboot) before they appear."
log "OK"
