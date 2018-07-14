#!/bin/bash
set -euo pipefail

echo "--- Update inotify max_user_watches"
if grep -Fxq "fs.inotify.max_user_watches=524288" /etc/sysctl.conf
then
	echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi
echo "--- OK"
