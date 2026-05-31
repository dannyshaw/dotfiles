#!/usr/bin/env bash
# desc: Sensible macOS defaults (key repeat, finder, screenshots)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

log "Applying macOS defaults"

# Fast key repeat (great for vim); disable press-and-hold accent popup.
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g ApplePressAndHoldEnabled -bool false

# Finder: show extensions, hidden files, path/status bars, full path in title.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Screenshots → ~/Screenshots as PNG.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"

# Don't write .DS_Store on network/USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

killall Finder 2>/dev/null || true
log "OK — some changes need a logout/login to fully apply."
