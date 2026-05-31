#!/usr/bin/env bash
# desc: Install macOS apps & CLI tools (brew bundle from Brewfile)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

command -v brew >/dev/null 2>&1 || die "Homebrew not found (bootstrap should have installed it)."

BREWFILE="$HERE/../Brewfile"
log "brew bundle from $BREWFILE"
brew bundle --file="$BREWFILE"
log "OK"
