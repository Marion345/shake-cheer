import Foundation

enum CheerSound: String, CaseIterable, Identifiable {
    case bell
    case applause
    case cheer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bell: return "Hand Bell"
        case .applause: return "Applause"
        case .cheer: return "Cheer"
        }
    }

    var emoji: String {
        switch self {
        case .bell: return "🔔"
        case .applause: return "👏"
        case .cheer: return "📣"
        }
    }

    var fileName: String { rawValue }
}
