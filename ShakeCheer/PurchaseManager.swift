import Combine
import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "com.marion345.shakecheer.pro"
    // Temporary TestFlight switch. Set this to false before App Store review.
    static let temporaryProTestingUnlockEnabled = true

    @Published private(set) var isPro = temporaryProTestingUnlockEnabled
    @Published private(set) var product: Product?
    @Published private(set) var isLoadingProduct = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var message: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }

        Task { [weak self] in
            guard let self else { return }
            await self.loadProduct()
            await self.refreshEntitlements()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var displayPrice: String {
        product?.displayPrice ?? "Prix à venir"
    }

    var isUsingTemporaryProTestingUnlock: Bool {
        Self.temporaryProTestingUnlockEnabled
    }

    func loadProduct() async {
        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            product = try await Product.products(
                for: [Self.proProductID]
            ).first

            if product == nil {
                message = "ShakeCheer Pro doit encore être configuré dans App Store Connect."
            } else {
                message = nil
            }
        } catch {
            message = "Impossible de charger ShakeCheer Pro. Réessaie plus tard."
        }
    }

    func purchasePro() async {
        if product == nil {
            await loadProduct()
        }

        guard let product else {
            message = "ShakeCheer Pro n’est pas encore disponible."
            return
        }

        isPurchasing = true
        message = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    message = "Apple n’a pas pu vérifier cet achat."
                    return
                }

                await transaction.finish()
                await refreshEntitlements()

            case .pending:
                message = "L’achat attend l’autorisation d’Apple."

            case .userCancelled:
                break

            @unknown default:
                message = "Le résultat de l’achat est inconnu."
            }
        } catch {
            message = "L’achat n’a pas pu être complété."
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        message = nil
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            if !isPro {
                message = "Aucun achat ShakeCheer Pro n’a été trouvé."
            }
        } catch {
            message = "La restauration des achats a échoué."
        }
    }

    func refreshEntitlements() async {
        var hasActiveProPurchase = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.productID == Self.proProductID,
               transaction.revocationDate == nil,
               !transaction.isUpgraded {
                hasActiveProPurchase = true
                break
            }
        }

        isPro = Self.temporaryProTestingUnlockEnabled || hasActiveProPurchase
    }
}
