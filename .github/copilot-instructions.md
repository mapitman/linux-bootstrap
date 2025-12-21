## Quick orientation

This repository contains shell scripts to bootstrap a Linux workstation across multiple distributions. The entry point is the top-level `bootstrap` script which detects the distribution using `/etc/os-release` and then sources the appropriate distro bootstrap script (for example `ubuntu/bootstrap`, `pop_os/bootstrap`, `fedora/bootstrap`, `arch/bootstrap`).

Important pattern: scripts are typically invoked by sourcing the file stream from GitHub:

  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)

Because scripts are sourced (not executed in a subshell) they run in the current shell environment and may call `exit` or change the shell state (PATH, shell, etc.). Avoid edits that assume these files are standalone executables unless the file's header or usage explicitly shows that.

## Project structure and conventions

- `bootstrap` (top-level): dispatches to a distro directory after reading `/etc/os-release`. Supports Ubuntu, Pop!_OS, Fedora, and Arch.
- `*/bootstrap` (per-distro): orchestrates other scripts in that distro folder and the shared `generic/` helpers.
- `generic/`: small reusable steps (create-ssh-key, install-jetbrains-tools, install-zsh-customizations, github-auth-login/logout, add-user-to-groups, create-directories, homebrew). Treat these as library modules that are `source`d by distro bootstrappers.
- `*/*install-*-packages` files: contain package lists and package-manager-specific commands (apt, dnf, pacman, yay). Be careful when modifying package sets — keep package-manager flags and ordering intact.
- `test/`: contains Docker and QEMU testing infrastructure for validation (primarily for Ubuntu).
- `scripts/`: helper scripts like `check.sh` for local syntax and shellcheck validation.
- `Makefile`: provides convenient targets for testing, linting, and building test images.

Examples to reference when changing behavior:
- Distribution detection: `bootstrap` (reads `/etc/os-release` and branches on `ID`).
- Arch essentials: `arch/install-essential-packages` (enables multilib, calls `pacman`, handles AUR with `yay`).
- Ubuntu interactive flow: `ubuntu/bootstrap` (prompts with `read -p` and conditionally runs dev/desktop/media installs).
- Fedora/Pop!_OS flow: similar interactive prompts for optional component installation.

## Interaction & side-effects to watch for

- Many scripts run `sudo` and install system packages. Prefer testing in an ephemeral environment (VM/container) rather than on the developer's host.
- Because scripts are sourced, `exit` will terminate the caller shell. Examples: distro `bootstrap` files call `exit 1` on mismatch — handle cautiously when refactoring or writing tests.
- Several files include interactive prompts (`read -p`) — automated edits should preserve this behavior or explicitly make non-interactive variants.

## Patterns for code changes

- Preserve the `source <(curl -fsSL ...)` style where callers expect that pattern. If you introduce an alternate execution method, add a usage comment and keep backward compatibility.
- When modifying package lists, keep package-manager specific flags (e.g., `--needed` for `pacman`, `-y`/`-qq` for `apt`) and preserve any pre-update steps (e.g., `apt-get update`).
- Reuse `generic/` helpers rather than duplicating logic across distros.
- The `lazyvim` generic helper has been removed — LazyVim setup was previously auto-installed but is no longer part of the bootstrap process.

## Testing and validation (how to be productive quickly)

### Local validation

Run the local validation script to check for bash syntax errors and shellcheck issues:

```sh
bash scripts/check.sh
```

This script:
- Finds all bash scripts (files with a bash shebang).
- Runs `bash -n` to check for syntax errors.
- Runs ShellCheck to report style and correctness issues (errors only).
- Suggests installation steps if ShellCheck is not available.

You can also use the Makefile targets:

```sh
make lint          # Run shellcheck on all scripts
make test-syntax   # Run bash -n syntax checks
make test          # Run automated Docker tests (Ubuntu)
make test-all      # Test all Ubuntu versions (24.04, 25.10)
```

### Docker testing (Ubuntu)

Quick Docker-based testing for package installation validation:

```sh
# Interactive testing
make test-interactive

# Automated testing
make test

# Test all Ubuntu versions
make test-all
```

See `test/README.md` for detailed Docker and QEMU testing instructions.

### CI checks

GitHub Actions automatically run on push/PR:
- `.github/workflows/ci.yml`: runs bash syntax checks and ShellCheck on all shell scripts
- `.github/workflows/test-ubuntu.yml`: runs Docker-based Ubuntu bootstrap tests on multiple Ubuntu versions (24.04, 25.10)

Both workflows use ShellCheck with `--severity=error` (warnings are advisory, errors block merge).

## Known issues and gaps (observations you can trust)

- **Arch bootstrap incomplete**: The `arch/bootstrap` file is sparse and noted in the README as "not fully baked yet".

## What to commit and why

- Keep commits small and focused: package list changes, distribution-specific fixes, or refactors of `generic/` helpers.
- When adding non-interactive automation, add a clearly marked `_noninteractive` variant or a flag guarded by an environment variable so the interactive default remains for humans.
- Run `bash scripts/check.sh` before committing to catch syntax errors and shellcheck issues.
- For Ubuntu changes, consider running `make test` to validate changes in Docker.

## Where to look next (files that exemplify common tasks)

### Core entry points
- `bootstrap` (root): distribution detection and routing
- `ubuntu/bootstrap`, `pop_os/bootstrap`, `fedora/bootstrap`, `arch/bootstrap`: per-distro orchestration

### Package installation examples
- `ubuntu/install-essential-packages`: apt-based package installation with proper update/upgrade flow
- `arch/install-essential-packages`: pacman and AUR (yay) package installation with multilib
- `fedora/install-packages`: dnf-based installation

### Generic helpers
- `generic/create-ssh-key`: SSH key generation pattern
- `generic/install-jetbrains-tools`: third-party tool installation (Toolbox)
- `generic/install-zsh-customizations`: shell customization setup
- `generic/homebrew`: Homebrew installation on Linux
- `generic/github-auth-login` / `generic/github-auth-logout`: GitHub CLI authentication

### Testing infrastructure
- `test/run-tests.sh`: main test runner script
- `test/docker/Dockerfile.ubuntu`: interactive Docker test image
- `test/docker/Dockerfile.ubuntu-noninteractive`: automated test image
- `test/README.md`: comprehensive testing documentation
- `Makefile`: convenient test and lint targets

If any section is unclear or you'd like the file to be more prescriptive (for example adding specific debugging techniques or extending CI capabilities), tell me which area to expand and I will iterate.
