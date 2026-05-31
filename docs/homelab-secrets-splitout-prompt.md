# Homelab secrets split-out prompt

Run this **on the homelab** (where your mixed secrets/dotdirs currently live) by
pasting the prompt below into Claude Code. It reorganizes the bundle into
`work / personal / shared` trees that a fresh machine can pull with
`install/pull-secrets.sh` (mac host pulls `work`+`shared`; Ubuntu UTM guest pulls
`personal`+`shared`).

It does **not** push anything to GitHub — the homelab stays the canonical store.

---

## The prompt

> You are organizing my secrets/config bundle on this homelab into a structure my
> dotfiles can pull from. **Do not delete or move originals until I confirm** — work
> in a new directory `~/dotfiles-secrets/` and copy into it.
>
> **Context — opsec model:**
> - My **macOS work host** pulls the `work` + `shared` trees.
> - My **Ubuntu UTM guest** (personal) pulls the `personal` + `shared` trees.
> - The work host must never receive personal credentials, and vice-versa.
>
> **Step 1 — Inventory.** Find the secret/config material I currently keep
> (typical locations: `~/.ssh`, `~/.aws`, `~/.config/gh`, `~/.config/*/tokens`,
> `~/.claude.json`, `~/.edrolosecretsrc`, `~/.p10k.zsh`, `~/.gnupg`, VPN configs,
> any `*secret*`/`*token*`/`*credential*` files, app config dirs). List each path
> with a one-line description and your guess of size/sensitivity. Use my dotfiles'
> `utilities/backup-secrets.sh` list as a starting seed if it's available.
>
> **Step 2 — Classify.** For each path propose a class:
> - `work` — edrolo / job credentials (AWS work creds, work SSH keys, gh work token,
>   `.edrolosecretsrc`, work VPN).
> - `personal` — personal accounts, personal SSH keys, personal cloud, etc.
> - `shared` — non-sensitive-but-handy config used everywhere (`.p10k.zsh`,
>   ssh `known_hosts`, base ssh `config`, editor state).
> Show me the proposed classification as a table and **ask me to confirm or correct
> anything ambiguous before you copy.** Anything you genuinely can't classify goes
> to `shared/UNCLASSIFIED/` for me to sort by hand — never default it to `work`.
>
> **Step 3 — Build the trees.** Create:
> ```
> ~/dotfiles-secrets/
>   work/       personal/       shared/
>   secrets.manifest
> ```
> Layout rules inside each `<class>/`:
> - **Standalone secret file/dir** → name it with the `.link` convention so my
>   symlinker picks it up: e.g. `.edrolosecretsrc` → `work/edrolosecretsrc.link`,
>   `~/.aws/credentials` → `work/aws/credentials` (see SSH/mixed-dir rule next).
> - **Mixed dirs** (`~/.ssh`, `~/.aws` — config is harmless, keys/creds are secret):
>   put the individual files under a per-class `ssh/` (or `aws/`) subtree, NOT a
>   whole-dir `.link`. For SSH specifically:
>     - private keys (`id_*` without `.pub`) → the owning class (`work`/`personal`)
>       under `ssh/`
>     - `known_hosts`, base `config` → `shared/ssh/`
>     - per-class host aliases → `<class>/ssh/config.d/<class>`
>   My `pull-secrets.sh` merges every pulled `ssh/` subtree into `~/.ssh` and fixes
>   perms, and a base `~/.ssh/config` should `Include ~/.ssh/config.d/*`.
> - Preserve permissions when copying (`cp -a`).
>
> **Step 4 — Manifest.** Write `~/dotfiles-secrets/secrets.manifest` as lines of
> `<class>\t<original path>\t<destination in tree>` so the split is auditable and
> repeatable.
>
> **Step 5 — Lock it down.** `chmod -R go-rwx ~/dotfiles-secrets`. Print a summary:
> counts per class, anything quarantined, and the exact `pull-secrets.sh` env vars
> I'll use from a fresh machine (`HOMELAB_HOST`, `HOMELAB_USER`,
> `HOMELAB_SECRETS_DIR=dotfiles-secrets`).

---

## After it runs

From a fresh machine (once its SSH key is in the homelab's `authorized_keys`):

```sh
HOMELAB_HOST=<homelab-ip-or-name> ~/.dotfiles/install/pull-secrets.sh
# profile is auto: mac=work, ubuntu=personal. Override with SECRETS_PROFILE=...
```
