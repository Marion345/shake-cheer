import AVFoundation
import Foundation

@MainActor
final class SoundManager: AudioEngine {
    private var players: [AVAudioPlayer] = []
    private let maxConcurrentPlayers = 8

    private var sustainedPlayer: AVAudioPlayer?
    private var sustainedSoundID: String?
    private var sustainedStopTask: Task<Void, Never>?

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

    func play(_ sound: SoundDefinition, intensity: Double) {
        if sound.usesSustainedPlayback {
            sustain(sound, intensity: intensity)
        } else {
            playImpact(sound, intensity: intensity)
        }
    }

    func keepAlive(_ sound: SoundDefinition) {
        guard sound.usesSustainedPlayback,
              sustainedSoundID == sound.id,
              sustainedPlayer?.isPlaying == true else { return }

        scheduleSustainedStop()
    }

    func stopAll() {
        sustainedStopTask?.cancel()
        sustainedStopTask = nil
        sustainedPlayer?.stop()
        sustainedPlayer = nil
        sustainedSoundID = nil

        players.forEach { $0.stop() }
        players.removeAll()
    }

    private func playImpact(_ sound: SoundDefinition, intensity: Double) {
        guard let url = audioURL(for: sound) else { return }

        do {
            players.removeAll { !$0.isPlaying }
            if players.count >= maxConcurrentPlayers {
                players.removeFirst().stop()
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume(for: intensity)
            player.prepareToPlay()
            player.play()
            players.append(player)
        } catch {
            print("Playback error: \(error.localizedDescription)")
        }
    }

    private func sustain(_ sound: SoundDefinition, intensity: Double) {
        sustainedStopTask?.cancel()

        if sustainedSoundID != sound.id || sustainedPlayer == nil {
            sustainedPlayer?.stop()

            guard let url = audioURL(for: sound) else { return }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = volume(for: intensity)
                player.prepareToPlay()
                player.play()
                sustainedPlayer = player
                sustainedSoundID = sound.id
            } catch {
                print("Sustained playback error: \(error.localizedDescription)")
                return
            }
        } else {
            sustainedPlayer?.setVolume(volume(for: intensity), fadeDuration: 0.08)
            if sustainedPlayer?.isPlaying == false {
                sustainedPlayer?.play()
            }
        }

        scheduleSustainedStop()
    }

    private func scheduleSustainedStop() {
        sustainedStopTask?.cancel()
        sustainedStopTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(2.2))
                guard !Task.isCancelled, let self, let player = self.sustainedPlayer else { return }

                player.setVolume(0, fadeDuration: 0.35)
                try await Task.sleep(for: .seconds(0.35))
                guard !Task.isCancelled else { return }

                player.stop()
                self.sustainedPlayer = nil
                self.sustainedSoundID = nil
            } catch {
                // Ongoing motion cancelled the fade-out and extended playback.
            }
        }
    }

    private func audioURL(for sound: SoundDefinition) -> URL? {
        guard let url = Bundle.main.url(
            forResource: sound.fileName,
            withExtension: sound.fileExtension
        ) else {
            print("Missing sound: \(sound.fileName).\(sound.fileExtension)")
            return nil
        }
        return url
    }

    private func volume(for intensity: Double) -> Float {
        Float(min(max(0.55 + intensity * 0.12, 0.55), 1.0))
    }
}
