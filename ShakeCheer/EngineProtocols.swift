import Foundation

@MainActor
protocol MotionEngine: AnyObject {
    var onShake: ((Double) -> Void)? { get set }
    var onMotion: (() -> Void)? { get set }
    var onIntensityChange: ((Double) -> Void)? { get set }

    @discardableResult
    func start() -> Bool
    func stop()
}

@MainActor
protocol AudioEngine: AnyObject {
    func play(_ sound: SoundDefinition, intensity: Double)
    func keepAlive(_ sound: SoundDefinition)
    func stopAll()
}
