#!/usr/bin/env bash
# desc: Node via fnm + global npm tools
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

# fnm (Fast Node Manager) — replaces the old creationix/nvm install.
if ! command -v fnm >/dev/null 2>&1; then
  if is_mac; then
    brew install fnm
  else
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  fi
fi

# Load fnm into THIS shell so we can install node now.
FNM_BIN="$(command -v fnm || echo "$HOME/.local/share/fnm/fnm")"
if [[ -x "$FNM_BIN" ]]; then
  eval "$("$FNM_BIN" env --use-on-cd)"
  log "Installing latest LTS node"
  "$FNM_BIN" install --lts
  "$FNM_BIN" default "$("$FNM_BIN" current)"
else
  warn "fnm not on PATH yet — open a new shell and run 'fnm install --lts'."
fi

# Linux only: bump inotify watchers for file-watching dev servers.
if is_ubuntu && ! grep -q "fs.inotify.max_user_watches=524288" /etc/sysctl.conf 2>/dev/null; then
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf >/dev/null
  sudo sysctl -p >/dev/null || true
fi

log "OK"
