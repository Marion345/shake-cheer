import AVFoundation
import Foundation

@MainActor
final class SoundManager: ObservableObject {
    private var players: [AVAudioPlayer] = []
    private let maxConcurrentPlayers = 8

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    func play(_ sound: CheerSound, intensity: Double) {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav") else {
            print("Missing sound: \(sound.fileName).wav")
            return
        }

        do {
            players.removeAll { !$0.isPlaying }
            if players.count >= maxConcurrentPlayers {
                players.removeFirst()
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = Float(min(max(0.55 + intensity * 0.12, 0.55), 1.0))
            player.prepareToPlay()
            player.play()
            players.append(player)
        } catch {
            print("Playback error: \(error.localizedDescription)")
        }
    }
}
