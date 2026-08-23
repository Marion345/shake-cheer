# Feuille de route ShakeCheer

## Vision

ShakeCheer devient un **soundboard contrôlé par le mouvement** : l’utilisateur choisit une ambiance, démarre une session, puis transforme son iPhone en objet d’encouragement. Certains sons réagissent à chaque secousse; d’autres restent actifs tant que le téléphone bouge.

## État actuel — prototype V0.1

Le prototype fonctionnel comprend :

- une interface SwiftUI sombre, orange et or;
- un carrousel centré avec six sons;
- Cloche, Applaudissements, Encouragement, Tambour, Crécelle et Corne de stade;
- des animations propres à chaque objet;
- un mode de jeu immersif en plein écran;
- un déclenchement Core Motion avec sensibilité moyenne fixe;
- deux comportements audio : impact court et lecture maintenue pendant le mouvement;
- une distribution automatisée avec GitHub Actions, Codemagic et TestFlight.

## Produit commercial

### Version gratuite

- trois sons inclus : Cloche, Applaudissements et Encouragement;
- accès au déclenchement par mouvement;
- publicité interstitielle avant certaines sessions, jamais pendant une session;
- aucune publicité intrusive pendant l’utilisation active;
- invitation claire à déverrouiller Pro.

### ShakeCheer Pro

Achat intégré non consommable donnant accès à :

- toutes les catégories et tous les packs de sons;
- Tambour, Crécelle et Corne de stade;
- sons personnalisés importés par l’utilisateur;
- suppression des publicités;
- futurs sons Pro ajoutés au catalogue.

Le prix et la fréquence des publicités seront validés après les essais TestFlight et avant la soumission commerciale.

## Catalogue Pro

| Catégorie | Sons prévus |
|---|---|
| Sports | Baseball, Softball, Hockey, Football, Soccer, Basketball |
| Party | Cheer, Air horn, Applause, Bell, Drum |
| Gaming | Victory, Fail, Level up, Warning |
| Funny | Boo, Laugh, WTF, Sad trombone |
| Custom | Sons importés par l’utilisateur |

Chaque son doit définir :

- son identifiant stable;
- son nom localisé;
- sa catégorie;
- son fichier audio et son format;
- son icône ou illustration;
- son animation;
- son mode de lecture;
- son statut gratuit ou Pro;
- sa provenance et sa licence commerciale.

## Architecture cible

### Modèle de contenu

Remplacer les conditions dispersées par un catalogue déclaratif :

- `SoundCategory` — Sports, Party, Gaming, Funny et Custom;
- `SoundDefinition` — métadonnées complètes d’un son;
- `PlaybackMode` — impact, soutenu ou personnalisé;
- `AccessLevel` — gratuit ou Pro;
- `SoundCatalog` — source unique des sons intégrés et personnalisés.

### Services

- `MotionEngine` — détection des secousses et du mouvement continu;
- `AudioEngine` — lecture d’impact, lecture soutenue, fondu et arrêt;
- `EntitlementManager` — état Pro avec StoreKit 2;
- `PurchaseManager` — achat et restauration;
- `CustomSoundStore` — import, copie locale, renommage et suppression;
- `AdService` — interface publicitaire isolée du reste de l’application;
- `SoundLicenseRegistry` — documentation de la provenance des fichiers.

Les vues SwiftUI consomment ces modèles et services sans connaître directement les noms de fichiers audio.

## Phases de livraison

### Phase 1 — Stabiliser la V0.1

- valider les six sons et les animations sur plusieurs iPhone;
- régler définitivement le comportement soutenu;
- vérifier les niveaux audio et les interruptions;
- compléter les licences des sons;
- recueillir les commentaires TestFlight.

**Critère de sortie :** aucune coupure inattendue, aucun son manquant et interface stable sur iPhone.

### Phase 2 — Fondations Pro

- créer le catalogue typé et les catégories;
- séparer les moteurs de mouvement et d’audio;
- ajouter les niveaux gratuit/Pro;
- ajouter StoreKit 2 avec achat et restauration;
- ajouter un paywall simple;
- prévoir l’interface publicitaire sans afficher de publicité en développement.

**Critère de sortie :** les trois sons gratuits fonctionnent sans achat; les autres se déverrouillent avec un achat StoreKit de test.

### Phase 3 — Contenu et sons personnalisés

- intégrer les packs Sports, Party, Gaming et Funny;
- créer une navigation par catégorie;
- importer un fichier depuis Files;
- préécouter, renommer et supprimer un son personnalisé;
- choisir impact ou lecture soutenue lorsque possible;
- persister la bibliothèque personnalisée sur l’appareil.

**Critère de sortie :** un utilisateur Pro peut importer un son et l’utiliser par mouvement après relance de l’application.

### Phase 4 — Monétisation et finition commerciale

- intégrer le fournisseur publicitaire retenu;
- afficher une publicité seulement avant une session gratuite;
- finaliser le paywall et les textes App Store;
- ajouter confidentialité, conditions et support;
- préparer captures d’écran, aperçu vidéo et métadonnées;
- tester achats, restauration, mode hors ligne et absence de réseau.

**Critère de sortie :** build App Store complet, licences vérifiées et parcours d’achat validé en sandbox.

### Phase 5 — Lancement et amélioration

- lancement progressif;
- suivi des plantages et retours;
- mesure respectueuse de la vie privée des catégories utilisées;
- ajustement des sons, animations, prix et fréquence publicitaire;
- ajout périodique de packs.

## Principes produit

- Le son doit commencer rapidement après le mouvement.
- Aucune publicité ne doit interrompre une session.
- L’application doit fonctionner hors ligne après installation et achat.
- Les sons commerciaux doivent avoir une licence vérifiable.
- Les sons personnalisés restent locaux sauf consentement explicite futur.
- Les réglages techniques restent cachés tant que les valeurs par défaut fonctionnent.
- L’expérience gratuite doit être utile, pas artificiellement inutilisable.

## Suivi GitHub

- [#23 — Stabiliser la V0.1 sur appareils TestFlight](https://github.com/Marion345/shake-cheer/issues/23)
- [#21 — Créer le catalogue de sons et les catégories Pro](https://github.com/Marion345/shake-cheer/issues/21)
- [#20 — Séparer MotionEngine et AudioEngine](https://github.com/Marion345/shake-cheer/issues/20)
- [#26 — Ajouter StoreKit 2 et le déverrouillage Pro](https://github.com/Marion345/shake-cheer/issues/26)
- [#19 — Créer la navigation par catégories](https://github.com/Marion345/shake-cheer/issues/19)
- [#22 — Importer et gérer des sons personnalisés](https://github.com/Marion345/shake-cheer/issues/22)
- [#24 — Intégrer la publicité avant les sessions gratuites](https://github.com/Marion345/shake-cheer/issues/24)
- [#25 — Vérifier les licences audio et préparer l’App Store](https://github.com/Marion345/shake-cheer/issues/25)

## Définition de terminé

Une fonctionnalité est terminée lorsqu’elle :

- compile dans GitHub Actions;
- est vérifiée sur un iPhone réel via TestFlight;
- gère les erreurs et l’absence de fichier;
- possède les textes d’accessibilité nécessaires;
- respecte l’accès gratuit ou Pro;
- documente toute nouvelle source audio.
