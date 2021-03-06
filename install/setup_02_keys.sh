#!/bin/bash
set -euo pipefail

APT_SOURCES=/etc/apt/sources.list.d/

# if we don't see the keys we want in .list files lets grab the keys and add the sources
echo "--- Installing apt keys"
# google chrome
if ! grep -qir --include="*.list" "deb.*dl.google.com/linux/chrome/deb/ stable main" "$APT_SOURCES"
then
  echo "--- --- installing google-chrome key"
  wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee "${APT_SOURCES}/google-chrome.list"
fi

# sublime text
if ! grep -qir --include="*.list" "deb https://download.sublimetext.com/ apt/dev/" $APT_SOURCES
then
  echo "--- --- installing sublime-text key"
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/dev/" | sudo tee "${APT_SOURCES}/sublime-text.list"
fi

# dropbox
if ! grep -qir --include="*.list" "deb.*http://linux.dropbox.com/ubuntu xenial main" $APT_SOURCES
then
  echo "--- --- installing dropbox key"
  echo "deb [arch=i386,amd64] http://linux.dropbox.com/ubuntu xenial main" | sudo tee "${APT_SOURCES}/dropbox.list"
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
fi




echo "--- Adding yarn key"
wget -qO - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add

echo "--- Adding yarn repo"
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"

echo "--- OK"
