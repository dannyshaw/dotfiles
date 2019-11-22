#!/bin/bash
set -euo pipefail

echo "--- Installing snap packages"
echo "--- Installing Spotify"
sudo snap install spotify

echo "--- Installing Slack"
sudo snap install slack --classic

echo "--- Installing Heroku CLI"
sudo snap install heroku --classic

echo "--- Installing Github Desktop"
sudo snap install github-desktop --classic --beta

echo "--- OK"
