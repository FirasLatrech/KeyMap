# KeyMap Fix — macOS menu-bar app

Standalone SwiftUI version of KeyMap Fix for people who don't use Raycast.

Lives in the menu bar, listens for a global hotkey (default **⌥⌘K**), and converts your currently selected text in place — Arabic ⇄ English (QWERTY/macOS Arabic) and English ⇄ French (QWERTY/AZERTY).

## Install

1. Download the latest [`KeyMap-1.0.0.dmg`](https://github.com/FirasLatrach/KeyMap/releases) from the Releases page.
2. Open the DMG, drag **KeyMap.app** into **Applications**.
3. On first launch, macOS will show a Gatekeeper warning (the app isn't notarized yet — see below). Right-click the app → **Open** → **Open Anyway**.
4. KeyMap will prompt for **Accessibility** permission — this is required to read your selection and paste the converted text. Grant it in System Settings → Privacy & Security → Accessibility.

## Use

1. Select any text in any app.
2. Press **⌥⌘K**.
3. The selection is replaced with the converted text. A small toast confirms the direction.

Click the menu-bar icon for the settings window: default direction, AZERTY toggle, notification toggle, launch-at-login.

## Build from source

Requires Xcode 15+ and macOS 13+.

```bash
git clone https://github.com/FirasLatrach/KeyMap.git
cd KeyMap/mac-app
swift test                      # run unit tests
./scripts/build-app.sh          # produces build/KeyMap.app
./scripts/build-dmg.sh          # produces build/KeyMap-1.0.0.dmg
```

The Swift sources are organized as a standard `swift package`:

```
KeyMap/
  App/            App entry point + AppDelegate
  Core/           Pure logic — Layouts, Direction, Preferences, Accessibility, SelectionConverter
  Features/
    MenuBar/      NSStatusItem controller + toast
    Settings/     SwiftUI settings window
    Hotkey/       Global hotkey via Carbon
  Resources/      Info.plist + .icns
KeyMapTests/      Layout conversion tests
scripts/          build-app.sh, build-dmg.sh
```

## Signing & notarization

v1 ships **unsigned**. macOS Gatekeeper will refuse to open the DMG-installed app on first launch with the message *"Apple cannot check this app for malicious software."* Bypass it:

- Right-click **KeyMap.app** → **Open** → **Open Anyway**, or
- Run `xattr -dr com.apple.quarantine /Applications/KeyMap.app` in Terminal.

Proper signing + notarization requires a paid Apple Developer ID (\$99/year) and will be added in a future release.

## Privacy

The Mac app, like the Raycast extension, is **100% local**. No network calls, no telemetry. The conversion is a deterministic character map. Source: [`KeyMap/Core/Layouts.swift`](./KeyMap/Core/Layouts.swift).
