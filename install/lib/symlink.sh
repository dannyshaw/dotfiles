#!/usr/bin/env bash
# symlink.sh — the ".link" symlinker, the backbone of these dotfiles.
#
# Any file or dir named "*.link" under a given root gets a symlink at
# ~/.<name>, e.g.  <root>/git/gitconfig.link  ->  ~/.gitconfig
#                  <root>/tmux/tmux.conf.link ->  ~/.tmux.conf
#
# Source this, then call:  link_tree "$HOME/.dotfiles"
# It is idempotent: correct links are left alone, real files are backed up
# (with confirmation), foreign links are re-pointed (with confirmation).
#
# Logging helpers (log2) come from common.sh; define a fallback so this file
# can also be sourced standalone.
type log2 >/dev/null 2>&1 || log2() { echo "--- --- $*"; }

# Back up a real file/dir sitting where a link should go. Returns 0 if the
# path is now clear to link, 1 if the user declined (skip).
check_backup_if_exists() {
  if [[ ! -L "$1" ]] && [[ -f "$1" || -d "$1" ]]; then
    echo "A file or directory was found at $1"
    read -r -p "Back it up (.bak) and link the dotfile? (y/N): " REPLY </dev/tty
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      log2 "Renaming:    $1  ->  $1.bak"
      mv "$1" "$1.bak"
      return 0
    fi
    return 1
  fi
  return 0
}

# If a link exists but points somewhere other than our target, offer to fix it.
# $1 = desired target, $2 = link path. Returns 0 if clear to (re)link, 1 to skip.
check_wrong_symlink_exists() {
  if [[ -L "$2" ]]; then
    local existing
    existing="$(readlink -- "$2")"
    if [[ "$existing" != "$1" ]]; then
      log2 "$2 is linked to $existing"
      read -r -p "Re-point it to the dotfile? (y/N): " REPLY </dev/tty
      if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        log2 "Removing link:   $2 -> $existing"
        rm -f "$2"
        return 0
      fi
      log2 "Skipping:    $2"
      return 1
    fi
  fi
  return 0
}

# $1 = target (the .link path), $2 = link name (~/.something)
attempt_link() {
  if ! check_backup_if_exists "$2"; then
    log2 "Skipping:    $2"
    return 1
  fi
  if ! check_wrong_symlink_exists "$1" "$2"; then
    return 1
  fi
  if [[ -L "$2" ]]; then
    log2 "OK link:     $2 -> $1"
  else
    log2 "Linking:     $2 -> $1"
    ln -s "$1" "$2"
  fi
  return 0
}

# Walk a tree and link every *.link entry. BSD/GNU-safe (no `grep -P`).
link_tree() {
  local root="$1"
  [[ -d "$root" ]] || { log2 "no such root, skipping: $root"; return 0; }

  # -prune the .git dir; print every *.link file/dir.
  find "$root" -name .git -prune -o -name '*.link' -print0 |
    while IFS= read -r -d '' target; do
      local base name link
      base="${target##*/}"      # strip dir
      name="${base%.link}"      # strip .link suffix  (tmux.conf.link -> tmux.conf)
      link="${HOME}/.${name}"
      attempt_link "$target" "$link" || continue
    done
}
