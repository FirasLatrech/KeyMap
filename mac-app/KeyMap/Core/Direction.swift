import Foundation

enum Direction: String, CaseIterable, Codable, Identifiable {
    case en2ar
    case ar2en
    case en2fr
    case fr2en

    var id: String { rawValue }

    var label: String {
        switch self {
        case .en2ar: return "EN → AR"
        case .ar2en: return "AR → EN"
        case .en2fr: return "EN → FR"
        case .fr2en: return "FR → EN"
        }
    }

    var reversed: Direction {
        switch self {
        case .en2ar: return .ar2en
        case .ar2en: return .en2ar
        case .en2fr: return .fr2en
        case .fr2en: return .en2fr
        }
    }
}
