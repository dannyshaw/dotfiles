#!/bin/bash
set -euo pipefail

echo "--- Installing pip packages"
pip3 install -r ../pip/requirements.txt
echo "--- OK"
