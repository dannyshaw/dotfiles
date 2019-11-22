#!/bin/bash

set -eou pipefail

# add udev rules for ledger
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

dropbox start -i

sudo apt remove -y gnome-shell-extension-ubuntu-dock


echo "--- Linking Autostart Config"
export AUTOSTART_CONFIG="${HOME}/.config/autostart"
export DOTFILES_AUTOSTART="${HOME}/.dotfiles/autostart"

# if the link isn't there but a hard user folder is there - back it up
if [[ ! -L "${AUTOSTART_CONFIG}" && -d "${AUTOSTART_CONFIG}" ]]; then
  echo "--- --- Backing up an existing autostart config"
  mv  "${AUTOSTART_CONFIG}" "${AUTOSTART_CONFIG}.bak"
fi

# if link is there but it doesnt point to dotfiles - remove it
if [[ -L "$AUTOSTART_CONFIG" ]]; then
  LINK_TARGET="$(readlink -- "$AUTOSTART_CONFIG")"
  if [ "$LINK_TARGET" != "$DOTFILES_AUTOSTART" ]; then
    echo "--- --- !!! WARNING !!! Foreign User Package Points to '$LINK_TARGET'"
    echo "--- --- !!! WARNING !!! Removing Symlink"
    rm -f "$AUTOSTART_CONFIG"
  fi
fi

# ensure symlink dotfiles config  to sublime config
if [[ ! -L "${AUTOSTART_CONFIG}" ]]; then
    echo "--- --- Symlinking to dotfiles user packages"
  ln -sf "${DOTFILES_AUTOSTART}" "${AUTOSTART_CONFIG}"
fi
echo "--- OK"
