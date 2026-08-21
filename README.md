# ShakeCheer

Prototype iOS V0.1 : secouer l'iPhone déclenche des sons d'encouragement.

## V0.1
- SwiftUI
- Core Motion / détection continue
- Version B : la fréquence de déclenchement augmente avec l'intensité du mouvement
- 3 sons prototype : Bell, Applause, Cheer
- Sensibilité réglable
- Compteur de shakes
- Start / Stop

## Générer le projet Xcode
Ce repo utilise [XcodeGen](https://github.com/yonaskolb/XcodeGen) pour éviter de versionner un projet Xcode généré à la main.

Sur un Mac :
```bash
brew install xcodegen
xcodegen generate
open ShakeCheer.xcodeproj
```

Puis sélectionner un iPhone réel dans Xcode et lancer l'app. Les capteurs Core Motion doivent être testés sur un appareil réel.

## Sons
Les fichiers WAV inclus sont des sons synthétiques de prototype générés pour le projet. Ils sont destinés aux tests fonctionnels; ils pourront être remplacés par des sons de meilleure qualité/licenciés avant publication.
