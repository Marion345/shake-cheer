import Foundation

enum CheerSound: String, CaseIterable, Identifiable {
    case bell
    case applause
    case cheer
    case drum
    case noisemaker
    case stadiumHorn

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bell: return "Cloche"
        case .applause: return "Applaudissements"
        case .cheer: return "Encouragement"
        case .drum: return "Tambour"
        case .noisemaker: return "Crécelle"
        case .stadiumHorn: return "Corne de stade"
        }
    }

    var emoji: String {
        switch self {
        case .bell: return "🔔"
        case .applause: return "👏"
        case .cheer: return "📣"
        case .drum: return "🥁"
        case .noisemaker: return "🪇"
        case .stadiumHorn: return "📯"
        }
    }

    var fileName: String {
        switch self {
        case .cheer: return "cheer-crowd-loop"
        case .drum: return "drum-crowd"
        case .stadiumHorn: return "stadium-horn"
        default: return rawValue
        }
    }

    var fileExtension: String {
        switch self {
        case .drum: return "mp3"
        default: return "wav"
        }
    }

    var usesSustainedPlayback: Bool {
        switch self {
        case .cheer, .drum, .stadiumHorn: return true
        default: return false
        }
    }
}
