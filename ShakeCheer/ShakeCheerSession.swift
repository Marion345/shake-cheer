import Foundation

@MainActor
final class ShakeCheerSession: ObservableObject {
    @Published private(set) var isRunning = false

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
    }

    private func configureCallbacks() {
        motionEngine.onShake = { [weak self] intensity in
            guard let self, let sound = self.selectedSound else { return }
            self.audioEngine.play(sound, intensity: intensity)
        }

        motionEngine.onMotion = { [weak self] in
            guard let self, let sound = self.selectedSound else { return }
            self.audioEngine.keepAlive(sound)
        }
    }
}
