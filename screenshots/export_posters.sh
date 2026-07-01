#!/usr/bin/env bash
# Renders each poster frame in appstore_screenshots.html to an exact
# 1242x2688 PNG (the 6.5" App Store slot), ready to upload.
#
# Each frame is 621x1344 in CSS; capturing at a 2x device scale gives 1242x2688.
#
# Usage: bash export_posters.sh
set -euo pipefail

cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [[ ! -x "$CHROME" ]]; then
  echo "Google Chrome not found at: $CHROME" >&2
  exit 1
fi

HTML="file://$(pwd)/appstore_screenshots.html"
OUT_DIR="output/posters"
mkdir -p "$OUT_DIR"

for n in 1 2 3 4 5; do
  out="$OUT_DIR/poster-$n.png"
  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size=621,1344 \
    --virtual-time-budget=3000 \
    --default-background-color=00000000 \
    --screenshot="$out" \
    "$HTML?frame=$n" >/dev/null 2>&1
  echo "✅ $out ($(sips -g pixelWidth -g pixelHeight "$out" | awk '/pixelWidth|pixelHeight/{printf $2" "}')px)"
done

echo "Done. Upload-ready posters are in screenshots/$OUT_DIR/"
