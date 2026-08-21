import SwiftUI

struct ContentView: View {
    @StateObject private var detector = ShakeDetector()
    @StateObject private var soundManager = SoundManager()
    @State private var selectedSound: CheerSound = .bell

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer(minLength: 12)

                Text(selectedSound.emoji)
                    .font(.system(size: 92))
                    .scaleEffect(1.0 + detector.liveIntensity * 0.12)
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

#Preview {
    ContentView()
}
