import CoreMotion
import Foundation

@MainActor
final class ShakeDetector: ObservableObject {
    @Published var isRunning = false
    @Published var liveIntensity = 0.0

    /// 0 = easiest to trigger, 1 = hardest to trigger.
    @Published var sensitivity = 0.5

    var onShake: ((Double) -> Void)?
    var onMotion: (() -> Void)?

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var lastTrigger = Date.distantPast
    private var lastMotionSignal = Date.distantPast

    init() {
        queue.name = "ShakeCheer.MotionQueue"
        queue.qualityOfService = .userInteractive
    }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }

        isRunning = true
        lastTrigger = Date.distantPast
        lastMotionSignal = Date.distantPast
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let a = motion.userAcceleration
            let magnitude = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)

            let r = motion.rotationRate
            let rotationMagnitude = sqrt(r.x * r.x + r.y * r.y + r.z * r.z)
            let activityMagnitude = max(magnitude, rotationMagnitude / 8.0)

            Task { @MainActor in
                self.process(magnitude: magnitude, activityMagnitude: activityMagnitude)
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
        liveIntensity = 0
    }

    private func process(magnitude: Double, activityMagnitude: Double) {
        liveIntensity = min(magnitude / 3.5, 1.0)
        let now = Date()

        // A lower motion threshold keeps sustained sounds alive between full shake peaks.
        if activityMagnitude >= 0.04, now.timeIntervalSince(lastMotionSignal) >= 0.12 {
            lastMotionSignal = now
            onMotion?()
        }

        // Fixed medium sensitivity: ~1.375g user acceleration.
        let threshold = 0.75 + sensitivity * 1.25
        guard magnitude >= threshold else { return }

        // Harder movement produces more frequent sound triggers.
        let normalized = min(max((magnitude - threshold) / 2.25, 0), 1)
        let cooldown = 0.34 - (0.22 * normalized) // ~340 ms down to ~120 ms

        guard now.timeIntervalSince(lastTrigger) >= cooldown else { return }
        lastTrigger = now

        onShake?(normalized)
    }
}
