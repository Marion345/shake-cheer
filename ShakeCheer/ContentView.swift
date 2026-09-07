import SwiftUI

struct ContentView: View {
    @StateObject private var session: ShakeCheerSession
    @StateObject private var purchaseManager: PurchaseManager
    @State private var selectedSound = SoundCatalog.bell
    @State private var selectedCategory: SoundCategory?
    @State private var showingPaywall = false

    @MainActor
    init() {
        _purchaseManager = StateObject(wrappedValue: PurchaseManager())
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
        _purchaseManager = StateObject(wrappedValue: PurchaseManager())
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
        .sheet(isPresented: $showingPaywall) {
            ProPaywallView(purchaseManager: purchaseManager)
        }
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
                                handleCategoryTap(category)
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 42, weight: .semibold))
                                        .foregroundStyle(category == .basic ? Color.white : Color.orange)

                                    Text(category.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    HStack(spacing: 5) {
                                        if isCategoryLocked(category) {
                                            Image(systemName: "lock.fill")
                                        }

                                        Text(
                                            category == .basic
                                                ? "GRATUIT"
                                                : purchaseManager.isPro ? "PRO ACTIF" : "PRO"
                                        )
                                    }
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
                        }
                    }

                    Text(proAccessMessage)
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
                                    SoundIcon(sound: sound, size: 108)
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

                SoundIcon(sound: selectedSound, size: 108)
                    .scaleEffect(fullScreenIconScale(for: proxy.size))
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

    private func handleCategoryTap(_ category: SoundCategory) {
        if isCategoryLocked(category) {
            showingPaywall = true
        } else {
            selectCategory(category)
        }
    }

    private func isCategoryLocked(_ category: SoundCategory) -> Bool {
        category.accessLevel == .pro && !purchaseManager.isPro
    }

    private var proAccessMessage: String {
        return purchaseManager.isPro
            ? "ShakeCheer Pro est actif sur ce compte Apple."
            : "Déverrouille les catégories Pro avec un achat unique."
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

    var body: some View {
        Image(sound.visualAssetName)
            .resizable()
            .scaledToFill()
            .frame(width: size * 1.72, height: size * 1.15)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.13, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}

#Preview {
    ContentView()
}
