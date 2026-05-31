# macOS Apps Inventory (captured 2026-05-31, pre-wipe)

Companion to `install/Brewfile` (generated via `brew bundle dump --describe`).
Ranked by real usage from Spotlight (`kMDItemLastUsedDate` / `kMDItemUseCount`).

Reinstall everything brew-managed with:

    brew bundle --file=install/Brewfile

## Daily drivers (high use / recent)

| App | Uses | Source | In Brewfile? |
|---|---|---|---|
| Google Chrome | 34,884 | direct | ❌ → `cask "google-chrome"` |
| iTerm | 16,807 | direct | ❌ → `cask "iterm2"` |
| Slack | 2,112 | direct | ❌ → `cask "slack"` |
| GitHub Desktop | 1,582 | direct | ❌ → `cask "github"` |
| Windsurf | 705 | direct | ❌ → `cask "windsurf"` |
| Obsidian | 595 | brew-cask | ✅ |
| Ghostty | 303 | brew-cask | ✅ |
| Meld | 237 | brew-cask | ✅ |
| Telegram | 184 | direct | ❌ → `cask "telegram"` |
| Session | 184 | direct | ❌ → `cask "session"` |
| Tailscale | 86 | direct | ❌ → `cask "tailscale"` |
| VLC | 81 | direct | ❌ → `cask "vlc"` |
| OrbStack | 67 | brew-cask | ✅ |
| VibeTunnel | 65 | direct | ❌ |
| Notion | 55 | brew-cask | ✅ |
| **Raycast** | 30* | direct | ❌ → `cask "raycast"` |
| ActivityWatch | 26 | direct | ❌ |

\* Raycast's low count is misleading — it's an always-running launcher (daily driver per Danny), not re-launched. Config already backed up in `config-history` tarball.

## Used less recently / occasional

Notion Calendar (cask ✅), KeePassX (cask ✅), UnnaturalScrollWheels (cask ✅),
noTunes (cask ✅), AeroSpace (cask ✅), OpenOats (cask ✅), Zed (direct),
Docker (direct — superseded by OrbStack?), UTM (direct — for the Ubuntu VM),
Transmission, OpenMTP, Brave Browser, ChatGPT Atlas, Wispr Flow, Cluely, Claude.

## App Store apps (need `mas` to script reinstall)

- WhatsApp (App Store)
- `mas` is NOT installed → `brew "mas"` then `mas list` to capture IDs.

## Not in Brewfile but should be (ready-to-add casks)

These daily/regular apps were installed manually; add to Brewfile for reproducible setup:

    cask "google-chrome"
    cask "iterm2"
    cask "slack"
    cask "github"
    cask "windsurf"
    cask "telegram"
    cask "session"
    cask "tailscale"
    cask "vlc"
    cask "raycast"
    cask "zed"
    cask "brave-browser"

## Cleanup candidates (duplicates / never used)

- `Visual Studio Code 2`, `GitHub Desktop 2` — duplicate installs (the " 2" suffix)
- Never-launched: OnyX, Ledger Live, Conductor, BetterZip, Suspicious Package, QLMarkdown
- Microsoft Office suite (Word/Excel/PowerPoint/Outlook/OneNote) — never launched per Spotlight; decide if needed on the new Mac.
