import Foundation

enum CheerSound: String, CaseIterable, Identifiable {
    case bell
    case applause
    case cheer
    case noisemaker
    case stadiumHorn

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bell: return "Cloche"
        case .applause: return "Applaudissements"
        case .cheer: return "Encouragement"
        case .noisemaker: return "Crécelle"
        case .stadiumHorn: return "Corne de stade"
        }
    }

    var emoji: String {
        switch self {
        case .bell: return "🔔"
        case .applause: return "👏"
        case .cheer: return "📣"
        case .noisemaker: return "🪇"
        case .stadiumHorn: return "📯"
        }
    }

    var fileName: String {
        switch self {
        case .stadiumHorn: return "stadium-horn"
        default: return rawValue
        }
    }
}
