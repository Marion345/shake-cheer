import SwiftUI

struct ContentView: View {
    @StateObject private var detector = ShakeDetector()
    @StateObject private var soundManager = SoundManager()
    @State private var selectedSound: CheerSound = .bell
    @State private var animationTrigger = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if detector.isRunning {
                    playingView
                        .transition(.opacity.combined(with: .scale(scale: 1.04)))
                } else {
                    setupView
                        .transition(.opacity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.25), value: detector.isRunning)
            .onAppear {
                detector.onShake = { intensity in
                    animationTrigger += 1
                    soundManager.play(selectedSound, intensity: intensity)
                }
                detector.onMotion = {
                    soundManager.keepAlive(selectedSound)
                }
            }
            .onDisappear {
                detector.stop()
                soundManager.stopAll()
            }
        }
        .tint(.orange)
        .preferredColorScheme(.dark)
    }

    private var setupView: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                    Spacer(minLength: 8)

                    VStack(spacing: 12) {
                        TabView(selection: $selectedSound) {
                            ForEach(CheerSound.allCases) { sound in
                                VStack(spacing: 16) {
                                    SoundAnimationView(sound: sound, trigger: animationTrigger)
                                        .scaleEffect(setupIconScale(for: proxy.size))
                                        .frame(height: max(245, min(proxy.size.height * 0.34, 330)))

                                    Text(sound.title)
                                        .font(.title.bold())
                                        .foregroundStyle(.white)
                                }
                                .tag(sound)
                                .accessibilityLabel(sound.title)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: max(330, min(proxy.size.height * 0.47, 420)))

                        HStack(spacing: 8) {
                            ForEach(CheerSound.allCases) { sound in
                                Capsule()
                                    .fill(selectedSound == sound ? Color.orange : Color.white.opacity(0.28))
                                    .frame(width: selectedSound == sound ? 22 : 8, height: 8)
                                    .animation(.easeInOut(duration: 0.2), value: selectedSound)
                            }
                        }

                        Label("Glisse pour changer de son", systemImage: "arrow.left.and.right")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 18)

                    VStack(spacing: 6) {
                        Text("SHAKE CHEER")
                            .font(.largeTitle.bold())
                        Text("Choisis un son, puis commence")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        beginSession()
                    } label: {
                        Text("START")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("Version B · plus le mouvement est fort, plus les sons peuvent se déclencher rapidement.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
                .frame(minHeight: proxy.size.height)
            }
        }
    }

    private var playingView: some View {
        GeometryReader { proxy in
            VStack(spacing: 28) {
                Spacer()

                SoundAnimationView(sound: selectedSound, trigger: animationTrigger)
                    .scaleEffect(fullScreenIconScale(for: proxy.size) + detector.liveIntensity * 0.12)
                    .animation(.easeOut(duration: 0.08), value: detector.liveIntensity)
                    .frame(maxWidth: .infinity, minHeight: 320)

                Text(selectedSound.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Touchez l’écran pour arrêter")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                detector.stop()
                soundManager.stopAll()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(selectedSound.title). Touchez pour arrêter.")
            .accessibilityAddTraits(.isButton)
        }
    }

    private func setupIconScale(for size: CGSize) -> Double {
        min(max(Double(size.width / 245), 1.4), 1.75)
    }

    private func fullScreenIconScale(for size: CGSize) -> Double {
        min(max(Double(size.width / 190), 1.65), 2.45)
    }

    private func beginSession() {
        // The free version can present an ad here before starting motion detection.
        detector.start()
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
                .frame(width: size * 1.08, height: size * 1.08)
        case .applause:
            Image("ApplauseHands")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.08, height: size * 1.08)
        case .noisemaker:
            Image("Noisemaker")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.25, height: size * 1.25)
        case .stadiumHorn:
            Image("StadiumHorn")
                .resizable()
                .scaledToFit()
                .frame(width: size * 1.15, height: size * 1.15)
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
                .foregroundStyle(.orange)
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

        case .drum:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(DrumPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(phase.angle))
                    } animation: { _ in
                        .easeOut(duration: 0.09)
                    }

                Image(systemName: "burst.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -56)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.15)
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
                    .foregroundStyle(.orange)
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

private enum DrumPhase: CaseIterable {
    case resting, hit, rebound, secondHit, settled

    var scale: Double {
        switch self {
        case .hit, .secondHit: return 0.88
        case .rebound: return 1.12
        default: return 1
        }
    }

    var angle: Double {
        switch self {
        case .hit: return -6
        case .rebound: return 5
        case .secondHit: return -3
        default: return 0
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
