import SwiftUI

struct ContentView: View {
    @StateObject private var session: ShakeCheerSession
    @State private var selectedSound = SoundCatalog.bell
    @State private var selectedCategory: SoundCategory?
    private let categoryLocksEnabled = false

    @MainActor
    init() {
        _session = StateObject(
            wrappedValue: ShakeCheerSession(
                motionEngine: CoreMotionEngine(),
                audioEngine: SoundManager()
            )
        )
    }

    @MainActor
    init(
        motionEngine: any MotionEngine,
        audioEngine: any AudioEngine
    ) {
        _session = StateObject(
            wrappedValue: ShakeCheerSession(
                motionEngine: motionEngine,
                audioEngine: audioEngine
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if session.isRunning {
                    playingView
                        .transition(.opacity.combined(with: .scale(scale: 1.04)))
                } else if let selectedCategory {
                    setupView(for: selectedCategory)
                        .transition(.opacity)
                } else {
                    categorySelectionView
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.25), value: session.isRunning)
            .onDisappear {
                session.stop()
            }
        }
        .tint(.orange)
        .preferredColorScheme(.dark)
    }

    private var categorySelectionView: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: max(24, proxy.size.height * 0.06))

                    VStack(spacing: 8) {
                        Text("SHAKE CHEER")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Text("Choisis ton ambiance")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ForEach(SoundCatalog.selectableCategories) { category in
                            Button {
                                selectCategory(category)
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 42, weight: .semibold))
                                        .foregroundStyle(category == .basic ? Color.white : Color.orange)

                                    Text(category.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(category == .basic ? "GRATUIT" : "PRO · TEST")
                                        .font(.caption2.bold())
                                        .foregroundStyle(category == .basic ? Color.green : Color.orange)
                                }
                                .frame(maxWidth: .infinity, minHeight: 138)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color.white.opacity(0.075))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(
                                                    category == .basic
                                                        ? Color.white.opacity(0.16)
                                                        : Color.orange.opacity(0.28),
                                                    lineWidth: 1
                                                )
                                        }
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(
                                categoryLocksEnabled
                                    && category.accessLevel == .pro
                            )
                        }
                    }

                    Text("Les catégories Pro sont déverrouillées pendant les tests.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 18)
                .frame(minHeight: proxy.size.height)
            }
        }
    }

    private func setupView(for category: SoundCategory) -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Button {
                            selectedCategory = nil
                        } label: {
                            Label("Catégories", systemImage: "chevron.left")
                                .font(.headline)
                        }

                        Spacer()

                        Text(category.title)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        TabView(selection: $selectedSound) {
                            ForEach(SoundCatalog.sounds(in: category)) { sound in
                                VStack(spacing: 16) {
                                    SoundAnimationView(sound: sound, trigger: session.animationTrigger)
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
                            ForEach(SoundCatalog.sounds(in: category)) { sound in
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

                SoundAnimationView(sound: selectedSound, trigger: session.animationTrigger)
                    .scaleEffect(fullScreenIconScale(for: proxy.size) + session.liveIntensity * 0.12)
                    .animation(.easeOut(duration: 0.08), value: session.liveIntensity)
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
                session.stop()
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

    private func selectCategory(_ category: SoundCategory) {
        guard let firstSound = SoundCatalog.sounds(in: category).first else { return }
        selectedCategory = category
        selectedSound = firstSound
    }

    private func beginSession() {
        // The free version can present an ad here before starting motion detection.
        session.start(sound: selectedSound)
    }
}

private struct SoundIcon: View {
    let sound: SoundDefinition
    let size: CGFloat

    @ViewBuilder
    var body: some View {
        switch sound.animation {
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
    let sound: SoundDefinition
    let trigger: Int

    var body: some View {
        switch sound.animation {
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

        case .cheer, .sadTrumpet:
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

        case .boo:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(-phase.angle))
                    } animation: { _ in
                        .easeOut(duration: 0.11)
                    }

                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -52)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.15)
                    }
            }

        case .crowdDisappointment:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(phase.angle))
                    } animation: { _ in
                        .easeOut(duration: 0.11)
                    }

                Image(systemName: "person.3.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -52)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.15)
                    }
            }

        case .crickets:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(y: phase == .burst ? -8 : 0)
                    } animation: { _ in
                        .spring(duration: 0.20, bounce: 0.45)
                    }

                Image(systemName: "waveform")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: 58)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.18)
                    }
            }

        case .levelUp:
            ZStack {
                SoundIcon(sound: sound, size: 104)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(y: phase == .burst ? -10 : 0)
                    } animation: { _ in
                        .spring(duration: 0.20, bounce: 0.4)
                    }

                Image(systemName: "chevron.up.2")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.orange)
                    .offset(y: -58)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.18)
                    }
            }

        case .podium, .victory:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(phase.angle))
                    } animation: { _ in
                        .spring(duration: 0.20, bounce: 0.35)
                    }

                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -56)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.18)
                    }
            }

        case .coin:
            SoundIcon(sound: sound, size: 108)
                .phaseAnimator(CoinPhase.allCases, trigger: trigger) { content, phase in
                    content
                        .rotation3DEffect(
                            .degrees(phase.angle),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .scaleEffect(phase.scale)
                } animation: { _ in
                    .easeInOut(duration: 0.10)
                }

        case .refereeWhistle:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(HornPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(x: phase.offset)
                    } animation: { _ in
                        .easeOut(duration: 0.11)
                    }

                Image(systemName: "wave.3.right")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(x: 62, y: -8)
                    .phaseAnimator(WavePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                            .offset(x: phase.x)
                    } animation: { _ in
                        .easeOut(duration: 0.20)
                    }
            }

        case .laughTrack:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(-phase.angle))
                    } animation: { _ in
                        .spring(duration: 0.18, bounce: 0.5)
                    }

                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -55)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.16)
                    }
            }

        case .crowdHey:
            ZStack {
                SoundIcon(sound: sound, size: 106)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(y: phase == .burst ? -7 : 0)
                    } animation: { _ in
                        .spring(duration: 0.18, bounce: 0.4)
                    }

                Image(systemName: "person.3.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -56)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.16)
                    }
            }

        case .djScratch:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(CoinPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .rotationEffect(.degrees(phase.angle))
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .linear(duration: 0.075)
                    }

                Image(systemName: "waveform")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: 58)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.15)
                    }
            }

        case .champagnePops:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(-phase.angle), anchor: .bottom)
                    } animation: { _ in
                        .spring(duration: 0.16, bounce: 0.45)
                    }

                Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(x: 42, y: -50)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.16)
                    }
            }

        case .partyBlower:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(HornPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(x: phase.offset)
                    } animation: { _ in
                        .easeOut(duration: 0.11)
                    }

                Image(systemName: "wave.3.right")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(x: 62, y: -8)
                    .phaseAnimator(WavePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                            .offset(x: phase.x)
                    } animation: { _ in
                        .easeOut(duration: 0.20)
                    }
            }

        case .failBuzzer:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .rotationEffect(.degrees(phase.angle))
                    } animation: { _ in
                        .easeOut(duration: 0.12)
                    }

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .bold))
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

        case .gameOver:
            ZStack {
                SoundIcon(sound: sound, size: 108)
                    .phaseAnimator(PulsePhase.allCases, trigger: trigger) { content, phase in
                        content
                            .scaleEffect(phase.scale)
                            .offset(y: phase == .burst ? 6 : 0)
                    } animation: { _ in
                        .easeOut(duration: 0.13)
                    }

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.orange)
                    .offset(y: -56)
                    .phaseAnimator(ImpactPhase.allCases, trigger: trigger) { content, phase in
                        content
                            .opacity(phase.opacity)
                            .scaleEffect(phase.scale)
                    } animation: { _ in
                        .easeOut(duration: 0.16)
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

        case .stadiumHorn, .airHorn:
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

private enum CoinPhase: CaseIterable {
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
        switch self {
        case .quarter, .threeQuarter: return 0.90
        case .half: return 1.10
        default: return 1
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
