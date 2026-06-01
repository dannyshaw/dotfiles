#!/usr/bin/env bash
# desc: Shell stack — zsh + antidote + powerlevel10k + fzf/mcfly/zoxide
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

# Homebrew installs these identically on macOS and Linux. Idempotent — brew
# skips anything already installed. (powerlevel10k loads as an antidote plugin
# from ~/.zsh_plugins.txt, so we just need the binaries here.)
ensure_brew || die "Homebrew not found (bootstrap installs it on both OSes)."
log "Ensuring shell tools via brew"
brew install zsh antidote fzf mcfly zoxide 2>&1 | sed 's/^/--- --- /' || true

# --- make zsh the login shell ----------------------------------------------
ZSH_BIN="$(command -v zsh || true)"
if [[ -n "$ZSH_BIN" && "$SHELL" != "$ZSH_BIN" ]]; then
  if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  log2 "Setting login shell to $ZSH_BIN"
  chsh -s "$ZSH_BIN" || log2 "chsh failed — set it manually: chsh -s $ZSH_BIN"
fi

log "OK — shell config is delivered via the symlinked ~/.zshrc + ~/.zsh_plugins.txt"
log2 "First zsh launch runs the p10k wizard unless ~/.p10k.zsh already exists."
