#!/usr/bin/env bash
# desc: Shell stack — zsh + antidote + powerlevel10k + fzf/mcfly/zoxide
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

# --- zsh + the interactive tools -------------------------------------------
# powerlevel10k is loaded as an antidote plugin (see zsh_plugins.txt.link), so
# we only need the binaries here.
if is_mac; then
  log "Installing shell tools via brew"
  brew install --quiet zsh antidote fzf mcfly zoxide 2>&1 | sed 's/^/--- --- /' || true
else
  log "Installing shell tools (apt + upstream installers)"
  sudo apt-get install -y zsh fzf
  # antidote: git clone (not packaged on Ubuntu)
  if [[ ! -d "$HOME/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  fi
  # mcfly + zoxide: official one-line installers (idempotent enough)
  command -v mcfly >/dev/null 2>&1 || \
    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh \
      | sudo sh -s -- --git cantino/mcfly
  command -v zoxide >/dev/null 2>&1 || \
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# --- make zsh the login shell ----------------------------------------------
ZSH_BIN="$(command -v zsh || true)"
if [[ -n "$ZSH_BIN" && "$SHELL" != "$ZSH_BIN" ]]; then
  if grep -q "$ZSH_BIN" /etc/shells 2>/dev/null || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null; then
    log2 "Setting login shell to $ZSH_BIN"
    chsh -s "$ZSH_BIN" || log2 "chsh failed — set it manually: chsh -s $ZSH_BIN"
  fi
fi

log "OK — shell config is delivered via the symlinked ~/.zshrc + ~/.zsh_plugins.txt"
log2 "First zsh launch will run the p10k wizard unless ~/.p10k.zsh already exists."
