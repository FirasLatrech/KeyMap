import AppKit
import SwiftUI
import Combine

/// Owns the menu-bar item and routes user actions.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {

    private let statusItem: NSStatusItem
    private let hotkey = GlobalHotkey()
    private let prefs: Preferences
    private var settingsWindow: NSWindow?
    private var cancellables: Set<AnyCancellable> = []

    init(prefs: Preferences = .shared) {
        self.prefs = prefs
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
        rebuildMenu()
        registerHotkey()
    }

    // MARK: - Status item

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = Self.statusImage()
        button.image?.isTemplate = true
        button.toolTip = "KeyMap Fix"
    }

    private static func statusImage() -> NSImage {
        // Glyph: "K↔" in the menu-bar. Using a system symbol keeps it template-tinted
        // and matches the bar's accent colour automatically.
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        return NSImage(systemSymbolName: "arrow.left.arrow.right",
                       accessibilityDescription: "KeyMap Fix")?
            .withSymbolConfiguration(config) ?? NSImage()
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        let title = NSMenuItem(title: "KeyMap Fix", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)

        let hotkeyItem = NSMenuItem(
            title: "Convert selection",
            action: #selector(triggerFromMenu),
            keyEquivalent: ""
        )
        hotkeyItem.target = self
        hotkeyItem.toolTip = "Default: ⌥⌘K"
        menu.addItem(hotkeyItem)

        menu.addItem(.separator())

        if !Accessibility.isTrusted {
            let warn = NSMenuItem(
                title: "Grant Accessibility…",
                action: #selector(grantAccessibility),
                keyEquivalent: ""
            )
            warn.target = self
            menu.addItem(warn)
            menu.addItem(.separator())
        }

        let settings = NSMenuItem(
            title: "Settings…",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settings.target = self
        menu.addItem(settings)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit KeyMap", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        statusItem.menu = menu
    }

    // MARK: - Hotkey

    private func registerHotkey() {
        hotkey.register { [weak self] in
            Task { @MainActor in await self?.runConvert() }
        }
    }

    @objc private func triggerFromMenu() {
        Task { await runConvert() }
    }

    private func runConvert() async {
        if !Accessibility.isTrusted {
            Accessibility.requestTrust()
            rebuildMenu()
            return
        }
        let outcome = await SelectionConverter.run(using: prefs)
        switch outcome {
        case .converted(let direction, _):
            if prefs.showToast {
                ToastPresenter.show("Converted \(direction.label)")
            }
        case .empty:
            ToastPresenter.show("No selection")
        case .unchanged:
            ToastPresenter.show("Nothing to convert")
        case .notTrusted:
            Accessibility.requestTrust()
            rebuildMenu()
        }
    }

    // MARK: - Settings

    @objc private func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let host = NSHostingController(rootView: SettingsView().environmentObject(prefs))
        let window = NSWindow(contentViewController: host)
        window.title = "KeyMap Settings"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.setContentSize(NSSize(width: 460, height: 320))
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func grantAccessibility() {
        Accessibility.requestTrust()
        Accessibility.openAccessibilityPane()
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        // Re-evaluate accessibility state in case the user just granted it.
        rebuildMenu()
    }
}
