import Foundation
import Carbon.HIToolbox

/// Builds a live character-substitution table between two `KeyboardLayout`s by
/// asking each layout what every physical key produces (unshifted + shifted).
///
/// The map is **scalar → string**. Multi-scalar outputs (e.g. an Arabic
/// ligature on some layouts) are kept on the *forward* side only; the reverse
/// pass uses the single-scalar entries to avoid corrupting prose that happens
/// to contain the same scalar sequence outside the ligature context.
enum LayoutMapper {

    /// Carbon `kVK_*` codes for the keys that have a visible character on a
    /// US ANSI keyboard. Function/arrow/modifier keys are deliberately excluded.
    private static let visibleKeyCodes: [Int] = [
        kVK_ANSI_A, kVK_ANSI_B, kVK_ANSI_C, kVK_ANSI_D, kVK_ANSI_E, kVK_ANSI_F,
        kVK_ANSI_G, kVK_ANSI_H, kVK_ANSI_I, kVK_ANSI_J, kVK_ANSI_K, kVK_ANSI_L,
        kVK_ANSI_M, kVK_ANSI_N, kVK_ANSI_O, kVK_ANSI_P, kVK_ANSI_Q, kVK_ANSI_R,
        kVK_ANSI_S, kVK_ANSI_T, kVK_ANSI_U, kVK_ANSI_V, kVK_ANSI_W, kVK_ANSI_X,
        kVK_ANSI_Y, kVK_ANSI_Z,
        kVK_ANSI_0, kVK_ANSI_1, kVK_ANSI_2, kVK_ANSI_3, kVK_ANSI_4,
        kVK_ANSI_5, kVK_ANSI_6, kVK_ANSI_7, kVK_ANSI_8, kVK_ANSI_9,
        kVK_ANSI_Minus, kVK_ANSI_Equal,
        kVK_ANSI_LeftBracket, kVK_ANSI_RightBracket, kVK_ANSI_Backslash,
        kVK_ANSI_Semicolon, kVK_ANSI_Quote, kVK_ANSI_Grave,
        kVK_ANSI_Comma, kVK_ANSI_Period, kVK_ANSI_Slash,
    ]

    /// Pre-built substitution maps for a single direction (source → target).
    struct Table {
        /// Scalar → output string. Multi-scalar outputs allowed.
        let scalarToString: [Unicode.Scalar: String]

        /// True if every source scalar maps to exactly one target scalar — the
        /// caller can use a `Unicode.Scalar` loop. Otherwise must concatenate.
        let isStrictlyScalarMap: Bool
    }

    /// Build the substitution table mapping characters produced by `source` to
    /// characters produced by `target` at the same physical key position.
    static func build(from source: KeyboardLayout, to target: KeyboardLayout) -> Table {
        var mapping: [Unicode.Scalar: String] = [:]
        var strict = true

        for code in visibleKeyCodes {
            let keyCode = UInt16(code)
            collect(keyCode: keyCode, shift: false, source: source, target: target,
                    into: &mapping, strict: &strict)
            collect(keyCode: keyCode, shift: true,  source: source, target: target,
                    into: &mapping, strict: &strict)
        }

        return Table(scalarToString: mapping, isStrictlyScalarMap: strict)
    }

    private static func collect(
        keyCode: UInt16,
        shift: Bool,
        source: KeyboardLayout,
        target: KeyboardLayout,
        into mapping: inout [Unicode.Scalar: String],
        strict: inout Bool
    ) {
        guard
            let srcStr = source.characters(forKeyCode: keyCode, shift: shift), !srcStr.isEmpty,
            let dstStr = target.characters(forKeyCode: keyCode, shift: shift), !dstStr.isEmpty
        else { return }

        // Source-side ligatures (multi-scalar) can't be reliably consumed during
        // a forward scan; keep only single-scalar source keys.
        let srcScalars = Array(srcStr.unicodeScalars)
        guard srcScalars.count == 1 else { return }
        let srcScalar = srcScalars[0]

        // First write wins so the unshifted row dominates over a shifted
        // collision (e.g. some layouts produce the same character on multiple
        // physical keys).
        if mapping[srcScalar] == nil {
            mapping[srcScalar] = dstStr
            if dstStr.unicodeScalars.count != 1 { strict = false }
        }
    }
}

extension LayoutMapper.Table {

    /// Apply the table to `text`. NFC-normalized first so layouts that emit
    /// decomposed sequences still hit the cache.
    func convert(_ text: String) -> String {
        let normalized = text.precomposedStringWithCanonicalMapping
        var out = String.UnicodeScalarView()
        out.reserveCapacity(normalized.unicodeScalars.count)
        for scalar in normalized.unicodeScalars {
            if let replacement = scalarToString[scalar] {
                out.append(contentsOf: replacement.unicodeScalars)
            } else {
                out.append(scalar)
            }
        }
        return String(out)
    }
}
