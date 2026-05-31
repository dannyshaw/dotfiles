#!/usr/bin/env bash
# desc: Python via uv (tools + venvs) — replaces pip/pipx/virtualenvwrapper
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

# --- uv --------------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  if is_mac; then
    brew install uv
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi
command -v uv >/dev/null 2>&1 || { warn "uv not on PATH yet — open a new shell and re-run."; exit 1; }

# A managed interpreter so `uv venv` / `uv run` work everywhere.
log "Installing a managed Python (3.13)"
uv python install 3.13

# --- CLI tools (one per line in install/uv-tools.txt) ----------------------
TOOLS_FILE="$HERE/../uv-tools.txt"
if [[ -f "$TOOLS_FILE" ]]; then
  while IFS= read -r tool; do
    tool="${tool%%#*}"; tool="${tool// /}"      # strip comments + whitespace
    [[ -z "$tool" ]] && continue
    log2 "uv tool install $tool"
    uv tool install "$tool" || warn "failed: $tool"
  done < "$TOOLS_FILE"
fi

log "OK — create project venvs with 'uv venv' (no more virtualenvwrapper)."
