#!/usr/bin/env bash
# desc: Node via fnm + a default LTS (runs before packages so npm globals work)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

# fnm comes from brew on both OSes (bootstrap installs Homebrew first). This
# runs before 20-packages so a node binary exists for the Brewfile's `npm "…"`
# global installs.
ensure_brew || die "Homebrew not found (bootstrap installs it)."
command -v fnm >/dev/null 2>&1 || brew install fnm

eval "$(fnm env --use-on-cd)"
log "Installing latest LTS node"
fnm install --lts
fnm default "$(fnm current)"

# Linux only: bump inotify watchers for file-watching dev servers.
if is_ubuntu && ! grep -q "fs.inotify.max_user_watches=524288" /etc/sysctl.conf 2>/dev/null; then
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf >/dev/null
  sudo sysctl -p >/dev/null || true
fi

log "OK"
