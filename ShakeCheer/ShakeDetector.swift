import CoreMotion
import Foundation

@MainActor
final class ShakeDetector: ObservableObject {
    @Published var isRunning = false
    @Published var shakeCount = 0
    @Published var liveIntensity = 0.0

    /// 0 = easiest to trigger, 1 = hardest to trigger.
    @Published var sensitivity = 0.5

    var onShake: ((Double) -> Void)?

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var lastTrigger = Date.distantPast

    init() {
        queue.name = "ShakeCheer.MotionQueue"
        queue.qualityOfService = .userInteractive
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        shakeCount = 0
        isRunning = true
        lastTrigger = Date.distantPast
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let a = motion.userAcceleration
            let magnitude = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)

            Task { @MainActor in
                self.process(magnitude: magnitude)
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
        liveIntensity = 0
    }

    private func process(magnitude: Double) {
        liveIntensity = min(magnitude / 3.5, 1.0)

        // Sensitivity slider maps to a threshold of ~0.75g–2.0g user acceleration.
        let threshold = 0.75 + sensitivity * 1.25
        guard magnitude >= threshold else { return }

        // Version B: harder movement produces more frequent sound triggers.
        let normalized = min(max((magnitude - threshold) / 2.25, 0), 1)
        let cooldown = 0.34 - (0.22 * normalized) // ~340 ms down to ~120 ms

        let now = Date()
        guard now.timeIntervalSince(lastTrigger) >= cooldown else { return }
        lastTrigger = now

        shakeCount += 1
        onShake?(normalized)
    }
}
