#!/bin/bash
set -euo pipefail

echo "--- Installing oh my zsh and setting shell"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME"/.oh-my-zsh
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi
echo "--- OK"
