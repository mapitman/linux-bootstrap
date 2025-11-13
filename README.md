# linux-bootstrap

Scripts for bootstrapping my Linux environment. The initial script
detects the distribution and runs the appropriate set of scripts.

## Supported Distributions

- Arch
- Fedora
- Pop!_OS
- Ubuntu

## Arch

_Note: this is not fully baked yet._ 

To perform a full bootstrap from a minimal Arch install do:

```sh
sudo pacman -S curl && \
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```

## Fedora

To perform a full bootstrap from a clean Fedora install do:

```sh
sudo dnf install curl && \
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```

## Ubuntu or Pop!_OS

To perform a full bootstrap from a clean Ubuntu or Pop!_OS install do:

```sh
sudo apt-get update && sudo apt-get install -y curl git && \
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```

## Contributing

### Local Validation

Before submitting changes, run the local validation script to check for bash syntax errors and shellcheck issues:

```sh
bash scripts/check.sh
```

This script:
- Finds all bash scripts (files with a bash shebang).
- Runs `bash -n` to check for syntax errors.
- Runs ShellCheck to report style and correctness issues.
- Suggests installation steps if ShellCheck is not available.

### ShellCheck Installation

If ShellCheck is not installed, run one of the following depending on your distribution:

```sh
# Debian/Ubuntu/Pop!_OS
sudo apt-get update && sudo apt-get install -y shellcheck

# Fedora
sudo dnf install -y ShellCheck

# Arch
sudo pacman -S shellcheck
```

### CI Checks

When you open a pull request or push to the repository, GitHub Actions will automatically run:
- **Syntax checks** (`bash -n`) on all shell scripts.
- **ShellCheck** with error-level severity (warnings are advisory, errors block the merge).

See [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for detailed guidance on project patterns and conventions.
