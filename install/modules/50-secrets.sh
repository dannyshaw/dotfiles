#!/usr/bin/env bash
# desc: Pull secrets from the homelab (profile-filtered) + link + fix perms
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LIB_DIR:=$HERE/../lib}"
# shellcheck source=../lib/common.sh
source "$LIB_DIR/common.sh"

# All the work lives in pull-secrets.sh so it can also be run standalone later.
exec "$HERE/../pull-secrets.sh"
