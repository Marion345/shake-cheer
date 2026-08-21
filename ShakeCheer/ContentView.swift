import SwiftUI

struct ContentView: View {
    @StateObject private var detector = ShakeDetector()
    @StateObject private var soundManager = SoundManager()
    @State private var selectedSound: CheerSound = .bell
    @State private var animationTrigger = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer(minLength: 12)

                SoundAnimationView(sound: selectedSound, trigger: animationTrigger)
                    .scaleEffect(1.0 + detector.liveIntensity * 0.08)
                    .animation(.easeOut(duration: 0.08), value: detector.liveIntensity)

                VStack(spacing: 6) {
                    Text("SHAKE CHEER")
                        .font(.largeTitle.bold())
                    Text(detector.isRunning ? "Secoue ton iPhone!" : "Choisis un son et appuie sur Start")
                        .foregroundStyle(.secondary)
                }

                Picker("Sound", selection: $selectedSound) {
                    ForEach(CheerSound.allCases) { sound in
                        Text("\(sound.emoji) \(sound.title)").tag(sound)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Sensibilité")
                            .font(.headline)
                        Spacer()
                        Text(sensitivityLabel)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $detector.sensitivity, in: 0...1)
                        .disabled(detector.isRunning)
                }

                VStack(spacing: 8) {
                    Text("Shakes")
                        .foregroundStyle(.secondary)
                    Text("\(detector.shakeCount)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                }

                Button {
                    if detector.isRunning {
                        detector.stop()
                    } else {
                        detector.start()
                    }
                } label: {
                    Text(detector.isRunning ? "STOP" : "START")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if !detector.isRunning {
                    Text("Version B · plus le mouvement est fort, plus les sons peuvent se déclencher rapidement.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                detector.onShake = { intensity in
                    animationTrigger += 1
                    soundManager.play(selectedSound, intensity: intensity)
                }
            }
            .onDisappear {
                detector.stop()
            }
        }
    }

    private var sensitivityLabel: String {
        switch detector.sensitivity {
        case 0..<0.34: return "Élevée"
        case 0.34..<0.67: return "Moyenne"
        default: return "Faible"
        }
    }
}

private struct SoundAnimationView: View {
    let sound: CheerSound
    let trigger: Int

    var body: some View {
        switch sound {
        case .bell:
            Text(sound.emoji)
                .font(.system(size: 92))
                .phaseAnimator(BellPhase.allCases, trigger: trigger) { content, phase in
                    content
                        .rotationEffect(.degrees(phase.angle), anchor: .bottom)
                        .scaleEffect(phase.scale)
                } animation: { _ in
                    .easeInOut(duration: 0.075)
                }

        case .applause:
            Text(sound.emoji)
                .font(.system(size: 92))
                .phaseAnimator(ClapPhase.allCases, trigger: trigger) { content, phase in
                    content
                        .scaleEffect(x: phase.width, y: phase.height)
                        .rotationEffect(.degrees(phase.angle))
                } animation: { _ in
                    .easeInOut(duration: 0.065)
                }

        case .cheer:
            ZStack {
                Text(sound.emoji)
                    .font(.system(size: 92))
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(phase.angle), anchor: .bottomLeading)
                    } animation: { _ in
                        .easeOut(duration: 0.11)
                    }

                HStack(spacing: 5) {
                    Text("♪")
                    Text("♫")
                }
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .phaseAnimator(NotePhase.allCases, trigger: trigger) { content, phase in
                    content
                        .opacity(phase.opacity)
                        .scaleEffect(phase.scale)
                        .offset(x: phase.x, y: phase.y)
                } animation: { phase in
                    phase == .burst
                        ? .spring(duration: 0.22, bounce: 0.35)
                        : .easeOut(duration: 0.24)
                }
            }
            .frame(width: 150, height: 110)
        }
    }
}

private enum BellPhase: CaseIterable {
    case resting, left, right, rebound, settled

    var angle: Double {
        switch self {
        case .resting, .settled: return 0
        case .left: return -24
        case .right: return 22
        case .rebound: return -12
        }
    }

    var scale: Double {
        self == .resting || self == .settled ? 1 : 1.06
    }
}

private enum ClapPhase: CaseIterable {
    case open, clap, rebound, secondClap, settled

    var width: Double {
        switch self {
        case .open, .settled: return 1
        case .clap, .secondClap: return 0.76
        case .rebound: return 1.12
        }
    }

    var height: Double {
        switch self {
        case .clap, .secondClap: return 1.08
        default: return 1
        }
    }

    var angle: Double {
        switch self {
        case .clap: return -5
        case .rebound: return 5
        case .secondClap: return -3
        default: return 0
        }
    }
}

private enum PulsePhase: CaseIterable {
    case resting, burst, settled

    var scale: Double {
        self == .burst ? 1.13 : 1
    }

    var angle: Double {
        self == .burst ? -7 : 0
    }
}

private enum NotePhase: CaseIterable {
    case hidden, burst, floating

    var opacity: Double {
        switch self {
        case .hidden: return 0
        case .burst: return 1
        case .floating: return 0
        }
    }

    var scale: Double {
        switch self {
        case .hidden: return 0.55
        case .burst: return 1.05
        case .floating: return 1.2
        }
    }

    var x: Double {
        switch self {
        case .hidden: return 40
        case .burst: return 54
        case .floating: return 70
        }
    }

    var y: Double {
        switch self {
        case .hidden: return -8
        case .burst: return -30
        case .floating: return -52
        }
    }
}

#Preview {
    ContentView()
}
