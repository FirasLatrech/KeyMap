import AppKit
import SwiftUI

@main
struct KeyMapApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var menuBar: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar utility — don't show in the Dock.
        NSApp.setActivationPolicy(.accessory)

        // Ask once on first launch; the system will only prompt if not yet granted.
        _ = Accessibility.requestTrust()

        menuBar = MenuBarController(prefs: .shared)
    }
}
