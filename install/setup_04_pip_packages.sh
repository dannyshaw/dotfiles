#!/bin/bash
set -euo pipefail

echo "--- Installing pip packages"
sudo pip3 install -r "$PWD"/../pip/requirements.txt
echo "--- OK"
