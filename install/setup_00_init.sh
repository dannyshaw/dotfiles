#!/bin/bash
set -euo pipefail

echo "--- Updating git submodules"
git submodule update --init
echo "--- OK"
