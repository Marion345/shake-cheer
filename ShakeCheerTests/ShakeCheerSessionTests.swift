import XCTest
@testable import ShakeCheer

@MainActor
final class ShakeCheerSessionTests: XCTestCase {
    func testStartUsesInjectedMotionEngine() {
        let motion = MotionEngineMock()
        let audio = AudioEngineMock()
        let session = ShakeCheerSession(motionEngine: motion, audioEngine: audio)

        session.start(sound: SoundCatalog.bell)

        XCTAssertTrue(session.isRunning)
        XCTAssertEqual(motion.startCount, 1)
    }

    func testUnavailableMotionDoesNotStartSession() {
        let motion = MotionEngineMock()
        motion.startResult = false
        let session = ShakeCheerSession(
            motionEngine: motion,
            audioEngine: AudioEngineMock()
        )

        session.start(sound: SoundCatalog.bell)

        XCTAssertFalse(session.isRunning)
    }

    func testShakePlaysSelectedSoundAndTriggersAnimation() {
        let motion = MotionEngineMock()
        let audio = AudioEngineMock()
        let session = ShakeCheerSession(motionEngine: motion, audioEngine: audio)
        session.start(sound: SoundCatalog.drum)

        motion.simulateShake(intensity: 0.8)

        XCTAssertEqual(audio.playedSounds, [SoundCatalog.drum])
        XCTAssertEqual(audio.lastIntensity, 0.8, accuracy: 0.001)
        XCTAssertEqual(session.animationTrigger, 1)
    }

    func testMotionKeepsSelectedSoundAlive() {
        let motion = MotionEngineMock()
        let audio = AudioEngineMock()
        let session = ShakeCheerSession(motionEngine: motion, audioEngine: audio)
        session.start(sound: SoundCatalog.stadiumHorn)

        motion.simulateMotion()

        XCTAssertEqual(audio.keptAliveSounds, [SoundCatalog.stadiumHorn])
    }

    func testStopStopsBothEnginesAndResetsState() {
        let motion = MotionEngineMock()
        let audio = AudioEngineMock()
        let session = ShakeCheerSession(motionEngine: motion, audioEngine: audio)
        session.start(sound: SoundCatalog.cheer)
        motion.simulateIntensity(0.7)

        session.stop()

        XCTAssertEqual(motion.stopCount, 1)
        XCTAssertEqual(audio.stopAllCount, 1)
        XCTAssertFalse(session.isRunning)
        XCTAssertEqual(session.liveIntensity, 0)
    }
}

@MainActor
private final class MotionEngineMock: MotionEngine {
    var onShake: ((Double) -> Void)?
    var onMotion: (() -> Void)?
    var onIntensityChange: ((Double) -> Void)?

    var startResult = true
    private(set) var startCount = 0
    private(set) var stopCount = 0

    func start() -> Bool {
        startCount += 1
        return startResult
    }

    func stop() {
        stopCount += 1
        onIntensityChange?(0)
    }

    func simulateShake(intensity: Double) {
        onShake?(intensity)
    }

    func simulateMotion() {
        onMotion?()
    }

    func simulateIntensity(_ intensity: Double) {
        onIntensityChange?(intensity)
    }
}

@MainActor
private final class AudioEngineMock: AudioEngine {
    private(set) var playedSounds: [SoundDefinition] = []
    private(set) var keptAliveSounds: [SoundDefinition] = []
    private(set) var lastIntensity = 0.0
    private(set) var stopAllCount = 0

    func play(_ sound: SoundDefinition, intensity: Double) {
        playedSounds.append(sound)
        lastIntensity = intensity
    }

    func keepAlive(_ sound: SoundDefinition) {
        keptAliveSounds.append(sound)
    }

    func stopAll() {
        stopAllCount += 1
    }
}
