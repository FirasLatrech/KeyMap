import Foundation
import Combine

/// User-visible preferences, persisted to `UserDefaults`.
///
/// In v1 the app shipped with a hardcoded `defaultDirection` enum. v2 reads the
/// user's actual enabled keyboard layouts at runtime, so prefs are now layout
/// IDs (e.g. `"com.apple.keylayout.ABC"`). The old enum key is migrated on
/// first launch and then deleted.
@MainActor
final class Preferences: ObservableObject {

    static let shared = Preferences()

    @Published var routingMode: RoutingMode {
        didSet { defaults.set(routingMode.rawValue, forKey: Key.routingMode) }
    }

    /// Preferred source layout ID. Used as a hint by Auto, or as the fixed
    /// source when `routingMode == .fixed`.
    @Published var preferredSourceID: String? {
        didSet { defaults.set(preferredSourceID, forKey: Key.preferredSourceID) }
    }

    /// Preferred target layout ID.
    @Published var preferredTargetID: String? {
        didSet { defaults.set(preferredTargetID, forKey: Key.preferredTargetID) }
    }

    @Published var showToast: Bool {
        didSet { defaults.set(showToast, forKey: Key.showToast) }
    }

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Key.launchAtLogin) }
    }

    enum RoutingMode: String, CaseIterable, Identifiable {
        case auto
        case fixed

        var id: String { rawValue }
        var label: String {
            switch self {
            case .auto:  return "Auto detect"
            case .fixed: return "Fixed direction"
            }
        }
    }

    private enum Key {
        static let routingMode        = "keymap.routingMode"
        static let preferredSourceID  = "keymap.preferredSourceID"
        static let preferredTargetID  = "keymap.preferredTargetID"
        static let showToast          = "keymap.showToast"
        static let launchAtLogin      = "keymap.launchAtLogin"

        // Legacy v1 keys, migrated then deleted on first run.
        static let legacyDefaultDirection = "keymap.defaultDirection"
        static let legacyAzertyEnabled    = "keymap.azertyEnabled"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        Self.migrateLegacyKeysIfNeeded(in: defaults)

        self.routingMode = RoutingMode(rawValue: defaults.string(forKey: Key.routingMode) ?? "") ?? .auto
        self.preferredSourceID = defaults.string(forKey: Key.preferredSourceID)
        self.preferredTargetID = defaults.string(forKey: Key.preferredTargetID)
        self.showToast = defaults.object(forKey: Key.showToast) as? Bool ?? true
        self.launchAtLogin = defaults.object(forKey: Key.launchAtLogin) as? Bool ?? false
    }

    private static func migrateLegacyKeysIfNeeded(in defaults: UserDefaults) {
        guard let legacy = defaults.string(forKey: Key.legacyDefaultDirection) else { return }

        let catalog = KeyboardLayout.enabledKeyboardLayouts()
        let firstASCII  = catalog.first { $0.isASCIICapable }
        let firstArabic = catalog.first { $0.producesArabicScript }

        switch legacy {
        case "en2ar":
            defaults.set(RoutingMode.fixed.rawValue, forKey: Key.routingMode)
            defaults.set(firstASCII?.id,  forKey: Key.preferredSourceID)
            defaults.set(firstArabic?.id, forKey: Key.preferredTargetID)
        case "ar2en":
            defaults.set(RoutingMode.fixed.rawValue, forKey: Key.routingMode)
            defaults.set(firstArabic?.id, forKey: Key.preferredSourceID)
            defaults.set(firstASCII?.id,  forKey: Key.preferredTargetID)
        default:
            defaults.set(RoutingMode.auto.rawValue, forKey: Key.routingMode)
        }

        defaults.removeObject(forKey: Key.legacyDefaultDirection)
        defaults.removeObject(forKey: Key.legacyAzertyEnabled)
    }
}
