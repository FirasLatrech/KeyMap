import Foundation

/// v2 entry point for conversions. The actual character tables live in
/// `LayoutMapper` (live tables read from macOS) and `LayoutCatalog` (cached).
///
/// This file exists so call sites read as the same "Layouts.convert(...)"
/// shape they did in v1.
enum Layouts {

    @MainActor
    static func convert(_ text: String, route: ConversionRoute) -> String {
        let table = LayoutCatalog.shared.table(from: route.source, to: route.target)
        return table.convert(text)
    }
}
