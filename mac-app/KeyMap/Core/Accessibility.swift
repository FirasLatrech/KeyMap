import AppKit
import ApplicationServices

/// Wraps the macOS Accessibility permission check + simulated copy/paste used to
/// read and replace the user's current selection.
enum Accessibility {

    /// Returns true if the process currently has Accessibility permission.
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompt the user to grant Accessibility. Triggers the system dialog the
    /// first time, and on subsequent calls is a no-op (returns the current state).
    @discardableResult
    static func requestTrust() -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options: NSDictionary = [key: true]
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Opens System Settings → Privacy & Security → Accessibility.
    static func openAccessibilityPane() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
