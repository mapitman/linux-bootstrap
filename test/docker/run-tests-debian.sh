#!/usr/bin/env bash
# Non-interactive test runner for Debian bootstrap scripts
set -e

cd /home/testuser/linux-bootstrap

echo "Testing Debian package installation..."
bash debian/install-packages

echo ""
echo "Verifying packages are installed..."
PACKAGES=(
    apt-transport-https
    bat
    btop
    curl
    detox
    docker.io
    eza
    ffmpeg
    fzf
    gh
    git
    git-extras
    gpg
    lazygit
    libfuse2t64
    lm-sensors
    lsb-release
    ncat
    neovim
    nmap
    pipx
    pv
    pwgen
    ranger
    rclone
    renameutils
    starship
    tmux
    wget
    yadm
    zoxide
    zsh
    zsh-doc
)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: The following packages are not installed:"
    for pkg in "${MISSING[@]}"; do
        echo "  - $pkg"
    done
    exit 1
fi

echo ""
echo "================================="
echo "Debian package test completed"
echo "================================="
