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
    case airHorn
    case sadTrumpet
    case boo
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
    let loopEndTime: TimeInterval?
    let loopCrossfadeDuration: TimeInterval
    let volumeMultiplier: Double

    init(
        id: String,
        title: String,
        emoji: String,
        category: SoundCategory,
        audio: AudioResource,
        animation: SoundAnimationKind,
        playbackMode: PlaybackMode,
        accessLevel: AccessLevel,
        loopEndTime: TimeInterval? = nil,
        loopCrossfadeDuration: TimeInterval = 0.4,
        volumeMultiplier: Double = 1.0
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.category = category
        self.audio = audio
        self.animation = animation
        self.playbackMode = playbackMode
        self.accessLevel = accessLevel
        self.loopEndTime = loopEndTime
        self.loopCrossfadeDuration = loopCrossfadeDuration
        self.volumeMultiplier = volumeMultiplier
    }

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
        accessLevel: .pro,
        loopEndTime: 4.69,
        loopCrossfadeDuration: 0.28
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
        title: "Corne cargo",
        emoji: "📯",
        category: .sports,
        audio: AudioResource(fileName: "cargo-ship-horn", fileExtension: "mp3"),
        animation: .stadiumHorn,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 2.10,
        loopCrossfadeDuration: 0.45
    )

    static let airHorn = SoundDefinition(
        id: "air-horn",
        title: "Air Horn",
        emoji: "📢",
        category: .party,
        audio: AudioResource(fileName: "air-horn", fileExtension: "mp3"),
        animation: .airHorn,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let sadTrumpet = SoundDefinition(
        id: "sad-trumpet",
        title: "Trompette triste",
        emoji: "🎺",
        category: .funny,
        audio: AudioResource(fileName: "sad-trumpet", fileExtension: "mp3"),
        animation: .sadTrumpet,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 2.30,
        loopCrossfadeDuration: 0.06,
        volumeMultiplier: 1.55
    )

    static let boo = SoundDefinition(
        id: "boo",
        title: "Boo",
        emoji: "👎",
        category: .funny,
        audio: AudioResource(fileName: "boo-crowd", fileExtension: "mp3"),
        animation: .boo,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 2.70,
        loopCrossfadeDuration: 0.20
    )

    static let allSounds: [SoundDefinition] = [
        bell,
        applause,
        cheer,
        drum,
        noisemaker,
        stadiumHorn,
        airHorn,
        sadTrumpet,
        boo
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
