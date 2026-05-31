# dotfiles

Cross-platform dotfiles for **macOS** (work host) and **Ubuntu** (personal UTM
guest). Public repo — it holds only non-secret config; secrets live on the
homelab and are pulled separately (see below).

## Install (fresh machine)

One line, works on macOS or Ubuntu:

```sh
curl -fsSL https://raw.githubusercontent.com/dannyshaw/dotfiles/master/install/bootstrap.sh | bash
```

It installs prerequisites (Homebrew on macOS / apt essentials on Ubuntu), clones
this repo to `~/.dotfiles`, ensures an SSH key, then launches an **interactive
installer** that lets you pick what to set up. Already cloned? Just run
`~/.dotfiles/install/install.sh`.

## How it works

- **`.link` convention** — anything named `*.link` is symlinked into `$HOME` as
  `~/.<name>`: `vim/vim.link → ~/.vim`, `zsh/zshrc.link → ~/.zshrc`,
  `tmux/tmux.conf.link → ~/.tmux.conf`. The symlinker (`install/lib/symlink.sh`)
  backs up real files and re-points stray links, and is idempotent.

- **Modules** — `install/modules/*.sh`. Platform is encoded in the filename
  (`foo.mac.sh`, `foo.ubuntu.sh`, or `foo.sh` = both); the installer hides
  modules that don't apply to the current OS and lets you multi-select the rest.
  Add a module by dropping a script in there with a `# desc:` header line.

- **Shell** — zsh + [powerlevel10k] prompt + [antidote] plugin manager, with
  `fzf` / `mcfly` / `zoxide` wired in. Plugins are listed in
  `zsh/zsh_plugins.txt.link`. Prompt config lives in `~/.p10k.zsh`
  (`p10k configure` to regenerate).

- **Python** — [`uv`] for tools and venvs (no pip/virtualenvwrapper). Tool list:
  `install/uv-tools.txt`.

## Secrets (homelab)

Secrets are **never** committed here. The homelab is the canonical store,
pre-sorted into `work` / `personal` / `shared` trees. A fresh machine pulls only
its profile + shared over SSH:

```sh
HOMELAB_HOST=<homelab> ~/.dotfiles/install/pull-secrets.sh
# profile auto-selected: mac=work, ubuntu=personal (override SECRETS_PROFILE)
```

To produce those trees from a mixed bundle, run
[`docs/homelab-secrets-splitout-prompt.md`](docs/homelab-secrets-splitout-prompt.md)
with Claude **on the homelab**. `utilities/backup-secrets.sh` makes an offline
age-encrypted cold backup.

[powerlevel10k]: https://github.com/romkatv/powerlevel10k
[antidote]: https://github.com/mattmc3/antidote
[`uv`]: https://github.com/astral-sh/uv
