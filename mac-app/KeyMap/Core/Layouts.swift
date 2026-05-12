import Foundation

/// Deterministic character maps between keyboard layouts. Pure functions only;
/// no system state. Mirrors `raycast-extension/src/lib/layouts.ts`.
enum Layouts {

    // MARK: - Source pair tables

    /// QWERTY (US) → macOS Arabic layout. Unshifted + shifted rows.
    private static let enToArPairs: [(String, String)] = [
        ("q", "ض"), ("w", "ص"), ("e", "ث"), ("r", "ق"), ("t", "ف"),
        ("y", "غ"), ("u", "ع"), ("i", "ه"), ("o", "خ"), ("p", "ح"),
        ("[", "ج"), ("]", "د"),
        ("a", "ش"), ("s", "س"), ("d", "ي"), ("f", "ب"), ("g", "ل"),
        ("h", "ا"), ("j", "ت"), ("k", "ن"), ("l", "م"), (";", "ك"), ("'", "ط"),
        ("z", "ئ"), ("x", "ء"), ("c", "ؤ"), ("v", "ر"), ("b", "لا"),
        ("n", "ى"), ("m", "ة"), (",", "و"), (".", "ز"), ("/", "ظ"),
        // Shifted row.
        ("Q", "َ"), ("W", "ً"), ("E", "ُ"), ("R", "ٌ"), ("T", "لإ"),
        ("Y", "إ"), ("U", "`"), ("I", "÷"), ("O", "×"), ("P", "؛"),
        ("{", "<"), ("}", ">"),
        ("A", "ِ"), ("S", "ٍ"), ("D", "]"), ("F", "["), ("G", "لأ"),
        ("H", "أ"), ("J", "ـ"), ("K", "،"), ("L", "/"), (":", ":"), ("\"", "\""),
        ("Z", "~"), ("X", "ْ"), ("C", "}"), ("V", "{"), ("B", "لآ"),
        ("N", "آ"), ("M", "'"), ("<", ","), (">", "."), ("?", "؟"),
    ]

    /// QWERTY (US) ↔ AZERTY (French).
    private static let enToFrPairs: [(String, String)] = [
        ("q", "a"), ("a", "q"), ("w", "z"), ("z", "w"),
        ("m", ","), (",", ";"), (";", "m"),
        ("Q", "A"), ("A", "Q"), ("W", "Z"), ("Z", "W"),
        ("M", "?"), ("<", "."), (":", "M"),
        ("1", "&"), ("2", "é"), ("3", "\""), ("4", "'"), ("5", "("),
        ("6", "-"), ("7", "è"), ("8", "_"), ("9", "ç"), ("0", "à"),
    ]

    // MARK: - Compiled maps

    private static func build(_ pairs: [(String, String)]) -> [String: String] {
        var m: [String: String] = [:]
        for (from, to) in pairs where m[from] == nil { m[from] = to }
        return m
    }

    private static func inverted(_ pairs: [(String, String)]) -> [(String, String)] {
        pairs.map { ($0.1, $0.0) }
    }

    private static let maps: [Direction: [String: String]] = [
        .en2ar: build(enToArPairs),
        .ar2en: build(inverted(enToArPairs)),
        .en2fr: build(enToFrPairs),
        .fr2en: build(inverted(enToFrPairs)),
    ]

    /// Multi-character source keys are deliberately disabled. The Arabic `لا`
    /// family of ligatures cannot be reliably round-tripped because the same
    /// two Unicode scalars also occur unrelated to the ligature, so converting
    /// `ل`+`ا` always back to `b` (a single QWERTY key) silently corrupts text.
    /// Treating every input as a single scalar is correct for the common case.
    private static let multiKeys: [Direction: [String]] = [:]

    // MARK: - Public API

    static func convert(_ text: String, direction: Direction) -> String {
        guard let map = maps[direction] else { return text }
        let multi = multiKeys[direction] ?? []
        var out = ""
        var idx = text.startIndex
        while idx < text.endIndex {
            var matched = false
            for key in multi {
                if text[idx...].hasPrefix(key) {
                    out += map[key]!
                    idx = text.index(idx, offsetBy: key.count)
                    matched = true
                    break
                }
            }
            if matched { continue }
            let ch = String(text[idx])
            out += map[ch] ?? ch
            idx = text.index(after: idx)
        }
        return out
    }

    private static let arabicRange: ClosedRange<Unicode.Scalar> = "\u{0600}"..."\u{06FF}"
    private static let azertyChars: Set<Character> = ["é", "è", "ç", "à", "ù", "É", "È", "Ç", "À", "Ù"]

    static func detect(_ text: String, azertyEnabled: Bool) -> Direction {
        for scalar in text.unicodeScalars where arabicRange.contains(scalar) {
            return .ar2en
        }
        if azertyEnabled, text.contains(where: { azertyChars.contains($0) }) {
            return .fr2en
        }
        return .en2ar
    }
}
