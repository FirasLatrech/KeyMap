import AppKit
import Carbon.HIToolbox

/// Drives the "convert the user's current selection in place" flow:
/// 1. Snapshot the clipboard.
/// 2. Simulate ⌘C, wait for the pasteboard to update.
/// 3. Pick a route from the user's enabled keyboard layouts.
/// 4. Build the substitution table and convert.
/// 5. Write the result and simulate ⌘V.
/// 6. Restore the original clipboard.
enum SelectionConverter {

    enum Outcome {
        case converted(route: ConversionRoute, output: String)
        case empty
        case unchanged
        case noRoute
        case notTrusted
    }

    @MainActor
    static func run(prefs: Preferences = .shared, catalog: LayoutCatalog = .shared) async -> Outcome {
        guard Accessibility.isTrusted else { return .notTrusted }

        let pasteboard = NSPasteboard.general
        let snapshot = pasteboard.snapshot()

        guard let selected = await copySelectionToPasteboard() else {
            pasteboard.restore(snapshot)
            return .empty
        }

        guard let route = resolveRoute(for: selected, prefs: prefs, catalog: catalog) else {
            pasteboard.restore(snapshot)
            return .noRoute
        }

        let converted = Layouts.convert(selected, route: route)

        if converted == selected {
            pasteboard.restore(snapshot)
            return .unchanged
        }

        pasteboard.clearContents()
        pasteboard.setString(converted, forType: .string)

        await sendCommand(key: kVK_ANSI_V)

        try? await Task.sleep(nanoseconds: 120_000_000)
        pasteboard.restore(snapshot)

        return .converted(route: route, output: converted)
    }

    @MainActor
    private static func resolveRoute(
        for text: String,
        prefs: Preferences,
        catalog: LayoutCatalog
    ) -> ConversionRoute? {
        switch prefs.routingMode {
        case .fixed:
            if
                let srcID = prefs.preferredSourceID,
                let dstID = prefs.preferredTargetID,
                let src = catalog.layout(withID: srcID),
                let dst = catalog.layout(withID: dstID),
                src.id != dst.id
            {
                return ConversionRoute(source: src, target: dst)
            }
            fallthrough
        case .auto:
            guard let (src, dst) = catalog.autoRoute(
                for: text,
                preferredSourceID: prefs.preferredSourceID,
                preferredTargetID: prefs.preferredTargetID
            ) else { return nil }
            return ConversionRoute(source: src, target: dst)
        }
    }

    @MainActor
    private static func copySelectionToPasteboard() async -> String? {
        let pasteboard = NSPasteboard.general
        let before = pasteboard.changeCount

        await sendCommand(key: kVK_ANSI_C)

        for _ in 0..<10 {
            try? await Task.sleep(nanoseconds: 30_000_000)
            if pasteboard.changeCount != before {
                return pasteboard.string(forType: .string)
            }
        }
        return nil
    }

    @MainActor
    private static func sendCommand(key: Int) async {
        guard let src = CGEventSource(stateID: .combinedSessionState) else { return }
        let keyCode = CGKeyCode(key)
        let down = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let up   = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
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
                if let data = item.data(forType: type) { dict[type] = data }
            }
            return dict
        }
        return PasteboardSnapshot(items: items)
    }

    func restore(_ snap: PasteboardSnapshot) {
        clearContents()
        let restored: [NSPasteboardItem] = snap.items.map { dict in
            let item = NSPasteboardItem()
            for (type, data) in dict { item.setData(data, forType: type) }
            return item
        }
        if !restored.isEmpty { writeObjects(restored) }
    }
}
