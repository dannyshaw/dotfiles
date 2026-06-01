#!/usr/bin/env bash
#
# pull-secrets.sh — restore secrets from the homelab onto this machine.
#
# The homelab is the canonical store; nothing secret lives in git. Secrets are
# pre-sorted there into work/personal/shared trees (see
# docs/homelab-secrets-splitout-prompt.md). This pulls only THIS machine's
# profile + shared, links the *.link entries into $HOME, composes ~/.ssh, and
# fixes permissions.
#
# Config via env:
#   HOMELAB_HOST          hostname/IP of the homelab            (required)
#   HOMELAB_USER          ssh user                              (default: $USER)
#   HOMELAB_SECRETS_DIR   remote path to the store              (default: dotfiles-secrets)
#   SECRETS_PROFILE       work|personal                         (default: from OS)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/lib}"
# shellcheck source=lib/common.sh
source "$LIB_DIR/common.sh"
# shellcheck source=lib/symlink.sh
source "$LIB_DIR/symlink.sh"
os_detect

STORE="$HOME/.dotfiles-secrets"
HOMELAB_USER="${HOMELAB_USER:-$USER}"
HOMELAB_SECRETS_DIR="${HOMELAB_SECRETS_DIR:-dotfiles-secrets}"

# Profile: mac host = work, ubuntu guest = personal (overridable).
if [[ -z "${SECRETS_PROFILE:-}" ]]; then
  if is_mac; then SECRETS_PROFILE=work; else SECRETS_PROFILE=personal; fi
fi

if [[ -z "${HOMELAB_HOST:-}" ]]; then
  warn "HOMELAB_HOST is not set — skipping secrets restore."
  log2 "Re-run later with:  HOMELAB_HOST=homelab.local $HERE/pull-secrets.sh"
  exit 0
fi

REMOTE="$HOMELAB_USER@$HOMELAB_HOST"
log "Restoring secrets: profile='$SECRETS_PROFILE' (+shared) from $REMOTE"

# --- reachability ----------------------------------------------------------
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE" true 2>/dev/null; then
  warn "Can't reach $REMOTE over SSH (key added to authorized_keys?). Skipping."
  exit 0
fi

# --- pull profile + shared (both merge into the local store) ---------------
mkdir -p "$STORE"; chmod 700 "$STORE"
for tree in "$SECRETS_PROFILE" shared; do
  log2 "rsync $tree/"
  rsync -az -e ssh "$REMOTE:$HOMELAB_SECRETS_DIR/$tree/" "$STORE/" 2>/dev/null \
    || warn "no '$tree' tree on homelab (skipping)"
done

# --- link the *.link entries (standalone secret files/dirs) ----------------
log "Linking secret dotfiles into \$HOME"
link_tree "$STORE"

# --- compose mixed dirs from their pulled subtrees -------------------------
# These hold a mix of secret + non-secret files, so they're delivered as a
# subtree (not a single *.link symlink) and merged into their real location.
# subtree-in-store  ->  destination
compose_subtree() {
  local sub="$1" dest="$2"
  [[ -d "$STORE/$sub" ]] || return 0
  log2 "composing $sub -> ${dest/#$HOME/~}"
  mkdir -p "$dest"
  cp -a "$STORE/$sub/." "$dest/"
}

log "Composing mixed-dir secrets into \$HOME"
compose_subtree ssh "$HOME/.ssh"
compose_subtree aws "$HOME/.aws"
compose_subtree gh  "$HOME/.config/gh"

# Tighten permissions on the composed dirs.
if [[ -d "$HOME/.ssh" ]]; then
  chmod 700 "$HOME/.ssh"
  find "$HOME/.ssh" -type f ! -name '*.pub' ! -name 'known_hosts*' ! -name 'config' \
    -exec chmod 600 {} +
  [[ -f "$HOME/.ssh/config" ]] && chmod 600 "$HOME/.ssh/config"
fi
for d in "$HOME/.aws" "$HOME/.config/gh"; do
  [[ -d "$d" ]] || continue
  chmod 700 "$d"
  find "$d" -type f -exec chmod 600 {} +
done

log "OK — secrets restored for profile '$SECRETS_PROFILE'."
