# Build Notes: Heartwood Hollow

Decisions, tuned values, lighting values, camera values, mount profiles, and verification findings recorded as the game is built (GDD Section 15).

## Engine & Launch Configuration (M0)

- Engine: Xogot for Mac 4.8 (`Godot 4.8.0`, Xogot `1.8.0 (2551)`), Mobile renderer, version stamp preserved at `4.8`.
- Display: `1920x1080` design canvas, `mode=0` (windowed), `initial_position_type=1` (center primary), `resizable=true`, `stretch/mode="canvas_items"`, `stretch/aspect="expand"`.
- Physics: `physics_interpolation=true`, `physics_jitter_fix=0.0`.
- Physics layers: 1 `world`, 2 `player`, 3 `npcs`, 4 `monsters`, 5 `sword_hitbox`, 6 `lantern_cone`, 7 `triggers`.
- Anti-aliasing: `msaa_3d=1` (2x MSAA for clean low-poly edges under Mobile renderer).
- Boot mute: `Audio` autoload mutes `Master` bus in `_ready()`, `M` (`toggle_mute` physical keycode) toggles mute on all screens including while paused. Verified live at runtime (`boot_muted=true`, `after_unmute=false`, `after_remute=true`, `paused_mute_toggle_works=true`).
- Font selection (Section 8.1): Evaluated all three OFL candidates (`Fredoka`, `Baloo 2`, `Lilita One`) side-by-side (`docs/evidence/font-candidates.png`). Selected **Fredoka** (`assets/fonts/Fredoka-Variable.ttf`, SIL OFL 1.1 in `assets/fonts/OFL.txt`) via `FontVariation` (`heartwood_font.tres` at `wght=640`, `heartwood_font_bold.tres` at `wght=700`).
- Shared Modeler palette: 54 `StandardMaterial3D` resources created in `assets/modeler/_materials/`.

## Xogot Modeler Assets & User Scope Override

- Completed and verified in `tests/model_lab.tscn`:
  - **M01 Wren's Wooden Sword** (5 rounds, `396 tris`, `0.190 x 0.780 x 0.042 m`).
  - **M02 Wren's Brass Lantern** (5 rounds, `640 tris`, `0.162 x 0.300 x 0.143 m`, with `OmniLight3D` + radial halo).
  - **M05 Wren's Capelet** (8 rounds, finalized per user directive, `452 tris`, `0.623 x 0.357 x 0.422 m`).
  - **M06 The Heartwood** (4 rounds, `12,532 tris`, `48.200 x 46.183 x 40.450 m`, `max_y = 45.0 m`, walkable Modeler trimesh collision on trunk + 6 mossy Bezier root arches).
- Modeled level geometry (`assets/modeler/level/`): `forest_path.tscn` (Bezier Plane winding dirt ribbon + edge underlay), `river_crossing.tscn` (walkable plank deck, approach ramps, 4 post pairs, sagging Bezier rope rails, safety walls, two M02 Lanterns at scale 1.4), `ruins_plaza.tscn` (16x16 m stone slab plaza).
- **On Hold (per user directive 2026-11-22 20:07):** M03 (mossy rocks), M04 (old forest trees), M07 (Heartseed/shard hero polish), M08 (hero bridge polish), M09 (honey pot), M10 (guard's shield). Zero pack models of Modeler categories are substituted anywhere in the project. Outer forest corridor borders reuse rotated distant instances of M06 (with sockets turned outward away from the path) so only the Zone 4 Heartwood displays the Heartseed socket.

## Wren Rig, Mount Profiles & Camera

- Base rig: `Rogue.gltf` at scale `0.50` (`1.50 m` tall), `Rogue_Dagger` hidden permanently. Facing convention: rig faces `+Z`, so `VisualRoot` starts at `rotation.y = PI` (`180°`) facing north (`-Z`).
- Calibrated `WeaponMountProfile` resources (`assets/resources/mounts/`):
  - `capelet_mount.tres`: `Torso`, offset `(0, 0.22, -0.02)`, rot `(0, 180, 0)`, scale `0.92`.
  - `sword_mount.tres`: `Weapon.R`, rot `(85, 0, 0)`.
  - `lantern_hip_mount.tres`: `Hips`, offset `(0.24, 0.04, -0.06)`; smoothly blends to `LanternRaisedAnchor` `(0.28, 1.24, 0.34)` while raising `UpperArm.L` / `LowerArm.L` when holding Right Mouse.
- Camera (`PlayerCamera`): rigid zero-lag follow on `get_global_transform_interpolated().origin + (0, 1.32, 0)`, `SpringArm3D` length `3.50 m` (`3.15 m` lantern raised), FOV `50°` (`47°` lantern raised), initial pitch `-16°`, trauma-squared hit shake.
- Movement: `walk_speed = 2.2 m/s`, `run_speed = 5.0 m/s`, `accel_time = 0.08 s`, `turn_rate = 16 rad/s`, facing input wish vector (never velocity).
- Combat & Signature Mechanic: 3-hit sword combo (`0.35 s` swing, `0.65 s` window, `35 ms` hitstop), 6 m golden volumetric lantern cone (`assets/shaders/lantern_cone.gdshader`) calming normal monsters in `1.2 s` and stunning Chief Bumble for `1.0 s`.

## Lighting, Ground Shader & Concept Match

- Environment (`assets/resources/env/heartwood_env.tres`): Filmic tonemap (`exposure = 0.96`), warm forest ambient (`#5A7A4A`, energy `0.52`, sky contribution `0.45`), sunlit sage depth fog (`#C4D996`, begin `38 m`, density `0.0075`), glow (`bloom = 0.14`, HDR threshold `1.0`). Zone 3 shifts dynamically to cool dense mist (`#B9C7C9`, begin `8 m`, density `0.024`) until Captain Rook's braziers burn it away.
- Ground shader (`assets/shaders/forest_ground.gdshader`): multi-scale procedural painterly moss/meadow variation (`#3D6624` / `#5E8F33` / `#8FB042`) replacing flat neon grass.
- Water shader (`assets/shaders/river_water.gdshader`): sparkling teal surface with scrolling sun glints (`Y = -0.22`) over a recessed riverbed (`Y = -1.15`) split cleanly between `SouthMesh` and `NorthMesh` with zero z-fighting.
- Concept Match rounds:
  - **Round 1 (`comparison-01.png`):** Caught accidental `ModelerCollision` static body inside `m01_wooden_sword.tscn` pushing Wren on spawn (removed + defensive guard added in `wren.gd`), fixed `MenuCameraDirector/Camera3D` + shot exports, tightened `DialogueBox` anchoring, added peaceful-idle monster guard during title & dialogue.
  - **Round 2 (`comparison-final.png`):** Tightened `DialogueBox` and `MuteCorner` spacing, tucked `LanternRaisedAnchor` closer to Wren's raised hand, refined `ConceptCam_Path`, `ConceptCam_Bridge`, and `ConceptCam_Chamber` framing so Wren, both M02 bridge lanterns, Chief Bumble, watcher monsters, Pip & Moss, and the glowing Heartseed all sit cleanly above the dialogue panel, and fixed `set_hostile_mode(true, true)` so re-triggering Fight after Dance resets Chief Bumble cleanly.

## Live Verification Summary

- All 16 scripts pass `xo script check` with 0 errors and 0 warnings.
- Live playtest verified: Boot mute & `M` toggle (normal + paused), opening dialogue & honey pot handoff, `<10 s` lantern calming (`FirstBlob` -> `CALM`, `monsters_calmed = 1`), 3-hit sword bonk (`Z1_Winged1` -> `POOFED`, `monsters_bonked = 1`), Decision 1 Honey (`shortcut_open = true`, camp dance, bakery message card) & Fight (`bridge_choice = "fight"`, tents collapsed `±72°`, east woods hostile), Decision 2 Turn In (`braziers_lit = true`, fog cleared, shield granted) & Keep (`sparkle_trail_active = true`), Zone 4 Heartseed awakening + all 3 endings (`forest`, `home`, `share`) with distinct color grades & End Card, F1 Presenter Panel, F2 Showcase Cameras + Heartwood Orbit, F3 Hide HUD, and F4 Modeler Gallery (`tests/model_lab.tscn`).
