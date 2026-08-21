import SwiftUI

struct ContentView: View {
    @StateObject private var detector = ShakeDetector()
    @StateObject private var soundManager = SoundManager()
    @State private var selectedSound: CheerSound = .bell
    @State private var animationTrigger = 0

    private let soundColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    SoundAnimationView(sound: selectedSound, trigger: animationTrigger)
                        .scaleEffect(1.0 + detector.liveIntensity * 0.08)
                        .animation(.easeOut(duration: 0.08), value: detector.liveIntensity)
                        .frame(height: 112)

                    VStack(spacing: 6) {
                        Text("SHAKE CHEER")
                            .font(.largeTitle.bold())
                        Text(detector.isRunning ? "Secoue ton iPhone!" : "Choisis un son et appuie sur Start")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    LazyVGrid(columns: soundColumns, spacing: 10) {
                        ForEach(CheerSound.allCases) { sound in
                            Button {
                                selectedSound = sound
                            } label: {
                                VStack(spacing: 5) {
                                    SoundIcon(sound: sound, size: 34)
                                    Text(sound.title)
                                        .font(.caption2.weight(.semibold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.65)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 68)
                                .foregroundStyle(selectedSound == sound ? .white : .primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedSound == sound ? Color.accentColor : Color.secondary.opacity(0.12))
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(sound.title)
                            .accessibilityAddTraits(selectedSound == sound ? .isSelected : [])
                        }
                    }

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

                    VStack(spacing: 6) {
                        Text("Shakes")
                            .foregroundStyle(.secondary)
                        Text("\(detector.shakeCount)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
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
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    if !detector.isRunning {
                        Text("Version B · plus le mouvement est fort, plus les sons peuvent se déclencher rapidement.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
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

private struct SoundIcon: View {
    let sound: CheerSound
    let size: CGFloat

    @ViewBuilder
    var body: some View {
        switch sound {
        case .bell:
            Image("HandBell")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        case .applause:
            Image("ApplauseHands")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        case .noisemaker:
            Image("Noisemaker")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.02, height: size * 0.78)
        case .stadiumHorn:
            Image("StadiumHorn")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        default:
            Text(sound.emoji)
                .font(.system(size: size))
        }
    }
}

private struct SoundAnimationView: View {
    let sound: CheerSound
    let trigger: Int

    var body: some View {
        switch sound {
        case .bell:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(BellPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .rotationEffect(.degrees(phase.angle), anchor: .bottom)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeInOut(duration: 0.075)
                    }

                HStack(spacing: 94) {
                    Image(systemName: "wave.3.left")
                    Image(systemName: "wave.3.right")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.orange)
                .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                    content
                        .opacity(phase.opacity)
                        .scaleEffect(phase.scale)
                } animation: { _ in
                    .easeOut(duration: 0.16)
                }
            }

        case .applause:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(ClapPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(x: phase.width, y: phase.height)
                            .rotationEffect(.degrees(phase.angle))
                    } animation: { _ in
                        .easeInOut(duration: 0.065)
                    }

                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -43)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.15)
                    }
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

        case .noisemaker:
            SoundIcon(sound: sound, size: 112)
                .phaseAnimator(RattlePhase.allCases, trigger: trigger) { content, phase in
                    content
                        .rotationEffect(.degrees(phase.angle))
                        .scaleEffect(phase.scale)
                } animation: { _ in
                    .linear(duration: 0.075)
                }

        case .stadiumHorn:
            ZStack {
                SoundIcon(sound: sound, size: 112)
                    .phaseAnimator(HornPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(x: phase.offset)
                    } animation: { _ in
                        .easeOut(duration: 0.12)
                    }

                Image(systemName: "wave.3.right")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.blue)
                    .phaseAnimator(WavePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                            .offset(x: phase.x)
                    } animation: { phase in
                        phase == .burst
                            ? .spring(duration: 0.2, bounce: 0.25)
                            : .easeOut(duration: 0.28)
                    }
                    .offset(x: 66, y: -7)
            }
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

    var scale: Double { self == .resting || self == .settled ? 1 : 1.06 }
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

private enum ImpactPhase: CaseIterable {
    case hidden, impact, fading

    var opacity: Double { self == .impact ? 1 : 0 }

    var scale: Double {
        switch self {
        case .hidden: return 0.55
        case .impact: return 1
        case .fading: return 1.35
        }
    }
}

private enum PulsePhase: CaseIterable {
    case resting, burst, settled

    var scale: Double { self == .burst ? 1.13 : 1 }
    var angle: Double { self == .burst ? -7 : 0 }
}

private enum NotePhase: CaseIterable {
    case hidden, burst, floating

    var opacity: Double { self == .burst ? 1 : 0 }

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

private enum RattlePhase: CaseIterable {
    case resting, quarter, half, threeQuarter, fullTurn

    var angle: Double {
        switch self {
        case .resting: return 0
        case .quarter: return 90
        case .half: return 180
        case .threeQuarter: return 270
        case .fullTurn: return 360
        }
    }

    var scale: Double {
        self == .resting || self == .fullTurn ? 1 : 1.08
    }
}

private enum HornPhase: CaseIterable {
    case resting, blast, rebound, settled

    var scale: Double {
        switch self {
        case .blast: return 1.14
        case .rebound: return 0.97
        default: return 1
        }
    }

    var offset: Double { self == .blast ? 7 : 0 }
}

private enum WavePhase: CaseIterable {
    case hidden, burst, expanding

    var opacity: Double { self == .burst ? 1 : 0 }

    var scale: Double {
        switch self {
        case .hidden: return 0.55
        case .burst: return 1
        case .expanding: return 1.35
        }
    }

    var x: Double {
        switch self {
        case .hidden: return -8
        case .burst: return 3
        case .expanding: return 20
        }
    }
}

#Preview {
    ContentView()
}
