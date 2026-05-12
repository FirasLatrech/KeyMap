import AppKit
import Carbon.HIToolbox

/// Registers a single global hotkey via the Carbon `RegisterEventHotKey` API
/// (the only stable way to get system-wide shortcuts on macOS without root).
final class GlobalHotkey {

    struct Combo {
        let keyCode: UInt32
        let modifiers: UInt32 // Carbon modifier flags (cmdKey, optionKey, etc.)

        /// Default ⌥⌘K.
        static let defaultCombo = Combo(
            keyCode: UInt32(kVK_ANSI_K),
            modifiers: UInt32(cmdKey | optionKey)
        )
    }

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let signature: OSType = OSType(0x4B4D4150) // 'KMAP'
    private let id: UInt32 = 1
    private var handler: (() -> Void)?

    init() {}

    deinit { unregister() }

    /// Register the given combo. Replaces any previous registration.
    /// Returns `true` on success.
    @discardableResult
    func register(_ combo: Combo = .defaultCombo, handler: @escaping () -> Void) -> Bool {
        unregister()
        self.handler = handler

        var hotKeyID = EventHotKeyID(signature: signature, id: id)
        var ref: EventHotKeyRef?
        let registerStatus = RegisterEventHotKey(
            combo.keyCode,
            combo.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        guard registerStatus == noErr, let ref else { return false }
        self.hotKeyRef = ref

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, userData -> OSStatus in
                guard let eventRef, let userData else { return noErr }
                var receivedID = EventHotKeyID()
                let s = GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &receivedID
                )
                guard s == noErr else { return noErr }
                let hk = Unmanaged<GlobalHotkey>.fromOpaque(userData).takeUnretainedValue()
                if receivedID.signature == hk.signature && receivedID.id == hk.id {
                    DispatchQueue.main.async { hk.handler?() }
                }
                return noErr
            },
            1,
            &spec,
            selfPtr,
            &eventHandler
        )
        return handlerStatus == noErr
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        handler = nil
    }
}

// Hotkey combos are not yet user-editable in v1; expose a static helper for the
// settings UI so we can label "⌥⌘K" without hardcoding the string.
extension GlobalHotkey.Combo {
    var displayString: String {
        var out = ""
        if modifiers & UInt32(controlKey) != 0 { out += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { out += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { out += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { out += "⌘" }
        out += Self.keyLabel(for: keyCode)
        return out
    }

    private static func keyLabel(for keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_J: return "J"
        case kVK_Space: return "Space"
        default: return "·"
        }
    }
}
