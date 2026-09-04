# Sources audio de ShakeCheer

Vérification effectuée le 4 septembre 2026. Les liens ci-dessous pointent vers les fiches des enregistrements utilisés par l’app. Les 16 sons sélectionnés manuellement sont récupérés depuis leur source publique puis coupés, normalisés et encodés automatiquement par `scripts/install_user_audio.py` avant XcodeGen.

## Sons de base

| Fichier | Enregistrement | Auteur | Licence et traitement |
|---|---|---|---|
| `bell.wav` | [La cloche sonne](https://sounddino.com/fr/effects/bells/), fichier `bell-ringing.mp3` | SoundDino | La page indique un usage commercial et personnel gratuit, sans attribution. Extrait, normalisé, fondu et converti en WAV PCM. |
| `applause.wav` | [Applause #1, nº 2363](https://bigsoundbank.com/applause-1-s2363.html) | Dorian CLAIR | CC0. Extrait et converti en WAV PCM. |
| `noisemaker.wav` | [Rapid rattle, nº 0316](https://bigsoundbank.com/rapid-rattle-s0316.html) | DavidGreck | CC0. Extrait et converti en WAV PCM. |

## Sons Pro sélectionnés manuellement

| Fichier dans l’app | Source | Auteur | Licence |
|---|---|---|---|
| `cheer-crowd.mp3` | [Freesound 829455](https://freesound.org/s/829455/) | itmightgetloud | CC0 |
| `drum-crowd.mp3` | [Freesound 500250 — Soccer fans screaming and playing drums in a small stadium of Chile](https://freesound.org/s/500250/) | felix.blume | CC0 |
| `referee-whistle.mp3` | [BigSoundBank 1105 — Whistle, plastic #2](https://bigsoundbank.com/whistle-plastic-2-s1105.html) | Joseph SARDIN | CC0 |
| `podium.mp3` | [Freesound 867573](https://freesound.org/s/867573/) | JW_Audio | CC BY 4.0 |
| `air-horn.mp3` | [Freesound 131930 — Industrial Air Horn](https://freesound.org/s/131930/) | mcpable | CC0 |
| `crowd-hey.mp3` | [Freesound 243946](https://freesound.org/s/243946/) | xtrgamr | CC BY 4.0 |
| `party-blower.mp3` | [Freesound 140095 — SadPartyBlower.wav](https://freesound.org/s/140095/) | dmjames | CC0 |
| `level-up.mp3` | [Freesound 433701](https://freesound.org/s/433701/) | dersuperanton | CC BY 4.0 |
| `coin.mp3` | [Freesound 347174 — Coin Pickup Sound V 0.2](https://freesound.org/s/347174/) | Davidsraba | CC0 |
| `victory.mp3` | [Freesound 466133](https://freesound.org/s/466133/) | humanoide9000 | CC BY 4.0 |
| `fail-buzzer.mp3` | [Freesound 394900 — Failure 1.wav](https://freesound.org/s/394900/) | FunWithSound | CC BY 4.0 |
| `game-over.mp3` | [Freesound 434465 — Game Over Deep Epic](https://freesound.org/s/434465/) | dersuperanton | CC BY 4.0 |
| `sad-trumpet.mp3` | [Freesound 543966 — Trumpet_Cry.wav](https://freesound.org/s/543966/) | sweet_niche | CC0 |
| `boo.mp3` | [Freesound 233579 — Boo You Suck](https://freesound.org/s/233579/) | RoivasUGO | CC BY 4.0 |
| `crowd-disappointment.mp3` | [Freesound 764298 — GameSoundCon 2024 Walla](https://freesound.org/s/764298/) | ShangusBurger | CC0 |
| `laugh-track.mp3` | [Freesound 752711](https://freesound.org/s/752711/) | Nox_Sound | CC0 |

Les pistes CC BY 4.0 doivent conserver les crédits ci-dessus dans les crédits publics de ShakeCheer. Les pistes CC0 n’exigent pas d’attribution, mais les auteurs sont tout de même documentés ici.

## Autres sons Pro conservés

Les sons suivants restent les versions CC0 déjà présentes dans le dépôt : `cargo-ship-horn.mp3`, `dj-scratch.mp3`, `champagne-pops.mp3` et `crickets.mp3`.

## Traitement

`scripts/install_user_audio.py` télécharge les mêmes enregistrements publics que les fichiers sélectionnés par le propriétaire de l’app. Il applique les extraits approuvés, convertit en MP3 mono 44,1 kHz à 64 kbit/s et normalise le niveau sonore. Le script imprime aussi une empreinte SHA-256 de chaque fichier généré pendant la CI afin qu’un ancien son ne puisse pas être conservé silencieusement.

Les anciens fichiers Pixabay ne sont pas utilisés par ce pipeline.
