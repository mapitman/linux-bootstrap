## Quick orientation

This repository contains shell scripts to bootstrap a Linux workstation across multiple distributions. The entry point is the top-level `bootstrap` script which detects the distribution using `/etc/os-release` and then sources the appropriate distro bootstrap script (for example `ubuntu/bootstrap`, `pop_os/bootstrap`, `fedora/bootstrap`, `arch/bootstrap`).

Important pattern: scripts are typically invoked by sourcing the file stream from GitHub:

  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)

Because scripts are sourced (not executed in a subshell) they run in the current shell environment and may call `exit` or change the shell state (PATH, shell, etc.). Avoid edits that assume these files are standalone executables unless the file's header or usage explicitly shows that.

## Project structure and conventions

- `bootstrap` (top-level): dispatches to a distro directory after reading `/etc/os-release`.
- `*/bootstrap` (per-distro): orchestrates other scripts in that distro folder and the shared `generic/` helpers.
- `generic/`: small reusable steps (create-ssh-key, install-jetbrains-tools, install-zsh-customizations, lazyvim, etc.). Treat these as library modules that are `source`d by distro bootstrappers.
- `*/*install-*-packages` files: contain package lists and package-manager-specific commands (apt, dnf, pacman, yay). Be careful when modifying package sets — keep package-manager flags and ordering intact.

Examples to reference when changing behavior:
- Distribution detection: `bootstrap` (reads `/etc/os-release` and branches on `ID`).
- Arch essentials: `arch/install-essential-packages` (enables multilib, calls `pacman`, handles AUR with `yay`).
- Ubuntu interactive flow: `ubuntu/bootstrap` (prompts with `read -p` and conditionally runs dev/desktop/media installs).

## Interaction & side-effects to watch for

- Many scripts run `sudo` and install system packages. Prefer testing in an ephemeral environment (VM/container) rather than on the developer's host.
- Because scripts are sourced, `exit` will terminate the caller shell. Examples: distro `bootstrap` files call `exit 1` on mismatch — handle cautiously when refactoring or writing tests.
- Several files include interactive prompts (`read -p`) — automated edits should preserve this behavior or explicitly make non-interactive variants.

## Patterns for code changes

- Preserve the `source <(curl -fsSL ...)` style where callers expect that pattern. If you introduce an alternate execution method, add a usage comment and keep backward compatibility.
- When modifying package lists, keep package-manager specific flags (e.g., `--needed` for `pacman`, `-y`/`-qq` for `apt`) and preserve any pre-update steps (e.g., `apt-get update`).
- Reuse `generic/` helpers rather than duplicating logic across distros.

## Testing and validation (how to be productive quickly)

- Quick lint: run `bash -n <script>` to check syntax.
- Static checks: run `shellcheck` (recommended) on changed scripts.
- Safe manual test: start a disposable VM or container for the target distribution and run the top-level `source <(...)` or the distro `bootstrap` directly.

## Known issues and fragile areas (observations you can trust)

- The top-level `bootstrap` contains a malformed `elif` for the `arch` branch (missing spacing around `[[`), and `pop_os/bootstrap` contains a garbled line in the optical-disc install section. Be conservative when editing these lines — tests and a VM run are recommended.

## What to commit and why

- Keep commits small and focused: package list changes, distribution-specific fixes, or refactors of `generic/` helpers.
- When adding non-interactive automation, add a clearly marked `_noninteractive` variant or a flag guarded by an environment variable so the interactive default remains for humans.

## Where to look next (files that exemplify common tasks)

- `bootstrap` (root)
- `ubuntu/bootstrap`, `pop_os/bootstrap`, `fedora/bootstrap`, `arch/bootstrap`
- `generic/create-ssh-key`, `generic/install-jetbrains-tools`, `arch/install-essential-packages`, `ubuntu/install-essential-packages`

If any section is unclear or you'd like the file to be more prescriptive (for example adding linting CI or a non-interactive test harness), tell me which area to expand and I will iterate.
