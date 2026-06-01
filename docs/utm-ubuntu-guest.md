# Setting up the personal Ubuntu guest in UTM

The dotfiles install **UTM** on the mac host (`brew bundle` →
`cask "utm"` in `Brewfile.macos`). Creating the Ubuntu VM is a one-time manual
step in the UTM GUI; once it's running, the **same `curl … | bash` one-liner**
sets the guest up exactly like the host (shell, brew, dotfiles) and pulls your
**personal** secrets.

This guest is where personal stuff lives (the work host never holds it — see the
opsec model in the README/secrets docs).

## 1. Get an Ubuntu ARM64 image

This Mac is Apple Silicon, so you need an **arm64/aarch64** build:

- Ubuntu Desktop (arm64): <https://ubuntu.com/download/desktop/thank-you?version=24.04&architecture=arm64>
  (or grab the latest LTS arm64 ISO from <https://cdimage.ubuntu.com/releases/>).
- Server arm64 is fine too if you want headless; the rest of these steps assume
  you can SSH in.

## 2. Create the VM in UTM

1. UTM → **Create a New Virtual Machine** → **Virtualize** (uses Apple's fast
   Virtualization framework) → **Linux**.
2. Select the arm64 ISO you downloaded.
3. Suggested specs (tune to taste):
   - **CPU:** 4 cores
   - **RAM:** 6–8 GB
   - **Disk:** 64 GB
   - Enable **clipboard sharing** / shared directory if offered.
4. Finish, then **boot** and run the Ubuntu installer (normal install; create
   your user, set a hostname like `ubuntu-utm`).
5. After install completes, shut down, **remove the ISO** from the VM's drives so
   it boots from disk, and start it again.

## 3. Prep the guest for the one-liner

Inside the guest:

```sh
sudo apt update
sudo apt install -y openssh-server curl    # ssh-server lets the host reach it; curl for the bootstrap
sudo systemctl enable --now ssh
```

If you want the guest to pull personal secrets from the homelab, make sure its
SSH key is authorized there (the bootstrap generates one and prints it):

## 4. Run the install

```sh
curl -fsSL https://raw.githubusercontent.com/dannyshaw/dotfiles/unified/install/bootstrap.sh | bash
```

(Use `master` instead of `unified` once that branch is merged.)

It will: install Linuxbrew + the cross-platform `Brewfile`, link dotfiles, set up
the zsh/p10k/fzf/mcfly/zoxide shell, and offer the secrets pull. The profile is
auto-selected as **personal** on Ubuntu (override with `SECRETS_PROFILE=…`):

```sh
HOMELAB_HOST=<homelab-ip-or-name> ~/.dotfiles/install/pull-secrets.sh
```

## Notes

- **Clipboard / resize:** if the desktop guest doesn't share clipboard or auto-resize,
  install `spice-vdagent` (`sudo apt install -y spice-vdagent`) and reboot.
- **Shared folder:** UTM can mount a host directory into the guest — handy, but keep
  work files on the host and personal files in the guest per the opsec split.
- The guest uses Homebrew too, so its toolchain matches the host; apt is only used
  for the brew bootstrap base, `openssh-server`, and Docker Engine.
