#!/usr/bin/env bash
# desc: Install macOS GUI apps + VS Code extensions (brew bundle, mac only)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

ensure_brew || die "Homebrew not found."

BREWFILE="$HERE/../Brewfile.macos"
log "brew bundle (macOS casks + VS Code extensions) from $BREWFILE"
# Casks first install VS Code, which provides the `code` CLI the vscode
# extension lines need.
brew bundle --file="$BREWFILE"
log "OK"
