#!/bin/bash
set -euo pipefail

echo "--- Linking Sublime Text User Packages"
# export SUBLIME_PACKAGES="${HOME}/.test/sublime-text-3/Packages"
export SUBLIME_PACKAGES="${HOME}/.config/sublime-text-3/Packages"
export USER_PACKAGES="${SUBLIME_PACKAGES}/User"
export DOTFILES_USER_PACKAGES="${HOME}/.dotfiles/sublime/User"

# ensure config folder exists
if [ ! -d "$SUBLIME_PACKAGES" ]; then
  echo "--- --- Creating sublime config folder"
  mkdir -p "$SUBLIME_PACKAGES"
fi

# if the link isn't there but a hard user folder is there - back it up
if [[ ! -L "${USER_PACKAGES}" && -d "${USER_PACKAGES}" ]]; then
  echo "--- --- Backing up an existing sublime config"
  mv  "${USER_PACKAGES}" "${USER_PACKAGES}.bak"
fi

# if link is there but it doesnt point to dotfiles - back it up
if [[ -L "$USER_PACKAGES" ]]; then
	LINK_TARGET="$(readlink -- "$USER_PACKAGES")"
	if [ "$LINK_TARGET" != "$DOTFILES_USER_PACKAGES" ]; then
		echo "--- --- !!! WARNING !!! Foreign User Package Points to '$LINK_TARGET'"
		echo "--- --- !!! WARNING !!! Removing Symlink"
		rm -f "$USER_PACKAGES"
	fi
fi

# ensure symlink dotfiles config  to sublime config
if [[ ! -L "${USER_PACKAGES}" ]]; then
    echo "--- --- Symlinking to dotfiles user packages"
	ln -sf "${DOTFILES_USER_PACKAGES}" "${USER_PACKAGES}"
fi
echo "--- OK"
