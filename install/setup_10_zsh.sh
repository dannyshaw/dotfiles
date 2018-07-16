#!/bin/bash
set -euo pipefail

echo "--- Setting up zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  echo 'run "chsh -s $(which zsh)", logout and in, then run again'
  exit 1
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "--- --- Installing oh my zsh"
  	git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME"/.oh-my-zsh
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel9k" ]; then
	echo "--- --- Installing powerlevel theme"
	git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
fi

if [ ! -d "$HOME/.powerline" ]; then
	echo "--- --- Installing powerline fonts"
	git clone https://github.com/powerline/fonts.git ~/.powerline
  echo "--- probably best close and reopen terminals"
fi

echo "--- OK"
