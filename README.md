# linux-bootstrap

Scripts for bootstrapping my Linux environment. The initial script
detects the distribution and runs the appropriate set of scripts.

## Supported Distributions

- Arch
- Fedora
- Omarchy
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

## Omarchy

[Omarchy](https://omarchy.org) is a custom installer on top of Arch

To perform a full bootstrap from a clean Omarchy install, do:

```sh
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```

## Ubuntu or Pop!_OS

To perform a full bootstrap from a clean Ubuntu or Pop!_OS install do:

```sh
sudo apt-get update && sudo apt-get install -y curl git && \
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/bootstrap)
```
