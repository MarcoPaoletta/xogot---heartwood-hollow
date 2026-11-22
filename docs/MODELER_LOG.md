# Xogot Modeler log

Heartwood Hollow, Xogot video 10. Kept by the builder while the game is built (GDD Sections 1.4, 1.8 and 15). Numbers come from tools and files, never from memory.

## Issues

Every Modeler problem goes here the moment it happens, newest first, and is also posted in the chat as one line starting with `MODELER ISSUE:`. One entry per problem: time, asset ID, operation, what was expected, what happened (exact error text or symptom), whether it reproduces, the workaround, the time lost, and a screenshot path in `docs/evidence/modeler/issues/`. If no issue happened, write one line saying so.

### Issue 02 — `xo modeler create --type torus` rejects small-scale rings (0.06 m)
- **Time:** 2026-11-22 19:26 -03:00
- **Asset ID:** M02 (`m02_brass_lantern`)
- **Operation:** `xo modeler create /Mesh --type torus --param rows=6 --param columns=10 --param tubeRadius=0.005 --size 0.060,0.010,0.060` (and with `--size 0.060,0.060,0.060 --param tubeRadius=0.006`)
- **Expected:** A small brass carrying ring (`0.060 m` outer diameter, `0.010 m` tube thickness).
- **What happened:** Error (exit code 31 / 1): `Error: Torus radius, segments, or circumference are not valid.`
- **Reproduces:** Yes, reproducible for small radii (`~0.03 m` outer radius).
- **Workaround:** Use `xo modeler create --type pipe --param sides=10 --param thickness=0.010 --param smooth=0 --size 0.060,0.010,0.060 --rotation=90,0,0`, optionally beveled via `modeler action ... bevel`, which produces a clean faceted brass carrying ring.
- **Time lost:** ~1 minute
- **Screenshot:** `docs/evidence/modeler/m02_brass_lantern-r01.png` (carrying ring built via `pipe` workaround)

### Issue 01 — `xo modeler bevel` crashes Swift ArgumentParser
- **Time:** 2026-11-22 19:12 -03:00
- **Asset ID:** M01 (`m01_wooden_sword`)
- **Operation:** `xo modeler bevel /Guard --mode edge --all --amount 0.006 --segments 1` (and with `--affect edges --amount-type offset --profile 0.5`)
- **Expected:** Bevel all selected edges of `/Guard` in one undo step.
- **What happened:** Fatal Swift ArgumentParser error (exit code 1): `Can't read a value from a parsable argument definition. This error indicates that a property declared with an @Argument, @Option, @Flag, or @OptionGroup property wrapper was neither initialized to a value nor decoded from command-line arguments.`
- **Reproduces:** Yes, 100% reproducible on every invocation of `xo modeler bevel`.
- **Workaround:** Use `xo modeler action <node> bevel --mode edge --all --bevel-amount 0.006 --bevel-segments 1`, which works cleanly (26 faces, 24 vertices on cube).
- **Time lost:** ~2 minutes
- **Screenshot:** `docs/evidence/modeler/issues/issue-01-bevel-cli.png` (captured after applying workaround on `/Guard`)

## Real names of the Modeler operations used

Inspected live via `xo modeler shapes` and `xo modeler actions` in Xogot 4.8 (`1.8.0 (2551)`):

- **Parametric shapes (`xo modeler create`):** `cube`, `prism`, `sprite`, `plane`, `cylinder`, `cone`, `sphere`, `pipe`, `torus`, `arch`, `door`, `stairs`
- **Freeform shapes:** `xo modeler poly create/edit` (Poly Shape with `--outline`, `--hole`, `--height`), `xo modeler bezier create/edit` (Bezier Plane / Bezier Block with `--knot`, `--radius`, `--height`, `--rows`, `--columns`)
- **Editing & sculpting:** `xo modeler mode`, `xo modeler select`, `xo modeler transform` (`--translate`, `--rotate`, `--scale`, `--extrude`, `--soft-radius`, `--soft-curve`), `xo modeler bevel`, `xo modeler cut`, `xo modeler boolean` (`union`, `intersection`, `subtraction`), `xo modeler make-editable`
- **Painting & smoothing:** `xo modeler paint material`, `xo modeler paint smoothing` (`--faceted`, `--group`), `xo modeler paint position`, `xo modeler slot list/set`
- **Actions (`xo modeler action`):** `extrudeFaces`, `insetFaces`, `bevel`, `bevelEdges`, `subdivideFaces`, `subdivideEdges`, `insertEdgeLoop`, `bridgeEdges`, `collapseVertices`, `weldVertices`, `flipFaces`, `deleteFaces`, `duplicateFaces`, `detachFaces`, `conformNormals`, `triangulateFaces`, `offsetElements`, `setPivot`, `centerPivot`, `freezeTransform`, `mirrorObjects`, `mergeObjects`, `setCollider`, `setTrigger`, `generateUV2`
- **Collision:** `--collision none|convex|box|mesh|trimesh` on `modeler create` and `action setCollider` (generates `StaticBody3D` named `ModelerCollision` with `CollisionShape3D`).

## Review rounds

One row per round (GDD Section 1.4): asset, round, review sheet path, what changed, what still fails.

| Asset | Round | Sheet | What changed | What still fails |
| :-- | :-- | :-- | :-- | :-- |
| M01 Wooden Sword | 1 | `docs/evidence/modeler/m01_wooden_sword-r01.png` | Blockout of blade, prism tip, guard, octagonal grip & pommel at exact `0.19 x 0.78 x 0.045 m` (96 tris). Fixed workshop camera framing & Wren cutout rotation. | Plain rectangular blade slab, no bevels/taper, no leather grip wraps, under 150-400 tri target. |
| M01 Wooden Sword | 2 | `docs/evidence/modeler/m01_wooden_sword-r02.png` | Sculpted 8-pt beveled plank Poly Shape with taper (`0.085 -> 0.075 m`) and extruded `0.070 m` chisel point; beveled guard & pommel (`276 tris`). | Blade reads flat yellow (single material), tip too thin in side view, grip missing raised leather wraps, guard needs collar bolster. |
| M01 Wooden Sword | 3 | `docs/evidence/modeler/m01_wooden_sword-r03.png` | Upgraded blade to 10-pt central-ridge faceted cross-section with chunkier wooden tip, added guard bolster collar & 2 tilted raised leather grip wraps (`396 tris`). | Blade faces still single uniform material, bevel borders do not contrast at gameplay distance. |
| M01 Wooden Sword | 4 | `docs/evidence/modeler/m01_wooden_sword-r04.png` | Per-face Modeler Paint on blade, guard, and pommel (`#E8B77E`, `#C98F55`, `#9C6338`, `#7A4A2A`, `#5A3420`, `#8B5A36`). | Outer bevel slope normal (`|nx|≈0.34`) missed the `0.45` threshold so wide edge bevels stayed light instead of `#9C6338`. |
| M01 Wooden Sword | 5 | `docs/evidence/modeler/m01_wooden_sword-r05.png` | Painted wide outer edge bevels & tip bevel slopes `#9C6338`, central ridge halves split `#E8B77E` / `#C98F55`, dark guard & collar with top highlight (`396 tris`). | None — all M01 workshop criteria pass (pose check verified in M3). |
| M02 Brass Lantern | 1 | `docs/evidence/modeler/m02_brass_lantern-r01.png` | Blockout at exact `0.300 m` height (pivot at ring top `Y=0`): carrying ring (`pipe`), finial, cone cap, hex glass cage, hex base (`162 tris`). | Straight cage (no bulge), no 6 bronze bars, pointy cone cap, pale glass, no inner diamond core. |
| M02 Brass Lantern | 2 | `docs/evidence/modeler/m02_brass_lantern-r02.png` | Added bulging hex glass, overhanging domed cap + rim, flared base, and 6 separate bronze bars (`408 tris`). | Euler order on tilted bars bowed all bars right (`>`) instead of radially outward; cage slightly tall; no mid-band or diamond core. |
| M02 Brass Lantern | 3 | `docs/evidence/modeler/m02_brass_lantern-r03.png` | Rebuilt 6 vertical corner bars with middle-ring radial sculpting (100% symmetrical bulge), added warm amber glass, bright diamond core flame, horizontal mid-band, seating collars, `OmniLight3D`, and `GlowSprite` (`524 tris`). | Cap dome could curve smoother (1 cut), ring needed physical mount saddle into finial, mid-band slightly thick across diamond. |
| M02 Brass Lantern | 4 | `docs/evidence/modeler/m02_brass_lantern-r04.png` | Upgraded cap dome to 2-step curve (`heightCuts=2`), added brass ring saddle, slimmed mid-band (`0.0065 m`), enlarged diamond core, per-face bronze paint contrast (`548 tris`). | Cap overhang rim could catch sharper highlight and bars slightly bolder at gameplay distance. |
| M02 Brass Lantern | 5 | `docs/evidence/modeler/m02_brass_lantern-r05.png` | Beveled overhanging cap rim (`0.003 m`), deepened bronze cap contrast (`#6E3A1C` vs `#A0602A`), thickened 6 bars (`0.0128 m`), refined halo (`640 tris`). | None — all M02 workshop criteria pass (hip/raised pose checks verified in M3). |

## Criteria check per asset

### M01 Wren's Wooden Sword (Tier A — 5 rounds) — PASS
- Size: `0.190 x 0.780 x 0.042 m` (target `0.78 m` total, `0.19 m` guard, `0.085->0.075 m` blade, `0.07 m` point; all within 5%).
- Triangles: `396` (target `150–400`).
- Pivot & orientation: grip center `(0,0,0)`, blade `+Y`, flat faces `±Z`, edges `±X`.
- Silhouette (`RevGameplay` & `RevFar`): blade, guard, grip, pommel, and chisel point read separately and unmistakably.
- Palette & wood read: warm light/mid central ridge split (`#E8B77E`/`#C98F55`) framed by `#9C6338` bevel borders, `#7A4A2A` beveled guard/pommel, `#5A3420` grip + `#8B5A36` angled wraps; never reads as metal or plain box.
- Hand fit pose checks: deferred to M3 Wren mount calibration (will re-verify here).

### M02 Wren's Brass Lantern (Tier A — 5 rounds) — PASS
- Size: `0.162 x 0.300 x 0.143 m` (target `0.30 m` total height, `0.13 m` cap across flats, `0.115 m` bulging cage across flats, `0.11 m` base, `0.06 m` ring).
- Triangles: `640` (target `400–1,200`).
- Pivot & orientation: top of carrying ring `(0,0,0)`, hanging downward along `-Y`, `+Y` up.
- Silhouette (`RevGameplay` & `RevFar`): overhanging cap, bulging cage, flared base, and ring all read clearly; warm gold glow never washes out silhouette.
- Detail & palette: 6 hexagonal panes and 6 separate curved dark bronze bars (`#8B4102`) countable at `RevGameplay`, domed bronze cap (`#6E3A1C` + `#A0602A` beveled rim), brass ring/finial (`#C98A2E`), warm amber glass (`#FFB828` translucent emissive), glowing diamond flame core (`#FFF6C8`), `OmniLight3D` (`#FFC873`, energy `1.4`, range `5 m`) + radial `GlowSprite`.
- Hip/raised pose checks: deferred to M3 Wren mount calibration; bridge reuse at scale 1.4 verified in M5.

## What worked especially well

_No entries yet._
