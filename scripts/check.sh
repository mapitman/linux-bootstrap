#!/usr/bin/env bash
set -euo pipefail
# scripts/check.sh - run bash syntax checks and shellcheck across the repo
# Usage: bash scripts/check.sh

HERE=$(pwd)
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "Finding bash scripts (shebang contains 'bash')..."
find . -type f -not -path './.git/*' ! -name '*.md' -exec grep -Il '^#!.*\bbash\b' {} \; > "$TMPFILE" || true

if [ ! -s "$TMPFILE" ]; then
  echo "No bash scripts found."
  exit 0
fi

echo "Found scripts:"
cat "$TMPFILE"

echo
echo "Running 'bash -n' (syntax check) on each file..."
while IFS= read -r f; do
  echo "--> bash -n $f"
  bash -n "$f"
done < "$TMPFILE"

if command -v shellcheck >/dev/null 2>&1; then
  echo
  echo "Running shellcheck -x --severity=error on all files (fail only on errors)..."
  # Run shellcheck but only fail on ERROR severity (treat warnings/info as advisory)
  xargs -a "$TMPFILE" shellcheck -x --severity=error
else
  echo
  echo "shellcheck not found. To install locally, run one of the following depending on your distro:"
  echo "  # Debian/Ubuntu/Pop!_OS"
  echo "  sudo apt-get update && sudo apt-get install -y shellcheck"
  echo
  echo "  # Fedora"
  echo "  sudo dnf install -y ShellCheck"
  echo
  echo "  # Arch"
  echo "  sudo pacman -S shellcheck"
  echo
  echo "Once installed, re-run: bash scripts/check.sh"
fi

echo
echo "All checks completed."
