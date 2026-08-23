# ShakeCheer

ShakeCheer est un **soundboard iPhone contrôlé par le mouvement**. L’utilisateur choisit un son, démarre une session, puis secoue son téléphone pour encourager une équipe, animer une fête ou déclencher un effet sonore.

## Prototype actuel

La V0.1 fonctionnelle comprend :

- SwiftUI et Core Motion;
- vingt-trois sons répartis entre De base, Sports, Party, Gaming et Funny;
- un écran de choix de catégorie avec verrouillage gratuit/Pro;
- un achat unique ShakeCheer Pro géré avec StoreKit 2;
- une restauration des achats Apple;
- un carrousel de sélection filtré avec animations;
- un mode immersif en plein écran;
- des sons courts déclenchés par secousse;
- des sons soutenus maintenus pendant le mouvement;
- une sensibilité moyenne optimisée;
- une distribution GitHub Actions, Codemagic et TestFlight.

## Vision commerciale

La version gratuite proposera trois sons et pourra afficher une publicité avant le démarrage d’une session. ShakeCheer Pro déverrouillera toutes les catégories, les packs de sons, les sons personnalisés et supprimera les publicités.

Catégories prévues :

- Sports;
- Party;
- Gaming;
- Funny;
- Custom sounds.

Consulter la [feuille de route complète](ROADMAP.md) pour l’offre gratuite/Pro, l’architecture cible et les phases de livraison. La configuration de l’achat intégré est détaillée dans [STOREKIT_SETUP.md](STOREKIT_SETUP.md).

## Générer le projet Xcode

Ce dépôt utilise [XcodeGen](https://github.com/yonaskolb/XcodeGen) afin d’éviter de versionner un projet Xcode généré à la main.

Sur un Mac :

```bash
brew install xcodegen
xcodegen generate
open ShakeCheer.xcodeproj
```

Sélectionner ensuite un iPhone réel dans Xcode et lancer l’application. Les capteurs Core Motion doivent être vérifiés sur un appareil physique.

## Audio et licences

Les fichiers audio utilisés par l’application se trouvent dans `Resources`. Toute nouvelle piste destinée à la distribution commerciale doit avoir une provenance et une licence documentées dans `Resources/AUDIO_SOURCES.md`.
