#!/usr/bin/env bash
# Generates the directory edition: the plugin without its hook and script, for
# submission to Anthropic's plugin directory, which accepts those only from
# Verified organizations. Output is committed at directory/longhaul and is what
# the directory submission points at. Never edit that folder by hand.
#
# Usage: bash scripts/build-directory-edition.sh [output-dir]
set -euo pipefail
cd "$(dirname "$0")/.."
NAME="longhaul"
SRC="plugins/$NAME"
OUT="${1:-directory/$NAME}"

case "$OUT" in
  ""|"/"|"."|".."|"$SRC"|plugins|plugins/*) echo "Refusing to write to '$OUT'." >&2; exit 1 ;;
esac

rm -rf "$OUT"
mkdir -p "$OUT"
# Same manifest, icon, skills and templates as the full edition.
cp -R "$SRC/.claude-plugin" "$SRC/skills" "$OUT/"
# Its own README: no hook, and no install commands for the GitHub marketplace.
cp scripts/directory-edition/README.md "$OUT/README.md"
find "$OUT" -name .DS_Store -delete
echo "Built $OUT"
