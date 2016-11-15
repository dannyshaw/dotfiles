#!/bin/bash

#install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install 6.0.0

sudo apt-get install git

git clone https://github.com/dannyshaw/dotfiles.git $HOME/.dotfiles

cd $HOME/.dotfiles

kody


