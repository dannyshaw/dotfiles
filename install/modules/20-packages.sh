#!/usr/bin/env bash
# desc: Install CLI packages + uv tools + npm/go (brew bundle, both OSes)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

ensure_brew || die "Homebrew not found (bootstrap installs it on macOS and Ubuntu)."

BREWFILE="$HERE/../Brewfile"
log "brew bundle (cross-platform) from $BREWFILE"
brew bundle --file="$BREWFILE"
log "OK"
