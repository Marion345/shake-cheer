import AVFoundation
import Foundation

@MainActor
final class SoundManager: AudioEngine {
    private var players: [AVAudioPlayer] = []
    private let maxConcurrentPlayers = 8

    private var sustainedPlayer: AVAudioPlayer?
    private var transitionPlayer: AVAudioPlayer?
    private var sustainedSound: SoundDefinition?
    private var sustainedVolume: Float = 0.7
    private var sustainedStopTask: Task<Void, Never>?
    private var sustainedLoopTask: Task<Void, Never>?
    private var isStoppingSustainedAudio = false

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
        guard sound.usesSustainedPlayback else { return }

        let hasActivePlayer = sustainedPlayer?.isPlaying == true
            || transitionPlayer?.isPlaying == true

        guard sustainedSound?.id == sound.id, hasActivePlayer else {
            sustain(sound, intensity: 0.5)
            return
        }

        if isStoppingSustainedAudio {
            isStoppingSustainedAudio = false
            transitionPlayer?.stop()
            transitionPlayer = nil
            sustainedPlayer?.setVolume(sustainedVolume, fadeDuration: 0.08)
            scheduleNextLoop(for: sound)
        }

        scheduleSustainedStop()
    }

    func stopAll() {
        sustainedStopTask?.cancel()
        sustainedLoopTask?.cancel()
        sustainedStopTask = nil
        sustainedLoopTask = nil
        isStoppingSustainedAudio = false

        sustainedPlayer?.stop()
        transitionPlayer?.stop()
        sustainedPlayer = nil
        transitionPlayer = nil
        sustainedSound = nil

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
        isStoppingSustainedAudio = false
        sustainedVolume = volume(for: intensity)

        if sustainedSound?.id != sound.id || sustainedPlayer == nil {
            sustainedLoopTask?.cancel()
            sustainedPlayer?.stop()
            transitionPlayer?.stop()
            transitionPlayer = nil

            guard let url = audioURL(for: sound) else { return }

            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = 0
                player.volume = sustainedVolume
                player.prepareToPlay()
                player.play()

                sustainedPlayer = player
                sustainedSound = sound
                scheduleNextLoop(for: sound)
            } catch {
                print("Sustained playback error: \(error.localizedDescription)")
                return
            }
        } else if transitionPlayer == nil {
            sustainedPlayer?.setVolume(sustainedVolume, fadeDuration: 0.08)
            if sustainedPlayer?.isPlaying == false {
                sustainedPlayer?.currentTime = 0
                sustainedPlayer?.play()
                scheduleNextLoop(for: sound)
            }
        }

        scheduleSustainedStop()
    }

    private func scheduleNextLoop(for sound: SoundDefinition) {
        sustainedLoopTask?.cancel()

        guard let currentPlayer = sustainedPlayer,
              let url = audioURL(for: sound) else { return }

        let requestedLoopEnd = sound.loopEndTime ?? currentPlayer.duration
        let loopEnd = min(max(requestedLoopEnd, 0.2), currentPlayer.duration)
        let crossfadeDuration = min(
            sound.loopCrossfadeDuration,
            loopEnd * 0.25
        )
        let delay = max(loopEnd - crossfadeDuration, 0.1)
        let expectedSoundID = sound.id

        sustainedLoopTask = Task { [weak self, weak currentPlayer] in
            do {
                try await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled,
                      let self,
                      let currentPlayer,
                      self.sustainedSound?.id == expectedSoundID,
                      !self.isStoppingSustainedAudio else { return }

                let nextPlayer = try AVAudioPlayer(contentsOf: url)
                nextPlayer.numberOfLoops = 0
                nextPlayer.volume = 0
                nextPlayer.prepareToPlay()
                nextPlayer.play()

                self.transitionPlayer = nextPlayer
                nextPlayer.setVolume(self.sustainedVolume, fadeDuration: crossfadeDuration)
                currentPlayer.setVolume(0, fadeDuration: crossfadeDuration)

                try await Task.sleep(for: .seconds(crossfadeDuration))
                guard !Task.isCancelled,
                      self.sustainedSound?.id == expectedSoundID,
                      !self.isStoppingSustainedAudio else { return }

                currentPlayer.stop()
                self.sustainedPlayer = nextPlayer
                self.transitionPlayer = nil
                self.scheduleNextLoop(for: sound)
            } catch is CancellationError {
                // Stopping or changing sounds cancels the pending transition.
            } catch {
                print("Sustained loop error: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleSustainedStop() {
        sustainedStopTask?.cancel()
        sustainedStopTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(2.2))
                guard !Task.isCancelled, let self else { return }

                self.isStoppingSustainedAudio = true
                self.sustainedLoopTask?.cancel()
                self.sustainedPlayer?.setVolume(0, fadeDuration: 0.35)
                self.transitionPlayer?.setVolume(0, fadeDuration: 0.35)

                try await Task.sleep(for: .seconds(0.35))
                guard !Task.isCancelled else { return }

                self.sustainedPlayer?.stop()
                self.transitionPlayer?.stop()
                self.sustainedPlayer = nil
                self.transitionPlayer = nil
                self.sustainedSound = nil
                self.sustainedLoopTask = nil
                self.isStoppingSustainedAudio = false
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
