# linux-bootstrap

Scripts for bootstrapping my Linux environment. The initial script
detects the distribution and runs the appropriate set of scripts.

## Supported Distributions

- Ubuntu

To perform a full bootstrap from a clean Ubuntu install do:

```sh
sudo apt update && sudo apt upgrade -y && sudo apt install -y curl git && \
  source <(curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/initial-dev/bootstrap)
```
