#!/bin/bash
set -euo pipefail

# creates symlinks to .links in the home folder

logger() {
  echo "--- --- $1"
}

check_backup_if_exists() {
  # if a hard file exists - back it up or skip
  if [[ ! -L "$1" ]] && [[ -f "$1" || -d "$1" ]]; then
    echo "A file or directory was found at $1"
    read -p "Do you want to back it up and link the dotfile? (no will skip) (yn): " -r REPLY </dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      logger "Renaming:    $1  ->  $1.bak"
      mv "$1" "$1.bak"
      return 0
    else
      return 1
    fi
  fi
}

check_wrong_symlink_exists() {
  # if link is there but it doesnt point to dotfiles - delete it or skip
  if [[ -L "$2" ]]; then
    EXISTING_LINK_TARGET="$(readlink -- "$2")"
    if [ "$EXISTING_LINK_TARGET" != "$1" ]; then
      logger "${2} is linked to ${EXISTING_LINK_TARGET}"
      read -p "Do you want to update the link to dotfiles? (yn): " -r REPLY </dev/tty
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        logger "Removing link:   $2 -> $EXISTING_LINK_TARGET"
        rm -f "$2"
        return 0
      else
        logger "Skipping:    $2"
        return 1
      fi
    fi
  fi
}

attempt_link() {
  if ! check_backup_if_exists "$2"; then
    logger "Skipping:    $2"
    return 1
  fi

  if ! check_wrong_symlink_exists "$1" "$2" ; then
    logger "Skipping:    $2"
    return 1
  fi

  if [[ -L "$2" ]]; then
    logger "Found correct link:    $2 -> $1"
  else
    logger "Linking:  ${2}  -> ${1}"
    ln -s "$1" "$2"
  fi

  return 0
}

echo "--- Symlink all the things"
# This will find all files and directories with the extension ".link"
# .dotfiles/git/gitconfig.link will get a symlink at ~/.gitconfig
# .dotfiles/vim/vim.link will get a symlink at ~/.vim
find "${HOME}/.dotfiles/" -path "${HOME}/.dotfiles/.git" -prune -o -name "*.link" -print0 | while IFS= read -r -d $'\0' TARGET; do

  # extract just the name of the file/dir to link (cant use basename bc we need dirs too)
  # MATCH=$(echo "${TARGET}" | grep -oP "${HOME}/\.dotfiles/[\/\w+]*/\K(\w[\.\w]*)(?=\.link)")
  MATCH=$(echo "${TARGET}" | grep -oP "^.*\/\K(\w[\.\w]*)(?=\.link$)")
  LINK_NAME="${HOME}/.${MATCH}"
  if ! attempt_link "$TARGET" "$LINK_NAME"; then
    continue
  fi
done

echo "--- OK"
