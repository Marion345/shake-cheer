# Sources audio de ShakeCheer

Vérification effectuée le 4 septembre 2026. Les liens ci-dessous pointent vers les fiches de téléchargement et de licence des enregistrements utilisés.

## Sons de base

| Fichier | Enregistrement | Auteur | Licence et traitement |
|---|---|---|---|
| `bell.wav` | [La cloche sonne](https://sounddino.com/fr/effects/bells/), fichier `bell-ringing.mp3` | SoundDino | La page indique un usage commercial et personnel gratuit, sans attribution. Extrait, normalisé, fondu et converti en WAV PCM. |
| `applause.wav` | [Applause #1, nº 2363](https://bigsoundbank.com/applause-1-s2363.html) | Dorian CLAIR | CC0. Extrait de 1,80 à 3,78 secondes, normalisé à −1 dBFS, fondu et converti en WAV PCM 16 bits, 44,1 kHz, stéréo. |
| `noisemaker.wav` | [Rapid rattle, nº 0316](https://bigsoundbank.com/rapid-rattle-s0316.html) | DavidGreck | CC0. Extrait, normalisé, fondu et converti en WAV PCM 16 bits, 44,1 kHz, stéréo. |

## Sons Pro — sources CC0

Les pistes suivantes restent basées sur des enregistrements BigSoundBank / LaSonothèque dont les fiches affichent explicitement **CC0 (domaine public)** et autorisent la modification, la redistribution et l’utilisation commerciale dans des applications.

| Fichier dans l’app | Enregistrement CC0 | Auteur | Préparation |
|---|---|---|---|
| `cheer-crowd.mp3` | [Shouts and Applauses of Teens #2, nº 0237](https://bigsoundbank.com/shouts-and-applauses-of-teens-2-s0237.html) | DenisChardonnet | Extrait de 4,50 s |
| `drum-crowd.mp3` | [Drum Roll 1 L, nº 2402](https://bigsoundbank.com/drum-roll-1-l-s2402.html) | Joseph SARDIN | Extrait de 4,45 s |
| `cargo-ship-horn.mp3` | [Ocean Liner Horn #1, nº 0261](https://bigsoundbank.com/horn-of-a-ship-1-s0261.html) | DenisChardonnet | Extrait de 8,40 s |
| `referee-whistle.mp3` | [Plastic Whistle #1, nº 1017](https://bigsoundbank.com/plastic-whistle-s1017.html) | Joseph SARDIN | Extrait de 2,50 s |
| `crowd-hey.mp3` | [Shouts and Applauses of Teens #1, nº 0236](https://bigsoundbank.com/shouts-and-applauses-of-teens-1-s0236.html) | DenisChardonnet | Extrait de 3,55 s |
| `dj-scratch.mp3` | [Vinyl Scratch #1, nº 2858](https://bigsoundbank.com/vinyl-scratch-1-s2858.html) | Joseph SARDIN | Extrait de 1,30 s |
| `champagne-pops.mp3` | [Champagne Cork #1, nº 0211](https://bigsoundbank.com/champagne-cork-s0211.html) | Joseph SARDIN | Trois copies espacées du bouchon, durée 2,15 s |
| `party-blower.mp3` | [Party Horn #1, nº 1553](https://bigsoundbank.com/party-horn-1-s1553.html) | Joseph SARDIN | Quatre copies espacées, durée 4,85 s |
| `coin.mp3` | [Coins #1, nº 0193](https://bigsoundbank.com/coins-1-s0193.html) | Joseph SARDIN | Extrait de 2,50 s |
| `fail-buzzer.mp3` | [Buzzer #1, nº 1583](https://bigsoundbank.com/buzzer-1-s1583.html) | Joseph SARDIN | Extrait de 0,33 s |
| `boo.mp3` | [Howling Two Children #1, nº 1661](https://bigsoundbank.com/howling-two-children-s1661.html) | Joseph SARDIN | Extrait de 2,40 s |
| `boo-crowd.mp3` | [Sigh by the Mouth, nº 1405](https://bigsoundbank.com/sigh-by-the-mouth-s1405.html) | Joseph SARDIN | Extrait de 4,10 s |
| `crickets.mp3` | [Field Cricket, nº 1020](https://bigsoundbank.com/field-cricket-s1020.html) | Joseph SARDIN | Extrait de 9,50 s |
| `laugh-track.mp3` | [Laughter, nº 0490](https://bigsoundbank.com/laughter-s0490.html) | Joseph SARDIN | Extrait de 7,80 s |

## Sons Pro — effets originaux ShakeCheer

Pour rapprocher certains effets de l'identité sonore de la première version sans réutiliser les enregistrements Pixabay, six pistes sont maintenant **créées par le projet lui-même** pendant le build, via `scripts/generate_familiar_audio.py`.

| Fichier généré | Conception |
|---|---|
| `air-horn.mp3` | Klaxon de stade synthétique court, riche en harmoniques, conçu pour remplacer la corne de brume qui s'éloignait trop de l'ancien Air Horn. |
| `level-up.mp3` | Arpège arcade ascendant original. |
| `victory.mp3` | Fanfare de victoire originale avec accent de cymbale synthétique. |
| `podium.mp3` | Roulement synthétique suivi d'une courte fanfare de remise de prix. |
| `sad-trumpet.mp3` | Motif descendant « wah-wah » original, répété pour conserver le mode de lecture soutenu. |
| `game-over.mp3` | Voix système macOS générée au build disant « Game over », ralentie et filtrée pour retrouver une voix masculine grave. Aucun enregistrement vocal tiers n'est inclus dans le dépôt. |

Le script produit les pistes en MP3 mono, 44,1 kHz, 96 kbit/s. Les formes d'onde musicales et synthétiques sont calculées à partir de sinusoïdes, dents de scie, enveloppes et bruit pseudo-aléatoire déterministe. Elles ne copient aucun fichier audio tiers.

## Traitement et historique

Les noms de fichiers attendus par `SoundCatalog.swift` sont conservés. Les anciens fichiers provenant de Pixabay ont été retirés de l'arbre courant et de l'historique Git lors de la reconstruction propre du 4 septembre 2026.
