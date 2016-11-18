#!/bin/bash

echo "Running Post Installation Script"

# everything in here should be idempotent

# install Fuzzy File Search
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  $HOME/.fzf/install
fi

if [ `echo $SHELL` != `which zsh` ]; then
  chsh -s $(which zsh)
fi

#symlink sublime text packages
ln -sf ${HOME}/.dotfiles/sublime/User ${HOME}/.config/sublime-text-3/Packages/User

source ~/.bashrc

echo "Post Installation Script Complete"
