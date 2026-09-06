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
    let playbackMode: PlaybackMode
    let accessLevel: AccessLevel
    let loopEndTime: TimeInterval?
    let loopCrossfadeDuration: TimeInterval
    let volumeMultiplier: Double
    let allowsRetriggerWhilePlaying: Bool

    init(
        id: String,
        title: String,
        emoji: String,
        category: SoundCategory,
        audio: AudioResource,
        playbackMode: PlaybackMode,
        accessLevel: AccessLevel,
        loopEndTime: TimeInterval? = nil,
        loopCrossfadeDuration: TimeInterval = 0.4,
        volumeMultiplier: Double = 1.0,
        allowsRetriggerWhilePlaying: Bool = true
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.category = category
        self.audio = audio
        self.playbackMode = playbackMode
        self.accessLevel = accessLevel
        self.loopEndTime = loopEndTime
        self.loopCrossfadeDuration = loopCrossfadeDuration
        self.volumeMultiplier = volumeMultiplier
        self.allowsRetriggerWhilePlaying = allowsRetriggerWhilePlaying
    }

    var fileName: String { audio.fileName }
    var fileExtension: String { audio.fileExtension }
    var visualAssetName: String { "Sound-\(id)" }
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
        playbackMode: .impact,
        accessLevel: .free
    )

    static let applause = SoundDefinition(
        id: "applause",
        title: "Applaudissements",
        emoji: "👏",
        category: .basic,
        audio: AudioResource(fileName: "applause", fileExtension: "wav"),
        playbackMode: .impact,
        accessLevel: .free
    )

    static let cheer = SoundDefinition(
        id: "cheer",
        title: "Encouragement stade",
        emoji: "🏟️",
        category: .sports,
        audio: AudioResource(fileName: "cheer-crowd", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.75,
        loopCrossfadeDuration: 0.22
    )

    static let drum = SoundDefinition(
        id: "drum",
        title: "Foule & tambours",
        emoji: "🥁",
        category: .sports,
        audio: AudioResource(fileName: "drum-crowd", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 5.75,
        loopCrossfadeDuration: 0.24
    )

    static let noisemaker = SoundDefinition(
        id: "noisemaker",
        title: "Crécelle",
        emoji: "🪇",
        category: .basic,
        audio: AudioResource(fileName: "noisemaker", fileExtension: "wav"),
        playbackMode: .impact,
        accessLevel: .free
    )

    static let stadiumHorn = SoundDefinition(
        id: "stadium-horn",
        title: "Corne cargo",
        emoji: "📯",
        category: .sports,
        audio: AudioResource(fileName: "cargo-ship-horn", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 8.10,
        loopCrossfadeDuration: 0.45
    )

    static let airHorn = SoundDefinition(
        id: "air-horn",
        title: "Air Horn",
        emoji: "📯",
        category: .party,
        audio: AudioResource(fileName: "air-horn", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let crowdHey = SoundDefinition(
        id: "crowd-hey",
        title: "Foule en fête",
        emoji: "🥳",
        category: .party,
        audio: AudioResource(fileName: "crowd-hey", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.65,
        loopCrossfadeDuration: 0.22
    )

    static let djScratch = SoundDefinition(
        id: "dj-scratch",
        title: "DJ Scratch",
        emoji: "💿",
        category: .party,
        audio: AudioResource(fileName: "dj-scratch", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let champagnePops = SoundDefinition(
        id: "champagne-pops",
        title: "Trois bouchons",
        emoji: "🍾",
        category: .party,
        audio: AudioResource(fileName: "champagne-pops", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro,
        allowsRetriggerWhilePlaying: false
    )

    static let partyBlower = SoundDefinition(
        id: "party-blower",
        title: "Sans-gêne",
        emoji: "🎉",
        category: .party,
        audio: AudioResource(fileName: "party-blower", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let refereeWhistle = SoundDefinition(
        id: "referee-whistle",
        title: "Sifflet arbitre",
        emoji: "⚽️",
        category: .sports,
        audio: AudioResource(fileName: "referee-whistle", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let podium = SoundDefinition(
        id: "podium",
        title: "Célébration",
        emoji: "🙌",
        category: .sports,
        audio: AudioResource(fileName: "podium", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 6.20,
        loopCrossfadeDuration: 0.30
    )

    static let levelUp = SoundDefinition(
        id: "level-up",
        title: "Level Up",
        emoji: "⬆️",
        category: .gaming,
        audio: AudioResource(fileName: "level-up", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let coin = SoundDefinition(
        id: "coin",
        title: "Pièce gagnée",
        emoji: "🪙",
        category: .gaming,
        audio: AudioResource(fileName: "coin", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let victory = SoundDefinition(
        id: "victory",
        title: "Victoire",
        emoji: "🏆",
        category: .gaming,
        audio: AudioResource(fileName: "victory", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 6.75,
        loopCrossfadeDuration: 0.25
    )

    static let failBuzzer = SoundDefinition(
        id: "fail-buzzer",
        title: "Échec",
        emoji: "❌",
        category: .gaming,
        audio: AudioResource(fileName: "fail-buzzer", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let gameOver = SoundDefinition(
        id: "game-over",
        title: "Game Over",
        emoji: "🎮",
        category: .gaming,
        audio: AudioResource(fileName: "game-over", fileExtension: "mp3"),
        playbackMode: .impact,
        accessLevel: .pro
    )

    static let sadTrumpet = SoundDefinition(
        id: "sad-trumpet",
        title: "Trompette triste",
        emoji: "🎺",
        category: .funny,
        audio: AudioResource(fileName: "sad-trumpet", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 3.75,
        loopCrossfadeDuration: 0.08,
        volumeMultiplier: 1.15
    )

    static let boo = SoundDefinition(
        id: "boo",
        title: "Boo!",
        emoji: "👎",
        category: .funny,
        audio: AudioResource(fileName: "boo", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.75,
        loopCrossfadeDuration: 0.18
    )

    static let crowdDisappointment = SoundDefinition(
        id: "crowd-disappointment",
        title: "Foule déçue",
        emoji: "😭",
        category: .funny,
        audio: AudioResource(fileName: "crowd-disappointment", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 4.75,
        loopCrossfadeDuration: 0.20
    )

    static let crickets = SoundDefinition(
        id: "crickets",
        title: "Criquets",
        emoji: "🦗",
        category: .funny,
        audio: AudioResource(fileName: "crickets", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 9.30,
        loopCrossfadeDuration: 0.35
    )

    static let laughTrack = SoundDefinition(
        id: "laugh-track",
        title: "Rires de foule",
        emoji: "🤣",
        category: .funny,
        audio: AudioResource(fileName: "laugh-track", fileExtension: "mp3"),
        playbackMode: .sustained,
        accessLevel: .pro,
        loopEndTime: 3.00,
        loopCrossfadeDuration: 0.16
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
