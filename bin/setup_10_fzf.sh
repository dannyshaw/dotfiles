#!/bin/bash
set -euo pipefail

echo "--- Install Fuzzy File Search"
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME"/.fzf
  "$HOME"/.fzf/install
fi
echo "--- OK"

