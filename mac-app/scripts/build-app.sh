#!/usr/bin/env bash
# Build KeyMap.app from the Swift package and stage it under build/.
#
# Usage:
#   ./scripts/build-app.sh            # release
#   ./scripts/build-app.sh debug      # debug
#
# Produces: build/KeyMap.app

set -euo pipefail

CONFIG="${1:-release}"
APP_NAME="KeyMap"
BUNDLE_ID="tn.firas.keymap"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

cd "$ROOT"

echo "→ Compiling ($CONFIG)…"
if [ "$CONFIG" = "release" ]; then
    swift build -c release --arch arm64 --arch x86_64
else
    swift build
fi

BIN_PATH="$(swift build -c "$CONFIG" --arch arm64 --arch x86_64 --show-bin-path 2>/dev/null || swift build -c "$CONFIG" --show-bin-path)"

echo "→ Staging app bundle at $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$MACOS" "$RESOURCES"

cp "$BIN_PATH/$APP_NAME" "$MACOS/$APP_NAME"
chmod +x "$MACOS/$APP_NAME"

cp "$ROOT/KeyMap/Resources/Info.plist" "$CONTENTS/Info.plist"

# Copy any .icns we have. (Optional: we ship a PNG today.)
if [ -f "$ROOT/KeyMap/Resources/AppIcon.icns" ]; then
    cp "$ROOT/KeyMap/Resources/AppIcon.icns" "$RESOURCES/AppIcon.icns"
fi

# Ad-hoc sign so Gatekeeper doesn't outright refuse to launch.
codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

echo "✓ Built $APP_DIR"
