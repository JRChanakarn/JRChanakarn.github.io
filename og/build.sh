#!/bin/sh
# Renders og/og.html to og.png (link preview) and favicon.svg to apple-touch-icon.png. Needs Google Chrome.
set -e
cd "$(dirname "$0")/.."
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

shot() { # <url> <out> <width> <height>
  # a throwaway profile, never the user's own Chrome
  profile=$(mktemp -d)
  rm -f "$2"
  "$CHROME" --headless=new --user-data-dir="$profile" --no-first-run --hide-scrollbars \
    --window-size="$3,$4" --virtual-time-budget=3000 --screenshot="$PWD/$2" "$1" >/dev/null 2>&1 &
  pid=$!
  # headless Chrome writes the screenshot but doesn't always exit by itself
  for _ in $(seq 1 40); do [ -s "$2" ] && break; sleep 0.25; done
  sleep 0.5
  kill "$pid" 2>/dev/null || true
  rm -rf "$profile" 2>/dev/null || true
  [ -s "$2" ] && echo "✅ $2" || { echo "❌ Chrome produced no $2"; exit 1; }
}

shot "file://$PWD/og/og.html" og.png 1200 630
printf '<body style="margin:0;background:#e8d5b9"><img src="../favicon.svg" style="display:block;width:150px;height:150px;margin:15px;image-rendering:pixelated">' > og/touch.html
shot "file://$PWD/og/touch.html" apple-touch-icon.png 180 180
rm og/touch.html
