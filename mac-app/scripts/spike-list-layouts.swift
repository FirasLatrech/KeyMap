#!/usr/bin/env swift
// Spike: enumerate every enabled keyboard input source and print what a
// selection of physical keys produces. Run with:
//     swift scripts/spike-list-layouts.swift
//
// This is a development-only script; it imports the KeyboardLayout source
// directly so we don't have to bring the whole app target along.

import Foundation
import Carbon.HIToolbox

// MARK: - Inline copy of KeyboardLayout (spike doesn't link the app target)

struct KeyboardLayout {
    let id: String
    let localizedName: String
    let isASCIICapable: Bool
    let primaryLanguage: String?
    private let layoutData: Data?
    private let keyboardType: UInt32

    init?(source: TISInputSource) {
        guard
            let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID),
            let idString = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String?
        else { return nil }

        let layoutData: Data?
        if let dataPtr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) {
            let cfData = Unmanaged<CFData>.fromOpaque(dataPtr).takeUnretainedValue()
            layoutData = cfData as Data
        } else {
            layoutData = nil
        }

        let localizedName: String = {
            if let ptr = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) {
                return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
            }
            return idString
        }()

        let isASCIICapable: Bool = {
            if let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsASCIICapable) {
                return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(ptr).takeUnretainedValue())
            }
            return false
        }()

        let primaryLanguage: String? = {
            guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) else { return nil }
            let langs = Unmanaged<CFArray>.fromOpaque(ptr).takeUnretainedValue() as? [String]
            return langs?.first
        }()

        self.id = idString
        self.localizedName = localizedName
        self.isASCIICapable = isASCIICapable
        self.primaryLanguage = primaryLanguage
        self.layoutData = layoutData
        self.keyboardType = UInt32(LMGetKbdType())
    }

    func characters(forKeyCode keyCode: UInt16, shift: Bool = false) -> String? {
        guard let layoutData else { return nil }
        var modifierState: UInt32 = 0
        if shift { modifierState |= UInt32(shiftKey >> 8) }
        return layoutData.withUnsafeBytes { raw -> String? in
            guard let base = raw.baseAddress else { return nil }
            let layoutPtr = base.assumingMemoryBound(to: UCKeyboardLayout.self)
            var deadKeyState: UInt32 = 0
            var length: Int = 0
            var buffer = [UniChar](repeating: 0, count: 8)
            let status = UCKeyTranslate(
                layoutPtr,
                keyCode,
                UInt16(kUCKeyActionDisplay),
                modifierState,
                keyboardType,
                OptionBits(kUCKeyTranslateNoDeadKeysBit),
                &deadKeyState,
                buffer.count,
                &length,
                &buffer
            )
            guard status == noErr, length > 0 else { return nil }
            return String(utf16CodeUnits: buffer, count: length)
        }
    }
}

// MARK: - Spike

let filter: [CFString: Any] = [
    kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as String,
]
guard let raw = TISCreateInputSourceList(filter as CFDictionary, false)?
    .takeRetainedValue() as? [TISInputSource]
else {
    print("Could not enumerate input sources.")
    exit(1)
}

let layouts = raw.compactMap(KeyboardLayout.init(source:))

let sampleKeys: [(name: String, code: Int)] = [
    ("Q", kVK_ANSI_Q),
    ("W", kVK_ANSI_W),
    ("A", kVK_ANSI_A),
    ("Z", kVK_ANSI_Z),
    ("M", kVK_ANSI_M),
    (";", kVK_ANSI_Semicolon),
    ("B", kVK_ANSI_B),
    ("1", kVK_ANSI_1),
    ("2", kVK_ANSI_2),
]

print("Enabled keyboard input sources:\n")
for layout in layouts {
    let badge = layout.isASCIICapable ? "ASCII" : "  -  "
    let lang  = layout.primaryLanguage ?? "?"
    print("• \(layout.localizedName)  [\(badge)  lang=\(lang)]")
    print("  id: \(layout.id)")
    for key in sampleKeys {
        let normal  = layout.characters(forKeyCode: UInt16(key.code), shift: false) ?? "—"
        let shifted = layout.characters(forKeyCode: UInt16(key.code), shift: true)  ?? "—"
        print("    key \(key.name): '\(normal)'  /  '\(shifted)' (shifted)")
    }
    print("")
}
