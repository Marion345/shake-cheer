# ShakeCheer — pages de support et de confidentialité

Deux pages statiques en français canadien, sans JavaScript, formulaire, police distante ni outil de suivi ajouté par ShakeCheer.

- `dist/index.html` : aide et contact public `yanick.marion@hotmail.com`.
- `dist/confidentialite.html` : politique de la version actuelle, achats Apple, mouvements locaux, support et hébergement.
- `dist/styles.css` : thème noir/orange, navigation clavier et mise en page responsive.
- `.openai/hosting.json` : identité conservée de l’ancien hébergement Sites; elle n’est pas publiée par GitHub Pages.
- `../.github/workflows/website-pages.yml` : vérification et publication sur GitHub Pages.

Les sources sont versionnées dans le dossier `website/` du dépôt public `Marion345/shake-cheer`. GitHub Pages est l’hébergement retenu pour disposer d’adresses gratuites sans « chatgpt ». Les liens internes sont relatifs et fonctionnent sous le préfixe `/shake-cheer/`.

## Activer la publication GitHub Pages

Une personne ayant les droits d’administration du dépôt doit effectuer ce réglage une fois :

1. Ouvrir [Settings → Pages](https://github.com/Marion345/shake-cheer/settings/pages).
2. Dans **Build and deployment → Source**, sélectionner **GitHub Actions**.
3. Dans **Actions → Deploy ShakeCheer website**, cliquer **Run workflow**, choisir `main` et lancer. Si une première exécution a échoué avant l’activation de Pages, lancer une nouvelle exécution après ce réglage.
4. Attendre la réussite de **Publish to GitHub Pages**, puis vérifier les deux pages publiques avant de remplacer les adresses dans App Store Connect.

Adresses attendues après la première publication réussie :

- Support : https://marion345.github.io/shake-cheer/
- Confidentialité : https://marion345.github.io/shake-cheer/confidentialite.html

Après activation, chaque modification de `website/` fusionnée dans `main` déclenche la vérification et la publication. Les pull requests exécutent seulement la vérification. Le déploiement publie uniquement `website/dist`; aucun fichier Swift, document interne ou réglage Sites n’est inclus. Aucun secret supplémentaire ni compilation iOS n’est nécessaire pour publier ces pages.

L’ancienne publication Sites reste disponible pendant la transition et n’est pas mise à jour par ce workflow. Ne pas y publier cette version de la politique, qui décrit GitHub Pages. Ne retirer les anciennes adresses d’App Store Connect qu’après vérification des nouvelles.

## Vérification

Depuis ce dossier : `python3 check_site.py`.

Cette vérification contrôle les pages HTML, leurs liens et ancres internes, les références de styles, le contact public, les métadonnées, l’absence de scripts et de ressources externes incorporées et les contrastes des couleurs principales. Elle ne remplace pas une compilation iOS, un test visuel dans un navigateur ou une validation juridique.

## Fondement de la politique

Code examiné au commit `35f38854900e2bd53213fa929dda36a29b73fd7e` de ShakeCheer :

- `ShakeDetector.swift` et `ShakeCheerSession.swift` : traitement en mémoire des mouvements, sans export de mesures.
- `SoundManager.swift` : fichiers audio locaux via `AVAudioPlayer`, session de lecture, pas d’enregistrement microphone.
- `PurchaseManager.swift` : StoreKit 2, droits Pro vérifiés, pas de serveur applicatif propre.
- `ContentView.swift`, `ProPaywallView.swift` et `ShakeCheerApp.swift` : pas de compte propre ni d’outil publicitaire ou d’analyse tiers.
- `SoundCatalog.swift`, `project.yml` et l’arborescence : catalogue local, iPhone/iOS 17, pas de dépendance publicitaire déclarée.

Les affirmations concernant le code s’appliquent à cette version. La politique distingue ces traitements des courriels de support et des traitements des prestataires Apple, Microsoft et GitHub.

## Avant la soumission App Store

- Valider les engagements de traitement des courriels avec le responsable et adapter la politique à toute pratique réelle différente.
- Rendre le site public, accessible sans compte, puis renseigner l’URL de support et l’URL de confidentialité dans App Store Connect.
- Ajouter un lien accessible vers la politique dans l’application : les pages web ne changent pas à elles seules le binaire iOS.
- Vérifier les déclarations App Privacy selon l’ensemble des traitements et SDK réellement livrés. Ne pas assimiler l’absence de suivi ajouté au site à l’absence de journaux techniques de l’hébergeur.
- Tester l’achat Pro et sa restauration et vérifier les licences commerciales des fichiers audio.

## Avant d’activer les publicités gratuites

La publicité est prévue, mais aucun SDK publicitaire n’est actuellement intégré. Ne pas présenter cette politique comme couvrant un réseau publicitaire non encore choisi.

1. Choisir le prestataire et examiner ses données, identifiants, finalités, destinataires, durées de conservation et options de consentement.
2. Mettre à jour la politique AVANT la livraison de cette version, ainsi que les réponses App Privacy et les métadonnées/manifestes requis.
3. Mettre en place les choix et consentements requis; ATT est nécessaire en cas de suivi au sens d’Apple, pas automatiquement pour toute publicité.
4. Vérifier l’absence de publicité pour les achats Pro reconnus et la possibilité d’utiliser les sons gratuits sans autoriser un suivi facultatif.

Références :

- https://developer.apple.com/app-store/review/guidelines/#privacy
- https://developer.apple.com/app-store/app-privacy-details/
- https://developer.apple.com/app-store/user-privacy-and-data-use/
- https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages#data-collection
- https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement
