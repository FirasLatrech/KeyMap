import AppKit
import SwiftUI

/// Small auto-dismissing HUD shown after a conversion.
@MainActor
enum ToastPresenter {

    private static var window: NSWindow?
    private static var dismissTask: Task<Void, Never>?

    static func show(_ message: String, duration: TimeInterval = 1.4) {
        dismissTask?.cancel()
        let host = NSHostingController(rootView: ToastView(message: message))
        host.view.layer?.cornerRadius = 12

        let size = NSSize(width: 240, height: 56)
        let screen = NSScreen.main?.visibleFrame ?? .zero
        let origin = NSPoint(
            x: screen.midX - size.width / 2,
            y: screen.maxY - size.height - 24
        )

        let window: NSWindow = self.window ?? {
            let w = NSPanel(
                contentRect: NSRect(origin: origin, size: size),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            w.level = .statusBar
            w.isOpaque = false
            w.backgroundColor = .clear
            w.hasShadow = true
            w.ignoresMouseEvents = true
            w.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
            self.window = w
            return w
        }()

        window.contentViewController = host
        window.setContentSize(size)
        window.setFrameOrigin(origin)
        window.alphaValue = 0
        window.orderFront(nil)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            window.animator().alphaValue = 1
        }

        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if Task.isCancelled { return }
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.22
                window.animator().alphaValue = 0
            } completionHandler: {
                window.orderOut(nil)
            }
        }
    }
}

private struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.486, green: 0.361, blue: 1.0)) // #7C5CFF
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}
