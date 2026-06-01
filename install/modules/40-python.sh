#!/usr/bin/env bash
# desc: Python via uv — managed interpreter (tools come from the Brewfile)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

# uv itself and all uv CLI tools (ruff, pre-commit, …) are declared in the
# Brewfile and installed by the packages module via `brew bundle`, on both
# macOS and Linux. This module just adds a uv-managed interpreter so
# `uv venv` / `uv run` work out of the box.
ensure_brew || true
if ! command -v uv >/dev/null 2>&1; then
  warn "uv not found — run the packages module (brew bundle) first."
  exit 0
fi

log "Installing a uv-managed Python (3.13)"
uv python install 3.13
log "OK — create project venvs with 'uv venv' (no pip/virtualenvwrapper)."
