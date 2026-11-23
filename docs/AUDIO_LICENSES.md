# Audio licenses

The music and ambience in `assets/audio/music/` and `assets/audio/ambience/` were downloaded at setup on 2026-11-21 from their official pages. All of it is CC0 1.0 (public domain dedication): no attribution is required, the credits below are a courtesy. The effects and stingers are original, synthesized from code for this game (see below). Add a row for anything added later (GDD Section 11).

## Music (`assets/audio/music/`)

Each track was chosen from its description and license page; listen to each one in the game before locking its role. Loop points still have to be set or checked in the import settings.

| File | Role in the GDD | Length | Author | License | Source |
| :-- | :-- | --: | :-- | :-- | :-- |
| `fairy_adventure_bpm140.ogg` | Forest adventure theme (Zones 1 and 2) | 144.0 s | mintodog | CC0 | [Fairy Adventure](https://opengameart.org/content/fairy-adventure) ("fantasy field music", described as loopable) |
| `apple_cider.ogg` | Title screen and Thistle | 199.8 s | Zane Little Music | CC0 | [Apple Cider](https://opengameart.org/content/apple-cider) (cozy) |
| `battleThemeA.mp3` | Tense variant, bridge fight | 95.9 s | cynicmusic | CC0 | [Battle Theme A](https://opengameart.org/content/battle-theme-a) |
| `forest_whisper.ogg` | Mysterious variant, Foggy Ruins | 82.3 s | Cleyton Kauffman | CC0 | [Forest Whisper Theme](https://opengameart.org/content/forest-whisper-theme) (described as a seamless loop) |
| `beautiful_forest.ogg` | Awe variant, Heart Chamber | 70.0 s | nene | CC0 | [Beautiful Forest (Orchestra)](https://opengameart.org/content/beautiful-forest-orchestra) |

## Stingers (`assets/audio/stingers/`)

Original, synthesized by `tools/audio/make_sfx.py` (plucked strings, steel pan and bell partials, no samples), owned by the project under its MIT license.

| File | Use | Length |
| :-- | :-- | --: |
| `ending_forest.ogg` | Ending: Return it to the forest | 1.9 s |
| `ending_home.ogg` | Ending: Carry it home to Thistle | 1.9 s |
| `ending_share.ogg` | Ending: Share the light | 1.7 s |
| `choice_honey.ogg` | Offer the honey | 2.1 s |
| `choice_fight.ogg` | Fight for the bridge | 0.3 s |
| `calm_burst.ogg` | Calm burst | 1.2 s |
| `seed_awaken.ogg` | The Heartseed awakens | 1.9 s |

No chiptune and no 8 bit sounds anywhere (GDD Section 11).

## Effects (`assets/audio/sfx/`)

Original, synthesized by `tools/audio/make_sfx.py` (filtered noise, modal wood and metal resonators, sine glides, no samples), owned by the project under its MIT license. Rebuild with `py -3 tools/audio/make_sfx.py`; every random stream is seeded, so a rebuild gives the same sounds, and the script prints the length, peak and RMS of each file.

| Files | Covers |
| :-- | :-- |
| `step_dirt_1..4`, `step_wood_1..4`, `step_stone_1..3` | Footsteps on dirt, planks and stone |
| `cloth_1..3` | Lantern raise and lower |
| `calm_chime_1..2` | The calm chime |
| `sword_swish_1..2`, `wood_bonk_1..4` | Wooden sword swings and bonks |
| `sparkle_poof_1..2` | The sparkle poof |
| `monster_happy_1..2`, `monster_grumpy_1..2` | Monster squeaks, happy and grumpy |
| `player_hurt_1..2` | Wren takes a hit |
| `honey_pour_1..2` | The honey pour |
| `dialogue_blip_1..2` | Dialogue blips |
| `ui_hover`, `ui_click_1..2`, `ui_reject` | Buttons |
| `shield_equip` | Captain Rook's shield |
| `brazier_light` | The braziers ignite |

## Ambience (`assets/audio/ambience/`)

| File | Use | Length | Author | License | Source |
| :-- | :-- | --: | :-- | :-- | :-- |
| `forest_ambience.mp3` | Forest bed, every zone | 44.7 s | TinyWorlds | CC0 | [Forest Ambience](https://opengameart.org/content/forest-ambience) (described as a seamless loop) |
| `park_ambience_river_90s.ogg` | River, Zone 2 | 90.0 s | thimras | CC0 | [Park ambiences](https://opengameart.org/content/park-ambiences), `park_ambience_river.wav` |
| `park_ambience_birds_90s.ogg` | Birds and leaves, Zones 1 and 4 | 90.0 s | thimras | CC0 | [Park ambiences](https://opengameart.org/content/park-ambiences), `park_ambience_birds.wav` |

The two park files are 90 s excerpts (from second 20, 1 s fades, OGG Vorbis q5) of the original 7.5 and 8.6 minute WAV recordings (86 and 99 MB), cut at setup to keep the repo light. CC0 allows the edit.

Every effect role of the GDD has its own file in the tables above.
