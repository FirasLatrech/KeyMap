**KeyMap Fix v1.1.0** — first MVP release.

KeyMap converts mis-typed text between any two keyboard layouts you have enabled in macOS. One hotkey. Selection is replaced in place.

## What's new in v1.1.0

- **Live keyboard layouts.** v1.0 had hardcoded character tables that only worked correctly for QWERTY US ↔ macOS Arabic. v1.1 reads the actual tables of whatever input sources you have enabled in System Settings → Keyboard → Input Sources.
- **Auto direction.** Detects the script of your selection and picks the right source/target layout automatically.
- **Smaller and faster.** 420KB universal binary (Apple Silicon + Intel).

## Install

1. Download **KeyMap-1.1.0.dmg** below.
2. Open the DMG, drag **KeyMap.app** into **Applications**.
3. First launch: right-click **KeyMap.app** → **Open** → **Open Anyway** (unsigned — see notes).
4. Grant Accessibility permission when prompted (System Settings → Privacy & Security → Accessibility).
5. Select any text in any app and press **⌥⌘K**.

## Settings

Click the ⇄ icon in your menu bar:
- **Detected keyboard layouts** — see which input sources KeyMap found.
- **Direction** — Auto (recommended) or Fixed (pick From / To explicitly).
- **Show toast after conversion** — small HUD confirming the direction.
- **Launch at login** — start KeyMap automatically.

## Privacy

100% local. Zero network calls. The conversion uses Apple's `UCKeyTranslate` API on the layouts you already have installed.

## Notes

- **Unsigned.** Gatekeeper will warn on first launch ("Apple cannot check this app for malicious software"). Right-click → Open → Open Anyway. Notarization is planned once a Developer ID is acquired.
- **Raycast version.** A Raycast extension is also available — see [raycast/extensions#27836](https://github.com/raycast/extensions/pull/27836).
- **Source.** github.com/FirasLatrach/KeyMap

Made in Tunis 🇹🇳.
