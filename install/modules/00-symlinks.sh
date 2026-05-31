#!/usr/bin/env bash
# desc: Symlink all *.link files into $HOME (dotfiles + secrets)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
: "${DOTFILES_DIR:=$(cd "$HERE/../.." && pwd)}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
# shellcheck source=../lib/symlink.sh
source "$LIB_DIR/symlink.sh"

log "Symlinking dotfiles from $DOTFILES_DIR"
link_tree "$DOTFILES_DIR"

# If the homelab secrets have been pulled, link those too.
if [[ -d "$HOME/.dotfiles-secrets" ]]; then
  log "Symlinking secrets from ~/.dotfiles-secrets"
  link_tree "$HOME/.dotfiles-secrets"
fi

log "OK"
