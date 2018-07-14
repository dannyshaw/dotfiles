#!/bin/bash
set -euo pipefail

echo "--- Installing node version manager"
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source "$HOME"/.bashrc
nvm install lts/carbon
nvm install lts/boron
echo "--- OK"
