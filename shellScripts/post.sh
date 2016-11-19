#!/bin/bash

echo "Running Post Installation Script"

# everything in here should be idempotent

# install oh my zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
fi

# install Fuzzy File Search
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  $HOME/.fzf/install
fi

if [ `echo $SHELL` != `which zsh` ]; then
  chsh -s $(which zsh)
fi

#symlink sublime text packages
if [ ! -d "${HOME}/.config/sublime-text-3/Packages" ]; then
  mkdir -p ${HOME}/.config/sublime-text-3/Packages
fi

if [ ! -d "${HOME}/.config/sublime-text-3/Packages/User" ]; then
  mv ${HOME}/.config/sublime-text-3/Packages/User ${HOME}/.config/sublime-text-3/Packages/User.bak
fi

ln -sf ${HOME}/.dotfiles/sublime/User ${HOME}/.config/sublime-text-3/Packages/User

source ~/.bashrc

echo "Post Installation Script Complete"
