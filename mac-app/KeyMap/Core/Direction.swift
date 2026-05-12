import Foundation

/// A live conversion route built from two of the user's currently-enabled
/// keyboard layouts. Replaces v1's hardcoded `Direction` enum.
struct ConversionRoute: Hashable {
    let source: KeyboardLayout
    let target: KeyboardLayout

    var label: String {
        "\(Self.shortName(source)) → \(Self.shortName(target))"
    }

    var reversed: ConversionRoute {
        ConversionRoute(source: target, target: source)
    }

    private static func shortName(_ layout: KeyboardLayout) -> String {
        if let lang = layout.primaryLanguage?.split(separator: "-").first {
            return lang.uppercased()
        }
        return layout.localizedName
    }
}
