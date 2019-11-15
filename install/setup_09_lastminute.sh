#!/bin/bash

set -eou pipefail

# add udev rules for ledger
wget -q -O - https://raw.githubusercontent.com/LedgerHQ/udev-rules/master/add_udev_rules.sh | sudo bash

dropbox start -i
