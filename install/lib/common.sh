#!/usr/bin/env bash
# common.sh — shared helpers for the dotfiles installer.
# Source this; do not execute. Safe to source more than once.

# --- logging ---------------------------------------------------------------
# Match the repo's long-standing "--- " prefix style.
log()  { echo "--- $*"; }
log2() { echo "--- --- $*"; }
warn() { echo "--- !!! $*" >&2; }
die()  { warn "$*"; exit 1; }

# --- OS detection ----------------------------------------------------------
# Exports OS=mac|ubuntu. Honours a pre-set OS env var (lets you force a target,
# e.g. `OS=ubuntu ./install.sh` for testing module filtering on a Mac).
os_detect() {
  if [[ -n "${OS:-}" ]]; then
    export OS
    return 0
  fi
  case "$(uname -s)" in
    Darwin) OS=mac ;;
    Linux)
      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID:-}${ID_LIKE:-}" in
          *ubuntu*|*debian*) OS=ubuntu ;;
          *) OS=ubuntu; warn "Unrecognised Linux ($ID); assuming ubuntu-like." ;;
        esac
      else
        OS=ubuntu; warn "No /etc/os-release; assuming ubuntu-like."
      fi
      ;;
    *) die "Unsupported platform: $(uname -s)" ;;
  esac
  export OS
}

is_mac()    { [[ "${OS:-}" == "mac" ]]; }
is_ubuntu() { [[ "${OS:-}" == "ubuntu" ]]; }

# Ensure `brew` is on PATH (Apple Silicon, Intel, or Linuxbrew). Returns 1 if
# Homebrew isn't installed at all.
ensure_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$b" ]]; then eval "$("$b" shellenv)"; return 0; fi
  done
  return 1
}

# --- prompts ---------------------------------------------------------------
# confirm "Question?"  -> returns 0 on y/Y, 1 otherwise. Reads from the tty so
# it works even when the script itself is piped (curl | bash).
confirm() {
  local reply
  read -r -p "$1 (y/N): " reply </dev/tty
  [[ "$reply" =~ ^[Yy]$ ]]
}

# --- interactive multi-select ---------------------------------------------
# Pure-bash, zero deps, and bash-3.2 safe (macOS ships 3.2 — no namerefs).
# Single-keypress: press a number to toggle it INSTANTLY (no Enter needed),
# Enter to install the checked items. Communicates via globals by convention:
#
#   SELECT_LABELS=("Symlinks" "Shell" "Packages")
#   SELECT_PRESELECTED=(0 1)        # indices on by default (may be empty)
#   select_modules
#   echo "${SELECT_RESULT[@]}"      # -> chosen indices, e.g. "0 2"
select_modules() {
  local n=${#SELECT_LABELS[@]}
  local -a state
  local i
  for ((i = 0; i < n; i++)); do state[i]=0; done
  if [[ ${#SELECT_PRESELECTED[@]} -gt 0 ]]; then
    for i in "${SELECT_PRESELECTED[@]}"; do state[i]=1; done
  fi

  # Single-keypress toggling works for up to 9 items; beyond that, fall back to
  # typing number(s) + Enter (so two-digit indices stay reachable).
  local singlekey=1; (( n > 9 )) && singlekey=0

  while true; do
    printf '\033[H\033[2J' >&2          # clear screen + home cursor (redraw in place)
    {
      echo "Select modules to install:"
      echo
      for ((i = 0; i < n; i++)); do
        local mark="[ ]"; [[ "${state[i]}" == "1" ]] && mark="[x]"
        printf "  %d) %s %s\n" "$((i + 1))" "$mark" "${SELECT_LABELS[i]}"
      done
      echo
      if (( singlekey )); then
        echo "  press a number to toggle · a=all · n=none · Enter=install · q=cancel"
      else
        echo "  type number(s) then Enter to toggle · a=all · n=none · Enter alone=install · q=cancel"
      fi
    } >&2

    local input=""
    if (( singlekey )); then
      if ! IFS= read -rsn1 input </dev/tty 2>/dev/null; then SELECT_RESULT=(); return 0; fi
    else
      if ! IFS= read -r input </dev/tty 2>/dev/null; then SELECT_RESULT=(); return 0; fi
    fi

    case "$input" in
      ''|$'\r'|$'\n') break ;;            # Enter → confirm
      q|Q)            SELECT_RESULT=(); return 0 ;;
      a|A) for ((i = 0; i < n; i++)); do state[i]=1; done ;;
      n|N) for ((i = 0; i < n; i++)); do state[i]=0; done ;;
      *)
        local tok idx
        for tok in ${input//,/ }; do      # one digit (single-key) or many (line mode)
          if [[ "$tok" =~ ^[0-9]+$ ]] && (( tok >= 1 && tok <= n )); then
            idx=$((tok - 1)); state[idx]=$(( 1 - state[idx] ))
          fi
        done
        ;;
    esac
  done

  SELECT_RESULT=()
  for ((i = 0; i < n; i++)); do
    if [[ "${state[i]}" == "1" ]]; then SELECT_RESULT+=("$i"); fi
  done
}
