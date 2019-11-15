#!/bin/bash
set -euo pipefail

SNAP_PACKAGES="\
    spotify \
"

SNAP_BETA_PACKAGES="\
    github-desktop \
"

SNAP_CLASSIC_PACKAGES="\
    slack \
    heroku \
"
echo "--- Installing snap packages"
echo "$SNAP_PACKAGES" | tr " " "\n" | awk '{print "--- --- " $0}'
sudo snap install $SNAP_PACKAGES
echo "beta"
echo "$SNAP_BETA_PACKAGES" | tr " " "\n" | awk '{print "--- --- " $0}'
sudo snap install $SNAP_BETA_PACKAGES --beta
echo "classic"
echo "$SNAP_CLASSIC_PACKAGES" | tr " " "\n" | awk '{print "--- --- " $0}'
sudo snap install $SNAP_CLASSIC_PACKAGES --classic
echo "--- OK"
