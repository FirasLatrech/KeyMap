import AppKit
import Carbon.HIToolbox
import Combine

/// Observable list of currently-enabled keyboard input sources.
///
/// Re-reads the list when:
///   - the system posts `kTISNotifyEnabledKeyboardInputSourcesChanged`, or
///   - the app returns to the foreground (the distributed notification
///     occasionally fails to reach a background-only menu-bar app).
@MainActor
final class LayoutCatalog: ObservableObject {

    static let shared = LayoutCatalog()

    @Published private(set) var layouts: [KeyboardLayout] = []

    /// Maps `(sourceID, targetID)` to a built substitution table. Cleared on
    /// every catalog refresh so we never serve stale data after a user toggles
    /// an input source.
    private var tableCache: [TablePair: LayoutMapper.Table] = [:]

    private struct TablePair: Hashable {
        let sourceID: String
        let sourceHash: Int
        let targetID: String
        let targetHash: Int
    }

    private init() {
        refresh()
        let center = DistributedNotificationCenter.default()
        let name = Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String)
        center.addObserver(
            self,
            selector: #selector(handleSystemChange),
            name: name,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppActivation),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func refresh() {
        layouts = KeyboardLayout.enabledKeyboardLayouts()
        tableCache.removeAll(keepingCapacity: true)
    }

    func layout(withID id: String) -> KeyboardLayout? {
        layouts.first { $0.id == id }
    }

    /// Build (or fetch from cache) the substitution table for the given route.
    func table(from source: KeyboardLayout, to target: KeyboardLayout) -> LayoutMapper.Table {
        let key = TablePair(
            sourceID: source.id, sourceHash: source.layoutHash,
            targetID: target.id, targetHash: target.layoutHash
        )
        if let cached = tableCache[key] { return cached }
        let table = LayoutMapper.build(from: source, to: target)
        tableCache[key] = table
        return table
    }

    @objc private func handleSystemChange() {
        DispatchQueue.main.async { [weak self] in self?.refresh() }
    }

    @objc private func handleAppActivation() {
        refresh()
    }
}

// MARK: - Auto-routing

extension LayoutCatalog {

    /// Given the user's selected text, pick the most plausible source layout
    /// (the one whose script matches the text) and the most plausible target
    /// (a layout with a different script, preferring ASCII-capable when the
    /// source is non-ASCII and vice versa).
    func autoRoute(for text: String,
                   preferredSourceID: String? = nil,
                   preferredTargetID: String? = nil) -> (source: KeyboardLayout, target: KeyboardLayout)? {

        guard layouts.count >= 2 else { return nil }

        let dominantScript = Self.dominantScript(in: text)

        let source: KeyboardLayout? = {
            if let preferredSourceID, let l = layout(withID: preferredSourceID),
               Self.matches(layout: l, script: dominantScript) {
                return l
            }
            return layouts.first { Self.matches(layout: $0, script: dominantScript) }
        }()

        guard let source else { return nil }

        let target: KeyboardLayout? = {
            if let preferredTargetID, let l = layout(withID: preferredTargetID), l.id != source.id {
                return l
            }
            return layouts.first { $0.id != source.id && !Self.matches(layout: $0, script: dominantScript) }
                ?? layouts.first { $0.id != source.id }
        }()

        guard let target else { return nil }
        return (source, target)
    }

    private enum Script { case latin, arabic, other }

    private static func dominantScript(in text: String) -> Script {
        var latin = 0, arabic = 0
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x0041...0x005A, 0x0061...0x007A: latin += 1
            case 0x0600...0x06FF, 0x0750...0x077F, 0xFB50...0xFDFF, 0xFE70...0xFEFF: arabic += 1
            default: break
            }
        }
        if arabic > latin { return .arabic }
        if latin > 0 { return .latin }
        return .other
    }

    private static func matches(layout: KeyboardLayout, script: Script) -> Bool {
        switch script {
        case .latin:  return layout.isASCIICapable
        case .arabic: return layout.producesArabicScript
        case .other:  return true
        }
    }
}
