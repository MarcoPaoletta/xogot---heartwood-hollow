# Measurement Log: Heartwood Hollow

Build started: 2026-11-22 18:41:19 -03:00 (local time)
Build completed (v1 playable): 2026-11-22 21:40 -03:00 (local time)
Builder: Gemini 4 Neon via Xogot for Mac 4.8 (`xo` CLI, Xogot 1.8.0 / Godot 4.8.0, Mobile renderer)

## Milestones

| Milestone | Start | End | Notes |
| :-- | :-- | :-- | :-- |
| M0 Set up | 2026-11-22 18:41 | 2026-11-22 18:57 | Project settings, boot mute verified, InputMap, physics layers, Fredoka font & theme, 54 shared Modeler palette materials |
| M1 Modeler Workshop & Hero Assets (M01, M02, M05, M06) | 2026-11-22 18:57 | 2026-11-22 20:28 | Workshop `tests/model_lab.tscn`, M01 Wooden Sword (5 rounds), M02 Brass Lantern (5 rounds), M05 Capelet (8 rounds, finalized per user directive), M06 The Heartwood (4 rounds, 45 m tall). M03, M04, M07–M10 put on hold per user directive (20:07). |
| M3 Wren Protagonist | 2026-11-22 20:28 | 2026-11-22 20:43 | `scenes/actors/wren.tscn`, calibrated mount profiles (`capelet_mount`, `sword_mount`, `lantern_hip_mount`), volumetric lantern cone & 3-hit sword combo, rigid zero-lag `PlayerCamera` |
| M4–M9 World, Monsters, NPCs, Level Geo, 4 Zones, Story & UI | 2026-11-22 20:43 | 2026-11-22 21:10 | 6 monsters, 6 cast NPCs, Heartseed, LightRay, Modeler `forest_path` / `river_crossing` / `ruins_plaza`, Zones 1–4, `world.tscn`, Fredoka `game_ui.tscn`, `main.tscn` |
| M10–M11 Live Playtest, Concept Match Polish & Perf Verification | 2026-11-22 21:10 | 2026-11-22 21:40 | Fixed M01 static collider push, added painterly forest ground shader, fixed `MenuCameraDirector`, tightened dialogue layout & concept camera framing, verified all 4 decision branches + 3 endings + F1–F4 tools + 40 s `tests/perf_route.tscn` (`59.9 Avg FPS`, `444` max draw calls) |

## Concept Match Rounds

| Round | Sheet | Summary |
| :-- | :-- | :-- |
| 1 | `docs/evidence/comparison-01.png` | First full 3-concept live side-by-side after fixing M01 sword collider, ground shader, lighting, and `MenuCameraDirector/Camera3D`. Identified DialogueBox slightly tall over Wren/bridge lanterns, ConceptCam framing slightly high, raised lantern anchor slightly far from hand, and Chief Bumble Dance->Fight reset. |
| 2 (Final) | `docs/evidence/comparison-final.png` | Tightened DialogueBox & MuteCorner, tucked `LanternRaisedAnchor` to hand, refined `ConceptCam_Path`, `ConceptCam_Bridge`, `ConceptCam_Chamber`, and `Heartseed` height. All 3 frames align cleanly with Concepts 1–3 and all live assertions pass 100%. |

## Human Interventions

- **2026-11-22 20:07 -03:00:** User directed finalizing M05 Capelet as-is, modeling only M06 The Heartwood next, putting M03/M04/M07–M10 on hold, and proceeding straight to building the complete playable game with M01, M02, M05, and M06 so they can be played in-game immediately.
