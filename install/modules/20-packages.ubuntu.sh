#!/usr/bin/env bash
# desc: Install Ubuntu CLI packages (apt, modernized)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

# Lean, current package set. Dead desktop/Ubuntu-16 cruft from the old list
# (chrome-via-apt, dropbox, gnome-tweaks, keepassx, powertop, tlp, i3 …) is gone;
# add GUI/personal apps in the UTM guest as needed.
APT_PACKAGES=(
  age
  apt-transport-https
  bat
  build-essential
  curl
  direnv
  eza
  git
  htop
  jq
  ripgrep
  shellcheck
  silversearcher-ag
  tmux
  tree
  unzip
  vim
  wl-clipboard
  xclip
  zsh
)

log "apt update"
sudo apt-get update -qq
log "Installing: ${APT_PACKAGES[*]}"
sudo apt-get install -y "${APT_PACKAGES[@]}"

# Modern third-party repos use signed-by keyrings (NOT the deprecated apt-key).
# Example pattern, left commented — enable per machine if you want Sublime:
#
#   curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg \
#     | sudo gpg --dearmor -o /etc/apt/keyrings/sublimehq.gpg
#   echo "deb [signed-by=/etc/apt/keyrings/sublimehq.gpg] https://download.sublimetext.com/ apt/stable/" \
#     | sudo tee /etc/apt/sources.list.d/sublime-text.list
#   sudo apt-get update -qq && sudo apt-get install -y sublime-text

log "OK"
