# linux-bootstrap

Scripts for bootstrapping my Linux environment. The initial script
detects the distribution and runs the appropriate set of scripts.

## Supported Distributions

- Fedora
- Pop!_OS
- Ubuntu

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
