#!/bin/bash
set -euo pipefail

DOCKER_COMPOSE_VERSION="1.21.2" # This needs to be manually updated

echo "--- Installing docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Switch to stable after Just 2018, docker-ce will be avail for 18.04 then
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  edge"

sudo apt update
sudo apt install -y docker-ce

echo "--- Installing docker-compose"
sudo curl -L \
  https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
  -o /usr/local/bin/docker-compose

sudo chmod 755 /usr/local/bin/docker-compose
echo "--- OK"
