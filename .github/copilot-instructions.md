## Purpose

Linux workstation bootstrap scripts for Ubuntu, Debian, Pop!_OS, Fedora, and Arch.

Primary entrypoint:

```sh
source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```

Scripts are sourced into the current shell, not executed in a subshell.

## Core Rules

- Keep the `source <(curl -fsSL ...)` usage pattern compatible.
- Treat scripts as sourced modules: `exit` in a sourced script exits the caller shell.
- Preserve distro-specific package manager flags and update/upgrade flow.
- Reuse `generic/` helpers instead of duplicating logic.
- Preserve interactive prompts unless adding an explicit non-interactive variant.
- For Debian-based distros, prefer `apt-get` for scripting and CI, since `apt` is primarily a user-facing tool that may prompt for input or have different output formatting.
- For Debian-based distros, share scripts where possible using symlinked files, since the underlying package management is the same and there is no need to duplicate scripts that would be identical across distros.
- For Arch and Fedora, which have more differences in package management and available packages, keep separate scripts without symlinks.

## Key Structure

- `bootstrap`: routes by `/etc/os-release` `ID`.
- `ubuntu/bootstrap`, `debian/bootstrap`, `pop_os/bootstrap`, `fedora/bootstrap`, `arch/bootstrap`: distro orchestrators.
- `generic/`: shared helpers (ssh key, zsh customizations, eza themes, groups, directories, GitHub auth, homebrew, toolbox).
- `test/`: Docker/QEMU testing infra.
- `scripts/check.sh`: repo-wide syntax + shellcheck (error-level) checks.

## Current Behavior Notes

- Multiple distro bootstraps include optional prompt-driven install steps (for example desktop/media/dev components).
- Arch bootstrap is still incomplete.

## Validate Changes

Primary check:

```sh
bash scripts/check.sh
```

Useful Make targets:

```sh
make test-syntax
make lint
make test
make test-all
make test-debian
make test-debian-all
```

## CI Workflows

- `.github/workflows/ci.yml`: bash syntax + shellcheck checks.
- `.github/workflows/test-ubuntu.yml`: Ubuntu Docker tests (24.04, 25.10).
- `.github/workflows/test-debian.yml`: Debian Docker tests (bookworm, trixie).

## Commit Messages

- Use imperative present tense in the subject line (for example `Add Debian desktop packages script`).
- Keep the subject line concise (about 50-72 chars) and specific to one change.
- Prefix with scope when useful (for example `debian:`, `test:`, `ci:`, `generic:`).
- In the body, explain why a change was made, especially for package additions/removals or behavior changes.
- Mention validation steps run when relevant (for example `bash scripts/check.sh`, `make test-debian`).

## High-Value Files

- `bootstrap`
- `ubuntu/bootstrap`
- `debian/bootstrap`
- `ubuntu/install-essential-packages`
- `debian/install-packages`
- `debian/install-desktop-packages`
- `arch/install-essential-packages`
- `fedora/install-packages`
- `test/run-tests.sh`
- `test/docker/Dockerfile.ubuntu-noninteractive`
- `test/docker/Dockerfile.debian-noninteractive`
