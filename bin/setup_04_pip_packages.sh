#!/bin/bash
set -euo pipefail

echo "--- Installing pip packages"
pip install -r ../pip/requirements.txt
echo "--- OK"
