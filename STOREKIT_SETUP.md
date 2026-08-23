# Configuration de ShakeCheer Pro dans App Store Connect

L’application utilise StoreKit 2 avec un achat intégré non consommable.

## Produit à créer

- Type : **Non-Consumable**
- Reference Name : **ShakeCheer Pro**
- Product ID : `com.marion345.shakecheer.pro`
- Prix : à choisir dans App Store Connect
- Nom français suggéré : **ShakeCheer Pro**
- Description française suggérée : **Déverrouille les catégories Sports, Party, Gaming et Funny, tous les sons Pro et retire les publicités.**

Le Product ID doit être copié exactement. Il est défini dans `PurchaseManager.proProductID`.

## Étapes Apple

1. Vérifier que les contrats d’applications payantes, les renseignements bancaires et fiscaux sont actifs.
2. Ouvrir la fiche ShakeCheer dans App Store Connect.
3. Créer l’achat intégré non consommable avec le Product ID ci-dessus.
4. Ajouter le prix, les localisations et la capture demandée pour la révision.
5. Rendre le produit disponible dans les territoires voulus.
6. Associer l’achat intégré à la version de l’application qui sera soumise.
7. Tester l’achat et **Restaurer mes achats** avec un compte Sandbox ou TestFlight avant la publication.

## Comportement dans l’application

- **De base** demeure gratuit : Cloche, Applaudissements et Crécelle.
- **Sports, Party, Gaming et Funny** ouvrent le paywall sans droit Pro actif.
- Un achat vérifié déverrouille immédiatement toutes les catégories Pro.
- Le droit est relu au démarrage et après chaque mise à jour de transaction.
- La restauration utilise `AppStore.sync()`.
- Si Apple ne retourne pas encore le produit, le paywall explique que la configuration App Store Connect est incomplète.

## Vérifications avant publication

- achat réussi;
- achat annulé;
- achat en attente;
- restauration sur un second appareil;
- remboursement ou révocation;
- démarrage hors ligne après un achat déjà reconnu;
- prix et textes localisés;
- captures et licences commerciales des sons.
