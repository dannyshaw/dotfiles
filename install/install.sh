#!/bin/bash
set -euo pipefail

echo "Danny's Dotfiles Installation"

for step in setup*.sh
do
  # check if you wanna run each file
  read -p "Do you want to process $step? (no will skip) (yn): " -r REPLY </dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Invoking [$step]"
    # $step
  else
    echo "Skipping [$step]"
  fi
done

echo "--- That's all folks"
