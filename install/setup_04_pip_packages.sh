#!/bin/bash
set -euo pipefail

echo "--- Installing pip packages"
pip3 install -r "$PWD"/../pip/requirements.txt
echo "--- OK"
