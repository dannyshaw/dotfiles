#!/usr/bin/env bash
#
# install.sh — interactive, module-driven dotfiles installer.
#
# Discovers install/modules/*.sh, hides any that don't match this OS (platform
# is encoded in the filename: foo.mac.sh / foo.ubuntu.sh / foo.sh = both), then
# lets you pick which of the rest to run. Modules run in filename order.
set -euo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$INSTALL_DIR/.." && pwd)"
LIB_DIR="$INSTALL_DIR/lib"
MODULES_DIR="$INSTALL_DIR/modules"

# shellcheck source=lib/common.sh
source "$LIB_DIR/common.sh"
os_detect

export DOTFILES_DIR LIB_DIR OS

# Default-on modules (matched by filename prefix).
DEFAULT_ON="00-symlinks 10-shell"

log "Danny's dotfiles installer  (OS=$OS, dir=$DOTFILES_DIR)"

# --- discover modules applicable to this OS --------------------------------
# Parallel arrays: MOD_PATH[i] holds the script; SELECT_* feed the picker.
MOD_PATH=(); SELECT_LABELS=(); SELECT_PRESELECTED=()

module_platform() {       # echo mac|ubuntu|both for a module filename
  local stem="${1%.sh}"
  case "$stem" in
    *.mac)    echo mac ;;
    *.ubuntu) echo ubuntu ;;
    *)        echo both ;;
  esac
}

module_desc() {           # first "# desc:" line, or the filename
  local d
  d="$(sed -n 's/^# *desc: *//p' "$1" | head -1)"
  if [[ -n "$d" ]]; then echo "$d"; else basename "$1"; fi
}

idx=0
for mod in "$MODULES_DIR"/*.sh; do
  [[ -e "$mod" ]] || continue
  plat="$(module_platform "$(basename "$mod")")"
  [[ "$plat" == "both" || "$plat" == "$OS" ]] || continue   # OS filter

  MOD_PATH+=("$mod")
  SELECT_LABELS+=("$(module_desc "$mod")")
  base="$(basename "$mod" .sh)"
  for on in $DEFAULT_ON; do
    if [[ "$base" == "$on"* ]]; then SELECT_PRESELECTED+=("$idx"); fi
  done
  idx=$((idx + 1))
done

[[ ${#MOD_PATH[@]} -gt 0 ]] || die "No modules found in $MODULES_DIR"

# --- pick ------------------------------------------------------------------
select_modules
if [[ ${#SELECT_RESULT[@]} -eq 0 ]]; then
  log "Nothing selected. Bye."
  exit 0
fi

# --- run -------------------------------------------------------------------
ran=(); failed=()
for i in "${SELECT_RESULT[@]}"; do
  mod="${MOD_PATH[i]}"
  name="$(basename "$mod")"
  echo
  log "▶ $name"
  if bash "$mod"; then
    ran+=("$name")
  else
    warn "module failed (continuing): $name"
    failed+=("$name")
  fi
done

# --- summary ---------------------------------------------------------------
echo
log "Done."
[[ ${#ran[@]}    -gt 0 ]] && log2 "ran:    ${ran[*]}"
[[ ${#failed[@]} -gt 0 ]] && log2 "failed: ${failed[*]}"
if [[ "$SHELL" != *zsh ]]; then
  log2 "Login shell isn't zsh yet — run: chsh -s \"\$(command -v zsh)\", then re-login."
fi
log2 "Open a new terminal to pick up the new shell config."
