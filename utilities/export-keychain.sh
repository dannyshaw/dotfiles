#!/usr/bin/env bash
#
# export-keychain.sh — dump the macOS login keychain (passwords, secure notes,
# generic/internet credentials) to a plaintext export, then encrypt it with an
# age passphrase you choose. Lets you keep the contents WITHOUT restoring the
# binary keychain onto a new machine.
#
# Run this YOURSELF in Terminal (not via an agent): macOS shows a GUI auth
# dialog per item — click "Always Allow" to power through them.
#
#   ./export-keychain.sh
#
# Output: ~/keychain-export-YYYY-MM-DD.txt.age  (decrypt later with: age -d FILE)
#
# Restore/read later (any machine with age):
#   age -d keychain-export-YYYY-MM-DD.txt.age > keychain.txt   # then read, then shred
#
# The plaintext dump is written to a temp file, encrypted, then overwritten and
# deleted. Nothing unencrypted is left behind.

set -euo pipefail

KC="${1:-$HOME/Library/Keychains/login.keychain-db}"
DATE="$(date +%Y-%m-%d)"
OUT="$HOME/keychain-export-${DATE}.txt.age"
TMP="$(mktemp "${TMPDIR:-/tmp}/kcdump.XXXXXX")"

cleanup() { rm -P "$TMP" 2>/dev/null || rm -f "$TMP"; }   # rm -P overwrites (BSD)
trap cleanup EXIT

command -v age >/dev/null || { echo "age not installed: brew install age" >&2; exit 1; }
[ -f "$KC" ] || { echo "keychain not found: $KC" >&2; exit 1; }

echo ">>> Unlocking keychain (enter your macOS login password if prompted)..."
security unlock-keychain "$KC"

echo ">>> Dumping decrypted contents..."
echo "    You will get a GUI dialog PER ITEM. Click 'Always Allow' to speed through."
security dump-keychain -d "$KC" > "$TMP"

ITEMS=$(grep -c '^keychain:' "$TMP" 2>/dev/null || echo "?")
echo ">>> Dumped ($(wc -l < "$TMP") lines). Encrypting with a passphrase you choose..."
age -p -o "$OUT" "$TMP"
chmod 600 "$OUT"

echo ">>> Wrote $OUT ($(du -h "$OUT" | cut -f1))"
echo ">>> Plaintext temp shredded. Store the passphrase in your password manager."
echo ">>> Copy $OUT somewhere safe (Dropbox / valoniahost / external)."
