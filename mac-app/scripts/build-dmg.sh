#!/usr/bin/env bash
# Build a distributable .dmg from build/KeyMap.app.
# Run ./scripts/build-app.sh first (or this script will do it for you).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/KeyMap.app"
DMG="$BUILD_DIR/KeyMap-1.0.0.dmg"
STAGE="$BUILD_DIR/dmg-stage"
VOL_NAME="KeyMap Fix"

if [ ! -d "$APP" ]; then
    "$ROOT/scripts/build-app.sh"
fi

echo "→ Staging DMG contents at $STAGE"
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/KeyMap.app"
ln -s /Applications "$STAGE/Applications"

echo "→ Creating $DMG"
hdiutil create \
    -volname "$VOL_NAME" \
    -srcfolder "$STAGE" \
    -ov \
    -format UDZO \
    "$DMG" >/dev/null

rm -rf "$STAGE"
echo "✓ DMG: $DMG"
