#!/bin/bash
set -euo pipefail

echo "--- Setting up node"

echo "--- --- Installing node version manager"

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source "$HOME"/.bashrc
nvm install lts/erbium
nvm alias default lts/erbium

# used for my custom git diff
echo "--- --- Installing npm packages"
yarn global add diff-so-fancy


# This allows node watch to monitor more than the default number of files
echo "--- --- Check inotify max_user_watches"
if ! grep -iq "fs.inotify.max_user_watches=524288" /etc/sysctl.conf
then
  echo "--- --- --- Writing to etc/sysctl.conf"
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi

echo "--- OK"


