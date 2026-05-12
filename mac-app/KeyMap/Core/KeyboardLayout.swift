import Foundation
import Carbon.HIToolbox

/// A snapshot of a single macOS keyboard input source (e.g. "ABC", "French",
/// "Arabic — PC"), exposing the characters each physical key produces.
///
/// Only sources with `kTISPropertyUnicodeKeyLayoutData` are usable — IME-style
/// sources (Chinese pinyin, Korean) return `nil` from `characters(forKeyCode:)`.
struct KeyboardLayout: Identifiable, Hashable {

    let id: String
    let localizedName: String
    let isASCIICapable: Bool
    let primaryLanguage: String?

    /// Opaque hash of the `UCKeyLayout` bytes; used to invalidate the mapping
    /// cache when the system swaps in a different keyboard table.
    let layoutHash: Int

    /// Pre-extracted layout bytes. `nil` for non-keyboard / IME sources.
    private let layoutData: Data?
    /// macOS keyboard type at snapshot time.
    private let keyboardType: UInt32

    init?(source: TISInputSource) {
        guard
            let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID),
            let idString = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String?
        else { return nil }

        guard
            let categoryPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceCategory),
            (Unmanaged<CFString>.fromOpaque(categoryPtr).takeUnretainedValue() as String) ==
                (kTISCategoryKeyboardInputSource as String)
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
        self.layoutHash = layoutData?.hashValue ?? 0
        self.keyboardType = UInt32(LMGetKbdType())
    }

    /// Returns the string produced by pressing `keyCode` (a Carbon `kVK_*` constant)
    /// with the given modifier state. `nil` for IME sources or unmappable keys.
    func characters(forKeyCode keyCode: UInt16, shift: Bool = false, option: Bool = false) -> String? {
        guard let layoutData else { return nil }

        var modifierState: UInt32 = 0
        if shift  { modifierState |= UInt32(shiftKey  >> 8) }
        if option { modifierState |= UInt32(optionKey >> 8) }

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

extension KeyboardLayout {

    /// All keyboard input sources currently enabled in System Settings, filtered
    /// to those that expose a `UCKeyLayout` (i.e. usable for mapping).
    static func enabledKeyboardLayouts() -> [KeyboardLayout] {
        let filter: [CFString: Any] = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as String,
        ]
        guard
            let listRef = TISCreateInputSourceList(filter as CFDictionary, false)?
                .takeRetainedValue() as? [TISInputSource]
        else { return [] }

        return listRef.compactMap(KeyboardLayout.init(source:))
    }

    /// Best-effort Arabic detection from the layout's primary language tag.
    var producesArabicScript: Bool {
        guard let lang = primaryLanguage else { return false }
        return lang.hasPrefix("ar")
    }
}
