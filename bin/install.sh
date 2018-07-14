#!/bin/bash
set -euo pipefail

echo "Installing"
PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
run-parts --regex 'setup_*' --exit-on-error "$PWD"
echo "Done"
