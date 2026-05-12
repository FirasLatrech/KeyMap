import Foundation
import Combine

/// User-visible preferences, persisted to `UserDefaults`.
final class Preferences: ObservableObject {

    static let shared = Preferences()

    @Published var defaultDirection: DefaultDirection {
        didSet { defaults.set(defaultDirection.rawValue, forKey: Key.defaultDirection) }
    }

    @Published var azertyEnabled: Bool {
        didSet { defaults.set(azertyEnabled, forKey: Key.azertyEnabled) }
    }

    @Published var showToast: Bool {
        didSet { defaults.set(showToast, forKey: Key.showToast) }
    }

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Key.launchAtLogin) }
    }

    enum DefaultDirection: String, CaseIterable, Identifiable {
        case auto
        case en2ar
        case ar2en
        case en2fr
        case fr2en

        var id: String { rawValue }

        var label: String {
            switch self {
            case .auto: return "Auto detect"
            case .en2ar: return "EN → AR"
            case .ar2en: return "AR → EN"
            case .en2fr: return "EN → FR"
            case .fr2en: return "FR → EN"
            }
        }

        func resolve(for text: String, azertyEnabled: Bool) -> Direction {
            switch self {
            case .auto: return Layouts.detect(text, azertyEnabled: azertyEnabled)
            case .en2ar: return .en2ar
            case .ar2en: return .ar2en
            case .en2fr: return .en2fr
            case .fr2en: return .fr2en
            }
        }
    }

    private enum Key {
        static let defaultDirection = "keymap.defaultDirection"
        static let azertyEnabled = "keymap.azertyEnabled"
        static let showToast = "keymap.showToast"
        static let launchAtLogin = "keymap.launchAtLogin"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.defaultDirection = DefaultDirection(rawValue: defaults.string(forKey: Key.defaultDirection) ?? "") ?? .auto
        self.azertyEnabled = defaults.object(forKey: Key.azertyEnabled) as? Bool ?? true
        self.showToast = defaults.object(forKey: Key.showToast) as? Bool ?? true
        self.launchAtLogin = defaults.object(forKey: Key.launchAtLogin) as? Bool ?? false
    }
}
