#!/usr/bin/env bash
# Builds dist/longhaul-plugin.zip for "Upload plugin" in the Claude app:
# the plugin folder as the single top-level entry. dist/ is not committed.
# Usage: bash scripts/build-zip.sh
set -euo pipefail
cd "$(dirname "$0")/.."
NAME="longhaul"
mkdir -p dist
rm -f "dist/$NAME-plugin.zip"
if command -v zip >/dev/null 2>&1; then
  (cd plugins && zip -qr "../dist/$NAME-plugin.zip" "$NAME" -x '*.DS_Store')
else
  python3 - "$NAME" <<'PYZIP'
import os, sys, zipfile
name = sys.argv[1]
with zipfile.ZipFile(f"dist/{name}-plugin.zip", "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(os.path.join("plugins", name)):
        for f in sorted(files):
            if f == ".DS_Store":
                continue
            p = os.path.join(root, f)
            info = zipfile.ZipInfo.from_file(p, os.path.relpath(p, "plugins"))
            with open(p, "rb") as fh:
                z.writestr(info, fh.read(), zipfile.ZIP_DEFLATED)
PYZIP
fi
echo "Built dist/$NAME-plugin.zip"
