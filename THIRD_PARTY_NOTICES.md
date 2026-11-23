# Third-party notices

Everything under `assets/quaternius/`, `assets/audio/music/`, `assets/audio/ambience/` and `assets/fonts/` is third-party material under its own license, kept in its own folder with its license file. None of it is covered by the MIT license of this repository. The packs were downloaded on 2026-11-21 from the author's official page (free tiers only); the Survival Pack, Medieval Village Pack and Ultimate Platformer Pack subsets were added on 2026-11-23 from Quaternius's own uploads of those packs.

## 3D models

| Path | Pack | Author | License | License file | Source |
| :-- | :-- | :-- | :-- | :-- | :-- |
| `assets/quaternius/ultimate-monsters/` | Ultimate Monsters (glTF) | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/ultimatemonsters.html) |
| `assets/quaternius/cute-animated-monsters/` | Cute Animated Monsters (glTF) | Quaternius | CC0 1.0 | `License.txt` (written at setup: the download has none, the pack page states CC0) | [quaternius.com](https://quaternius.com/packs/cutemonsters.html) |
| `assets/quaternius/rpg-character-pack/` | RPG Character Pack (glTF, Humanoid Rig FBX, textures) | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/rpgcharacters.html) |
| `assets/quaternius/universal-animation-library/` | Universal Animation Library, Standard (free) tier (GLB) | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/universalanimationlibrary.html) |
| `assets/quaternius/stylized-nature-megakit/` | Stylized Nature MegaKit, Standard (free) tier (glTF), ground cover subset | Quaternius | CC0 1.0 | `License_Standard.txt` | [quaternius.com](https://quaternius.com/packs/stylizednaturemegakit.html) |
| `assets/quaternius/ultimate-modular-ruins/` | Ultimate Modular Ruins Pack (FBX), architecture subset | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/ultimatemodularruins.html) |
| `assets/quaternius/medieval-village-megakit/` | Medieval Village MegaKit, Standard (free) tier (glTF) | Quaternius | CC0 1.0 | `License_Standard.txt` | [quaternius.com](https://quaternius.com/packs/medievalvillagemegakit.html) |
| `assets/quaternius/fantasy-props-megakit/` | Fantasy Props MegaKit, Standard (free) tier (glTF), subset | Quaternius | CC0 1.0 | `License_Standard.txt` | [quaternius.com](https://quaternius.com/packs/fantasypropsmegakit.html) |
| `assets/quaternius/survival-pack/` | Survival Pack (FBX), `Tent` only | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/survival.html) |
| `assets/quaternius/medieval-village-pack/` | Medieval Village Pack (FBX), `Bonfire` only | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/medievalvillage.html) |
| `assets/quaternius/ultimate-platformer-pack/` | Ultimate Platformer Pack (glTF), `Arrow_Side` signpost only | Quaternius | CC0 1.0 | `License.txt` | [quaternius.com](https://quaternius.com/packs/ultimateplatformer.html) |

Subsets: the models of the categories the game builds itself in Xogot Modeler (trees, rocks, pebbles, weapons, shields, lanterns, torches, candles, pots, vases, bottles, potions, bridges) were left out of the Nature, Ruins and Fantasy Props packs on purpose, so no pack model can stand in for a Modeler asset. The full list of what each pack folder holds is in `docs/MEASUREMENTS.md`.

## Audio

| Path | Author | License | Source |
| :-- | :-- | :-- | :-- |
| `assets/audio/music/fairy_adventure_bpm140.ogg` | mintodog | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/fairy-adventure) |
| `assets/audio/music/apple_cider.ogg` | Zane Little Music | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/apple-cider) |
| `assets/audio/music/battleThemeA.mp3` | cynicmusic | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/battle-theme-a) |
| `assets/audio/music/forest_whisper.ogg` | Cleyton Kauffman | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/forest-whisper-theme) |
| `assets/audio/music/beautiful_forest.ogg` | nene | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/beautiful-forest-orchestra) |
| `assets/audio/ambience/forest_ambience.mp3` | TinyWorlds | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/forest-ambience) |
| `assets/audio/ambience/park_ambience_*_90s.ogg` (90 s excerpts) | thimras | CC0 1.0 | [OpenGameArt](https://opengameart.org/content/park-ambiences) |

Roles and lengths: `docs/AUDIO_LICENSES.md`.

## Fonts

| Path | Font | Author | License | Source |
| :-- | :-- | :-- | :-- | :-- |
| `assets/fonts/candidates/lilitaone/` | Lilita One | Juan Montoreano | SIL Open Font License 1.1 (`OFL.txt`) | [Google Fonts](https://github.com/google/fonts/tree/main/ofl/lilitaone) |
| `assets/fonts/candidates/fredoka/` | Fredoka (variable) | The Fredoka Project Authors (hafontia) | SIL Open Font License 1.1 (`OFL.txt`) | [Google Fonts](https://github.com/google/fonts/tree/main/ofl/fredoka) |
| `assets/fonts/candidates/baloo2/` | Baloo 2 (variable) | The Baloo 2 Project Authors (Ek Type) | SIL Open Font License 1.1 (`OFL.txt`) | [Google Fonts](https://github.com/google/fonts/tree/main/ofl/baloo2) |

## Ours

Everything else is project-authored and under the MIT license: every model made in Xogot Modeler (`assets/modeler/`), the sound effects in `assets/audio/sfx/` and the stingers in `assets/audio/stingers/` (synthesized from code by `tools/audio/make_sfx.py`, no samples), scenes, scripts, shaders, materials and docs.
