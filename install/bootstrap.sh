#!/usr/bin/env bash
#
# bootstrap.sh — one-liner entrypoint for a fresh macOS host or Ubuntu guest.
#
#   curl -fsSL https://raw.githubusercontent.com/dannyshaw/dotfiles/master/install/bootstrap.sh | bash
#
# Installs prerequisites, clones the repo to ~/.dotfiles, ensures an SSH key,
# then hands off to the interactive installer. Idempotent and safe to re-run.
#
# This script is fetched standalone (before the repo exists) so it CANNOT source
# lib/common.sh — it carries its own minimal helpers.
set -euo pipefail

REPO_SSH="git@github.com:dannyshaw/dotfiles.git"
REPO_HTTPS="https://github.com/dannyshaw/dotfiles.git"
DOTFILES="${DOTFILES_DIR:-$HOME/.dotfiles}"
BRANCH="${DOTFILES_BRANCH:-master}"

log()  { echo "--- $*"; }
log2() { echo "--- --- $*"; }
warn() { echo "--- !!! $*" >&2; }
die()  { warn "$*"; exit 1; }

# --- detect OS -------------------------------------------------------------
case "$(uname -s)" in
  Darwin) OS=mac ;;
  Linux)  OS=ubuntu ;;
  *) die "Unsupported platform: $(uname -s)" ;;
esac
log "Bootstrapping dotfiles on: $OS"

# --- prerequisites ---------------------------------------------------------
ensure_mac_prereqs() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log2 "Installing Xcode Command Line Tools (a GUI prompt will appear)..."
    xcode-select --install || true
    log2 "Re-run this script once the Command Line Tools finish installing."
    # Don't hard-fail: git may already exist via other means.
  fi
  if ! command -v brew >/dev/null 2>&1; then
    log2 "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Put brew on PATH for the rest of this run (Apple Silicon path).
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_ubuntu_prereqs() {
  log2 "Installing base packages (git, curl, build-essential, rsync, file, procps)..."
  sudo apt-get update -qq
  # build-essential, procps, curl, file = Homebrew-on-Linux prerequisites.
  sudo apt-get install -y git curl build-essential rsync file procps
  if ! command -v brew >/dev/null 2>&1; then
    log2 "Installing Homebrew (Linuxbrew)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

case "$OS" in
  mac)    ensure_mac_prereqs ;;
  ubuntu) ensure_ubuntu_prereqs ;;
esac

command -v git >/dev/null 2>&1 || die "git is still missing — install it and re-run."

# --- clone the repo --------------------------------------------------------
if [[ -d "$DOTFILES/.git" ]]; then
  log "Repo already present at $DOTFILES (leaving it as-is)."
else
  log "Cloning dotfiles into $DOTFILES (branch: $BRANCH)..."
  if ! git clone --branch "$BRANCH" "$REPO_SSH" "$DOTFILES" 2>/dev/null; then
    log2 "SSH clone failed (no key yet?) — falling back to HTTPS."
    git clone --branch "$BRANCH" "$REPO_HTTPS" "$DOTFILES"
  fi
fi

# --- ensure an SSH key (needed later to reach the homelab + GitHub) --------
ensure_ssh_key() {
  local key="$HOME/.ssh/id_ed25519"
  if [[ -f "$key" || -f "$HOME/.ssh/id_rsa" ]]; then
    log2 "SSH key already present."
    return 0
  fi
  log2 "Generating an ed25519 SSH key..."
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -N "" -f "$key" -C "$(whoami)@$(hostname)-$OS"
  echo
  warn "Add this public key to your homelab's ~/.ssh/authorized_keys (and GitHub):"
  echo "------------------------------------------------------------------"
  cat "$key.pub"
  echo "------------------------------------------------------------------"
  echo "Press <enter> once added (or to continue without homelab access)..."
  read -r _ </dev/tty || true
}
ensure_ssh_key

# --- hand off to the interactive installer ---------------------------------
log "Launching the interactive installer..."
exec "$DOTFILES/install/install.sh"
