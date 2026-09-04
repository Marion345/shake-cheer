import Foundation

enum SoundCategory: String, CaseIterable, Identifiable {
    case basic
    case sports
    case party
    case gaming
    case funny
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: return "De base"
        case .sports: return "Sports"
        case .party: return "Party"
        case .gaming: return "Gaming"
        case .funny: return "Funny"
        case .custom: return "Mes sons"
        }
    }

    var icon: String {
        switch self {
        case .basic: return "star.fill"
        case .sports: return "sportscourt.fill"
        case .party: return "music.note"
        case .gaming: return "gamecontroller.fill"
        case .funny: return "face.smiling.fill"
        case .custom: return "waveform.badge.plus"
        }
    }

    var accessLevel: AccessLevel {
        self == .basic ? .free : .pro
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
    case crowdDisappointment
    case crickets
    case levelUp
    case podium
    case coin
    case victory
    case refereeWhistle
    case laughTrack
    case failBuzzer
    case gameOver
    case crowdHey
    case djScratch
    case champagnePops
    case partyBlower
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
        category: .basic,
        audio: AudioResource(fileName: "bell", fileExtension: "wav"),
        animation: .bell,
        playbackMode: .impact,
        accessLevel: .free
    )

    static let applause = SoundDefinition(
        id: "applause",
        title: "Applaudissements",
        emoji: "👏",
        category: .basic,
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
        accessLevel: .pro
    )

    static let drum = SoundDefinition(
        id: "drum",
        title: "Tambour",
        emoji: "🥁",
        category: .sports,
        audio: AudioResource(fileName: "drum-crowd", fileExtension: "mp3"),
        animation: .drum,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.20,
        loopCrossfadeDuration: 0.28
    )

    static let noisemaker = SoundDefinition(
        id: "noisemaker",
        title: "Crécelle",
        emoji: "🪇",
        category: .basic,
        audio: AudioResource(fileName: "noisemaker", fileExtension: "wav"),
        animation: .noisemaker,
        playbackMode: .impact,
        accessLevel: .free
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
        loopEndTime: 8.10,
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

    static let crowdHey = SoundDefinition(
        id: "crowd-hey",
        title: "Foule « Hey! »",
        emoji: "🙌",
        category: .party,
        audio: AudioResource(fileName: "crowd-hey", fileExtension: "mp3"),
        animation: .crowdHey,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 3.30,
        loopCrossfadeDuration: 0.25
    )

    static let djScratch = SoundDefinition(
        id: "dj-scratch",
        title: "DJ Scratch",
        emoji: "💿",
        category: .party,
        audio: AudioResource(fileName: "dj-scratch", fileExtension: "mp3"),
        animation: .djScratch,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let champagnePops = SoundDefinition(
        id: "champagne-pops",
        title: "Trois bouchons",
        emoji: "🍾",
        category: .party,
        audio: AudioResource(fileName: "champagne-pops", fileExtension: "mp3"),
        animation: .champagnePops,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let partyBlower = SoundDefinition(
        id: "party-blower",
        title: "Sans-gêne",
        emoji: "🥳",
        category: .party,
        audio: AudioResource(fileName: "party-blower", fileExtension: "mp3"),
        animation: .partyBlower,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.50,
        loopCrossfadeDuration: 0.20
    )

    static let refereeWhistle = SoundDefinition(
        id: "referee-whistle",
        title: "Sifflet",
        emoji: "📣",
        category: .sports,
        audio: AudioResource(fileName: "referee-whistle", fileExtension: "mp3"),
        animation: .refereeWhistle,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let podium = SoundDefinition(
        id: "podium",
        title: "Podium",
        emoji: "🏆",
        category: .sports,
        audio: AudioResource(fileName: "podium", fileExtension: "mp3"),
        animation: .podium,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 6.90,
        loopCrossfadeDuration: 0.35
    )

    static let levelUp = SoundDefinition(
        id: "level-up",
        title: "Level Up",
        emoji: "⬆️",
        category: .gaming,
        audio: AudioResource(fileName: "level-up", fileExtension: "mp3"),
        animation: .levelUp,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 1.15,
        loopCrossfadeDuration: 0.25
    )

    static let coin = SoundDefinition(
        id: "coin",
        title: "Pièce gagnée",
        emoji: "🪙",
        category: .gaming,
        audio: AudioResource(fileName: "coin", fileExtension: "mp3"),
        animation: .coin,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let victory = SoundDefinition(
        id: "victory",
        title: "Victoire",
        emoji: "🎉",
        category: .gaming,
        audio: AudioResource(fileName: "victory", fileExtension: "mp3"),
        animation: .victory,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 6.05,
        loopCrossfadeDuration: 0.25
    )

    static let failBuzzer = SoundDefinition(
        id: "fail-buzzer",
        title: "Échec",
        emoji: "❌",
        category: .gaming,
        audio: AudioResource(fileName: "fail-buzzer", fileExtension: "mp3"),
        animation: .failBuzzer,
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let gameOver = SoundDefinition(
        id: "game-over",
        title: "Game Over",
        emoji: "☠️",
        category: .gaming,
        audio: AudioResource(fileName: "game-over", fileExtension: "mp3"),
        animation: .gameOver,
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
        loopEndTime: 7.35,
        loopCrossfadeDuration: 0.06,
        volumeMultiplier: 1.55
    )

    static let boo = SoundDefinition(
        id: "boo",
        title: "Boo",
        emoji: "👎",
        category: .funny,
        audio: AudioResource(fileName: "boo", fileExtension: "mp3"),
        animation: .boo,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 2.15,
        loopCrossfadeDuration: 0.20
    )

    static let crowdDisappointment = SoundDefinition(
        id: "crowd-disappointment",
        title: "Foule déçue",
        emoji: "😩",
        category: .funny,
        audio: AudioResource(fileName: "boo-crowd", fileExtension: "mp3"),
        animation: .crowdDisappointment,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 3.85,
        loopCrossfadeDuration: 0.20
    )

    static let crickets = SoundDefinition(
        id: "crickets",
        title: "Criquets",
        emoji: "🦗",
        category: .funny,
        audio: AudioResource(fileName: "crickets", fileExtension: "mp3"),
        animation: .crickets,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 9.30,
        loopCrossfadeDuration: 0.35
    )

    static let laughTrack = SoundDefinition(
        id: "laugh-track",
        title: "Rires",
        emoji: "😂",
        category: .funny,
        audio: AudioResource(fileName: "laugh-track", fileExtension: "mp3"),
        animation: .laughTrack,
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 7.50,
        loopCrossfadeDuration: 0.20
    )

    static let selectableCategories: [SoundCategory] = [
        .basic,
        .sports,
        .party,
        .gaming,
        .funny
    ]

    static let allSounds: [SoundDefinition] = [
        bell,
        applause,
        noisemaker,
        cheer,
        drum,
        stadiumHorn,
        refereeWhistle,
        podium,
        airHorn,
        crowdHey,
        djScratch,
        champagnePops,
        partyBlower,
        levelUp,
        coin,
        victory,
        failBuzzer,
        gameOver,
        sadTrumpet,
        boo,
        crowdDisappointment,
        crickets,
        laughTrack
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
