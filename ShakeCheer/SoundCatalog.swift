import Foundation

enum SoundCategory: String, CaseIterable, Identifiable {
    case sports
    case party
    case gaming
    case funny
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sports: return "Sports"
        case .party: return "Party"
        case .gaming: return "Gaming"
        case .funny: return "Funny"
        case .custom: return "Mes sons"
        }
    }
}

enum PlaybackMode: String {
    case impact
    case sustained
    case custom
}

enum AccessLevel: String {
    case free
    case pro
}

enum SoundAnimationKind: String {
    case bell
    case applause
    case cheer
    case drum
    case noisemaker
    case stadiumHorn
}

struct AudioResource: Hashable {
    let fileName: String
    let fileExtension: String
}

struct SoundDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let emoji: String
    let category: SoundCategory
    let audio: AudioResource
    let animation: SoundAnimationKind
    let playbackMode: PlaybackMode
    let accessLevel: AccessLevel

    var fileName: String { audio.fileName }
    var fileExtension: String { audio.fileExtension }
    var usesSustainedPlayback: Bool { playbackMode == .sustained }
    var isPro: Bool { accessLevel == .pro }
}

enum SoundCatalog {
    static let bell = SoundDefinition(
        id: "bell",
        title: "Cloche",
        emoji: "🔔",
        category: .sports,
        audio: AudioResource(fileName: "bell", fileExtension: "wav"),
        animation: .bell,
        playbackMode: .impact,
        accessLevel: .free
    )

    static let applause = SoundDefinition(
        id: "applause",
        title: "Applaudissements",
        emoji: "👏",
        category: .sports,
        audio: AudioResource(fileName: "applause", fileExtension: "wav"),
        animation: .applause,
        playbackMode: .impact,
        accessLevel: .free
    )

    static let cheer = SoundDefinition(
        id: "cheer",
        title: "Encouragement",
        emoji: "📣",
        category: .sports,
        audio: AudioResource(fileName: "cheer-crowd", fileExtension: "mp3"),
        animation: .cheer,
        playbackMode: .sustained,
        accessLevel: .free
    )

    static let drum = SoundDefinition(
        id: "drum",
        title: "Tambour",
        emoji: "🥁",
        category: .party,
        audio: AudioResource(fileName: "drum-crowd", fileExtension: "mp3"),
        animation: .drum,
        playbackMode: .sustained,
        accessLevel: .pro
    )

    static let noisemaker = SoundDefinition(
        id: "noisemaker",
        title: "Crécelle",
        emoji: "🪇",
        category: .party,
        audio: AudioResource(fileName: "noisemaker", fileExtension: "wav"),
        animation: .noisemaker,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let stadiumHorn = SoundDefinition(
        id: "stadium-horn",
        title: "Corne de stade",
        emoji: "📯",
        category: .sports,
        audio: AudioResource(fileName: "stadium-horn", fileExtension: "wav"),
        animation: .stadiumHorn,
        playbackMode: .sustained,
        accessLevel: .pro
    )

    static let allSounds: [SoundDefinition] = [
        bell,
        applause,
        cheer,
        drum,
        noisemaker,
        stadiumHorn
    ]

    static var freeSounds: [SoundDefinition] {
        allSounds.filter { $0.accessLevel == .free }
    }

    static var proSounds: [SoundDefinition] {
        allSounds.filter { $0.accessLevel == .pro }
    }

    static func sounds(in category: SoundCategory) -> [SoundDefinition] {
        allSounds.filter { $0.category == category }
    }

    static func definition(id: String) -> SoundDefinition? {
        allSounds.first { $0.id == id }
    }
}
