# Build Notes: Heartwood Hollow

Decisions, tuned values, lighting values, camera values, mount profiles, and verification findings recorded as the game is built (GDD Section 15).

## Engine & Launch Configuration (M0)

- Engine: Xogot for Mac 4.8 (`Godot 4.8.0`, Xogot `1.8.0 (2551)`), Mobile renderer, version stamp preserved at `4.8`.
- Display: `1920x1080` design canvas, `mode=0` (windowed), `initial_position_type=1` (center primary), `resizable=true`, `stretch/mode="canvas_items"`, `stretch/aspect="expand"`.
- Physics: `physics_interpolation=true`, `physics_jitter_fix=0.0`.
- Physics layers: 1 `world`, 2 `player`, 3 `npcs`, 4 `monsters`, 5 `sword_hitbox`, 6 `lantern_cone`, 7 `triggers`.
- Anti-aliasing: `msaa_3d=1` (2x MSAA for clean low-poly edges under Mobile renderer).
- Boot mute: `Audio` autoload mutes `Master` bus in `_ready()`, `M` (`toggle_mute` physical keycode) toggles mute on all screens including while paused. Verified at runtime (`BOOT_MUTED=true`, `M` flips `false` -> `true`).
- Font selection (Section 8.1): Evaluated all three OFL candidates (`Fredoka`, `Baloo 2`, `Lilita One`) side-by-side in a Concept-2-styled dialogue box (`docs/evidence/font-candidates.png`). Selected **Fredoka** (`assets/fonts/Fredoka-Variable.ttf`, SIL OFL 1.1 in `assets/fonts/OFL.txt`) via `FontVariation` (`heartwood_font.tres` at `wght=640`, `heartwood_font_bold.tres` at `wght=700`) as the closest rounded, cozy match to the concepts. Set `gui/theme/custom_font` and `gui/theme/custom` (`assets/resources/theme_heartwood.tres`).
- Shared Modeler palette: 54 `StandardMaterial3D` resources created in `assets/modeler/_materials/` using the exact hex values and roughness/metallic/emission specs from GDD Sections 1.6 and 1.7.
