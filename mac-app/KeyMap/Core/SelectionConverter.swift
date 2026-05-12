import AppKit
import Carbon.HIToolbox

/// Drives the "convert the user's current selection in place" flow:
/// 1. Snapshot the clipboard.
/// 2. Simulate ⌘C, wait for the pasteboard to update.
/// 3. Run the conversion.
/// 4. Write the result and simulate ⌘V.
/// 5. Restore the original clipboard.
///
/// Requires Accessibility permission (granted via `Accessibility.requestTrust()`).
enum SelectionConverter {

    enum Outcome {
        case converted(direction: Direction, output: String)
        case empty
        case unchanged
        case notTrusted
    }

    /// Run the convert-selection flow. Returns the outcome so the caller can
    /// drive a toast / HUD. Safe to call from the main thread.
    @MainActor
    static func run(using prefs: Preferences = .shared) async -> Outcome {
        guard Accessibility.isTrusted else { return .notTrusted }

        let pasteboard = NSPasteboard.general
        let snapshot = pasteboard.snapshot()

        guard let selected = await copySelectionToPasteboard() else {
            pasteboard.restore(snapshot)
            return .empty
        }

        let direction = prefs.defaultDirection.resolve(for: selected, azertyEnabled: prefs.azertyEnabled)
        let converted = Layouts.convert(selected, direction: direction)

        if converted == selected {
            pasteboard.restore(snapshot)
            return .unchanged
        }

        pasteboard.clearContents()
        pasteboard.setString(converted, forType: .string)

        await sendCommand(key: kVK_ANSI_V)

        // Give the host app a moment to consume the paste before restoring.
        try? await Task.sleep(nanoseconds: 120_000_000)
        pasteboard.restore(snapshot)

        return .converted(direction: direction, output: converted)
    }

    /// Sends ⌘C and reads the resulting string from the pasteboard. Returns
    /// `nil` if nothing was selected.
    @MainActor
    private static func copySelectionToPasteboard() async -> String? {
        let pasteboard = NSPasteboard.general
        let before = pasteboard.changeCount

        await sendCommand(key: kVK_ANSI_C)

        // Poll briefly for the pasteboard to update — the host app needs a tick.
        for _ in 0..<10 {
            try? await Task.sleep(nanoseconds: 30_000_000) // 30ms
            if pasteboard.changeCount != before {
                return pasteboard.string(forType: .string)
            }
        }
        return nil
    }

    /// Synthesize a ⌘<key> keystroke via CGEvent.
    @MainActor
    private static func sendCommand(key: Int) async {
        guard let src = CGEventSource(stateID: .combinedSessionState) else { return }
        let keyCode = CGKeyCode(key)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        down?.flags = .maskCommand
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}

// MARK: - Pasteboard snapshot helpers

private struct PasteboardSnapshot {
    let items: [[NSPasteboard.PasteboardType: Data]]
}

private extension NSPasteboard {
    func snapshot() -> PasteboardSnapshot {
        let items = (pasteboardItems ?? []).map { item -> [NSPasteboard.PasteboardType: Data] in
            var dict: [NSPasteboard.PasteboardType: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) {
                    dict[type] = data
                }
            }
            return dict
        }
        return PasteboardSnapshot(items: items)
    }

    func restore(_ snap: PasteboardSnapshot) {
        clearContents()
        let restored: [NSPasteboardItem] = snap.items.map { dict in
            let item = NSPasteboardItem()
            for (type, data) in dict {
                item.setData(data, forType: type)
            }
            return item
        }
        if !restored.isEmpty {
            writeObjects(restored)
        }
    }
}
