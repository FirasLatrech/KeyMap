# KeyMap Fix

Convert mis-typed text between Arabic, English, and French (AZERTY) keyboard layouts in one keystroke. macOS only.

Ships in three forms:

| | What | For |
|---|---|---|
| 🟣 **[Raycast extension](./raycast-extension)** | Two commands + preferences inside Raycast. PR [#27836](https://github.com/raycast/extensions/pull/27836). | Raycast users — the smoothest experience. |
| 🍎 **[Mac menu-bar app](./mac-app)** | Native SwiftUI app, global hotkey, no Raycast required. Download the `.dmg` from Releases. | Everyone else on macOS. |
| 🌐 **[Landing page](./landing)** | Next.js + Tailwind marketing site. | The web. |

## Quick start

**Use it via Raycast** — coming once PR #27836 is merged into the store.

**Use it standalone** — grab the [latest release](https://github.com/FirasLatrach/KeyMap/releases) and drag **KeyMap.app** into Applications. Press **⌥⌘K** on any selected text.

**Develop locally:**

```bash
# Raycast extension
cd raycast-extension && npm install && npm run dev

# Landing page
cd landing && npm install && npm run dev

# Mac app
cd mac-app && swift test && ./scripts/build-dmg.sh
```

See [`DESIGN.md`](./DESIGN.md) for the design brief.

Made in Tunis 🇹🇳.
