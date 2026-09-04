import Foundation

@MainActor
final class ShakeCheerSession: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var liveIntensity = 0.0
    @Published private(set) var animationTrigger = 0

    private let motionEngine: any MotionEngine
    private let audioEngine: any AudioEngine
    private var selectedSound: SoundDefinition?

    init(
        motionEngine: any MotionEngine,
        audioEngine: any AudioEngine
    ) {
        self.motionEngine = motionEngine
        self.audioEngine = audioEngine
        configureCallbacks()
    }

    func start(sound: SoundDefinition) {
        selectedSound = sound
        isRunning = motionEngine.start()
    }

    func stop() {
        motionEngine.stop()
        audioEngine.stopAll()
        isRunning = false
        liveIntensity = 0
    }

    private func configureCallbacks() {
        motionEngine.onShake = { [weak self] intensity in
            guard let self, let sound = self.selectedSound else { return }
            self.animationTrigger += 1
            self.audioEngine.play(sound, intensity: intensity)
        }

        motionEngine.onMotion = { [weak self] in
            guard let self, let sound = self.selectedSound else { return }
            self.audioEngine.keepAlive(sound)
        }

        motionEngine.onIntensityChange = { [weak self] intensity in
            self?.liveIntensity = intensity
        }
    }
}
