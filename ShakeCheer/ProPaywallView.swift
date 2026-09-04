import SwiftUI

struct ProPaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.16))
                            .frame(width: 132, height: 132)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 18)

                    VStack(spacing: 8) {
                        Text("SHAKECHEER PRO")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("Déverrouille toute l’ambiance.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        ProBenefitRow(
                            icon: "sportscourt.fill",
                            title: "Toutes les catégories",
                            detail: "Sports, Party, Gaming et Funny"
                        )
                        ProBenefitRow(
                            icon: "waveform",
                            title: "20 sons Pro",
                            detail: "Des effets conçus pour chaque occasion"
                        )
                        ProBenefitRow(
                            icon: "nosign",
                            title: "Sans publicité",
                            detail: "Démarre immédiatement et encourage ton équipe"
                        )
                        ProBenefitRow(
                            icon: "arrow.down.circle.fill",
                            title: "Achat unique",
                            detail: "Pas d’abonnement"
                        )
                    }
                    .padding(.vertical, 4)

                    Button {
                        Task {
                            await purchaseManager.purchasePro()
                        }
                    } label: {
                        Group {
                            if purchaseManager.isPurchasing {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("DÉBLOQUER · \(purchaseManager.displayPrice)")
                                    .font(.headline.bold())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(
                        purchaseManager.isPurchasing
                            || purchaseManager.isLoadingProduct
                            || purchaseManager.product == nil
                    )

                    Button("Restaurer mes achats") {
                        Task {
                            await purchaseManager.restorePurchases()
                        }
                    }
                    .font(.headline)
                    .disabled(purchaseManager.isPurchasing)

                    if let message = purchaseManager.message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Text("Le paiement est traité par Apple. ShakeCheer Pro est un achat non consommable associé à ton compte Apple.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("ShakeCheer Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onChange(of: purchaseManager.isPro) { _, isPro in
                if isPro {
                    dismiss()
                }
            }
        }
        .tint(.orange)
        .preferredColorScheme(.dark)
    }
}

private struct ProBenefitRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.075))
        )
    }
}
