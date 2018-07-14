#!/bin/bash
set -euo pipefail

APT_PACKAGES="\
    apt-transport-https \
    apt-file \
    awscli \
    build-essential \
    curl \
    git \
    google-chrome-stable \
    gparted \
    htop \
    jq \
    keepassx \
    libgeoip-dev \
    lynx \
    meld \
    openvpn \
    postgresql-contrib-9.6 \
    postgresql-9.6 \
    powertop \
    python-dev \
    python-pip \
    python3-dev \
    python-gpgme \
    redis-server \
    ruby \
    silversearcher-ag \
    shellcheck \
    sublime-text \
    tmux \
    unetbootin \
    vim \
    xclip \
    yarn \
    zsh \
"

echo "--- Updating apt sources"
sudo apt-get update --quiet | awk '{print "--- --- " $0}'
echo "--- OK"
echo "--- Installing apt packages"
echo "$APT_PACKAGES" | tr " " "\n" | awk '{print "--- --- " $0}'
sudo apt-get install -y "$APT_PACKAGES" --quiet
echo "--- OK"
