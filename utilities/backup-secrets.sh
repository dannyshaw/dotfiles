#!/usr/bin/env bash
#
# backup-secrets.sh — collect everything irreplaceable on this machine into a
# single age-encrypted tarball before a wipe.
#
# Usage:
#   ./backup-secrets.sh            # build encrypted bundle in $HOME, copy to Dropbox
#   ./backup-secrets.sh --dry-run  # just print what WOULD be collected, no archive
#
# Restore later (on a clean Mac or Ubuntu VM):
#   brew install age   # or: sudo apt install age
#   age -d secrets-backup-YYYY-MM-DD.tar.age | tar -xvf - -C /tmp/restore
#
# You will be prompted for a passphrase. Choose a strong one and store it in
# your password manager. The passphrase is never written to disk or echoed.

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

DATE="$(date +%Y-%m-%d)"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/secrets-backup.XXXXXX")"
OUT="$HOME/secrets-backup-${DATE}.tar.age"
DROPBOX="$HOME/Library/CloudStorage/Dropbox"
MANIFEST="$STAGE/MANIFEST.txt"

cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

echo "# Secrets backup manifest — $DATE" > "$MANIFEST"
echo "# Files collected (paths relative to \$HOME):" >> "$MANIFEST"
echo >> "$MANIFEST"

# Copy a file or directory into the staging area, preserving its path under $HOME.
stage() {
  local src="$1"
  [[ -e "$src" ]] || return 0
  local rel="${src#"$HOME"/}"
  local dest="$STAGE/home/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "  $rel" >> "$MANIFEST"
  echo "  staged: $rel"
}

echo ">>> Collecting secrets & unmanaged config into staging..."

# --- SSH (whole dir, minus stray node_modules/test cruft) ---
if [[ -d "$HOME/.ssh" ]]; then
  mkdir -p "$STAGE/home/.ssh"
  rsync -a --exclude 'node_modules' --exclude 'test' --exclude 'agent' "$HOME/.ssh/" "$STAGE/home/.ssh/" 2>/dev/null \
    || cp -a "$HOME/.ssh/." "$STAGE/home/.ssh/"
  echo "  .ssh/ (excluding node_modules,test)" >> "$MANIFEST"
  echo "  staged: .ssh/"
fi

# --- Cloud credentials ---
stage "$HOME/.aws/credentials"
stage "$HOME/.aws/config"
stage "$HOME/.docker/config.json"
stage "$HOME/.docker/.token_seed"

# --- API / OAuth tokens ---
stage "$HOME/.config/gh/hosts.yml"
stage "$HOME/.config/gh/config.yml"
stage "$HOME/.claude.json"
stage "$HOME/.gmail-mcp/credentials.json"
stage "$HOME/.config/google-calendar-mcp/tokens.json"
stage "$HOME/.amux/tls"
stage "$HOME/.mcp-auth"
stage "$HOME/.codex/auth.json"

# --- Unmanaged shell config (not in dotfiles yet) ---
stage "$HOME/.zprofile"
stage "$HOME/.zshenv"
stage "$HOME/.zshrc.local"
stage "$HOME/.edrolosecretsrc"

# NOTE: ~/dev is intentionally NOT collected here — it is backed up wholesale
# as a separate tarball and restored directly onto the new machine.

echo
echo ">>> Manifest:"
cat "$MANIFEST"
echo
FILECOUNT=$(find "$STAGE/home" -type f 2>/dev/null | wc -l | tr -d ' ')
echo ">>> $FILECOUNT files staged."

if $DRY_RUN; then
  echo ">>> DRY RUN — no archive written. Re-run without --dry-run to encrypt."
  exit 0
fi

if ! command -v age >/dev/null 2>&1; then
  echo "!!! 'age' not installed. Run: brew install age   (then re-run this script)" >&2
  exit 1
fi

if [ -t 0 ] && [ -t 1 ]; then
  # Interactive terminal: passphrase mode (decrypt with: age -d FILE)
  echo ">>> Creating encrypted bundle (you will be prompted for a passphrase)..."
  tar -C "$STAGE" -cf - . | age -p > "$OUT"
else
  # Headless (run by an agent/cron): keypair mode (decrypt with: age -d -i KEYFILE FILE)
  KEYFILE="$HOME/secrets-backup-${DATE}.age-key.txt"
  [ -f "$KEYFILE" ] || age-keygen -o "$KEYFILE" 2>/dev/null
  chmod 600 "$KEYFILE"
  PUB="$(awk '/public key:/ {print $NF}' "$KEYFILE")"
  echo ">>> Headless mode — encrypting to generated key: $KEYFILE"
  tar -C "$STAGE" -cf - . | age -r "$PUB" > "$OUT"
  echo "!!! ============================================================"
  echo "!!! IDENTITY KEY: $KEYFILE"
  echo "!!! The bundle CANNOT be decrypted without this key file."
  echo "!!! Save it separately (password manager) AND it will be copied"
  echo "!!! to Dropbox/network drive alongside the bundle is NOT enough"
  echo "!!! on its own — store the key somewhere the bundle is NOT."
  echo "!!! ============================================================"
fi
chmod 600 "$OUT"
echo ">>> Wrote $OUT ($(du -h "$OUT" | cut -f1))"

if [[ -d "$DROPBOX" ]]; then
  cp "$OUT" "$DROPBOX/"
  echo ">>> Copied to Dropbox: $DROPBOX/$(basename "$OUT")"
fi

echo
echo ">>> DONE. Next steps:"
echo "    1. Copy $OUT to an external drive when plugged in."
echo "    2. Verify it decrypts:  age -d $OUT | tar -tf - | head"
echo "    3. Store the passphrase in your password manager."
echo "    4. Rotate the leaked GEMINI/ANTHROPIC/OPENAI keys (they're in public git history)."
