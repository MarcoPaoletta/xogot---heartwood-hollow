# Asset Manifest: Heartwood Hollow

Measured sizes, triangle counts, review rounds, and scene usage for every Xogot Modeler asset and every CC0 pack model used (GDD Sections 1.10, 10, 15). Zero pack models of Modeler categories are used anywhere in the project.

## Xogot Modeler Hero Assets (Section 1.5)

| ID | Asset | Scene Path | Measured Size X x Y x Z (m) | Triangles | Review Rounds | Status / Used In |
| :-- | :-- | :-- | :-- | --: | --: | :-- |
| M01 | Wren's wooden sword | `res://assets/modeler/m01_wooden_sword/m01_wooden_sword.tscn` | `0.190 x 0.780 x 0.042` | 396 | 5 | Complete — `scenes/actors/wren.tscn`, `tests/model_lab.tscn` |
| M02 | Wren's brass lantern | `res://assets/modeler/m02_brass_lantern/m02_brass_lantern.tscn` | `0.162 x 0.300 x 0.143` | 640 | 5 | Complete — `scenes/actors/wren.tscn`, `assets/modeler/level/river_crossing.tscn` (x2 @ 1.4x), `zone1_path.tscn` (gate & Bramble stall), `zone2_bridge.tscn` (tents), `zone4_chamber.tscn` (ruins), `tests/model_lab.tscn` |
| M05 | Wren's capelet | `res://assets/modeler/m05_capelet/m05_capelet.tscn` | `0.623 x 0.357 x 0.422` | 452 | 8 | Finalized per user directive — `scenes/actors/wren.tscn`, `tests/model_lab.tscn` |
| M06 | The Heartwood | `res://assets/modeler/m06_heartwood/m06_heartwood.tscn` | `48.200 x 46.183 x 40.450` | 12,532 | 4 | Complete — Hero 1.0x in `scenes/zones/zone4_chamber.tscn`, distant rotated corridor canopy silhouettes (`0.44-0.48x`, sockets outward) in `zone1_path`, `zone2_bridge`, `zone3_ruins`, `tests/model_lab.tscn` |
| M03, M04, M07-M10 | Rocks, forest trees, hero Heartseed/shard, hero bridge, honey pot, guard's shield | — | — | — | — | **On hold** per user directive (2026-11-22 20:07). No pack substitutions made. |

## Xogot Modeler Level Geometry & Story Props (Section 1.7)

| Asset | Scene Path | Purpose | Used In |
| :-- | :-- | :-- | :-- |
| Winding Forest Path | `res://assets/modeler/level/forest_path.tscn` | Bezier Plane dirt path ribbon + darker path-edge underlay connecting all 4 zones | `scenes/world.tscn` |
| River Crossing Bridge | `res://assets/modeler/level/river_crossing.tscn` | Walkable plank deck + south/north approach ramps + 4 post pairs + sagging Bezier rope rails + safety colliders + 2 M02 Brass Lanterns | `scenes/zones/zone2_bridge.tscn` (main crossing & unlockable East Shortcut) |
| Ruins Stone Plaza | `res://assets/modeler/level/ruins_plaza.tscn` | 16 x 16 m layered stone-slab plaza for Zone 3 Foggy Ruins decision | `scenes/zones/zone3_ruins.tscn` |
| Awakened Heartseed Prop | `res://scenes/props/heartseed_node.tscn` | Faceted Modeler bipyramid crystal + two orbiting Modeler pipe halo rings + `OmniLight3D` + sparkles + lantern trigger | `scenes/zones/zone4_chamber.tscn` |

## CC0 Pack Models Used (Supporting Cast Only)

| Role | Source Path | Scene Path | Instance Scale | Notes |
| :-- | :-- | :-- | --: | :-- |
| Wren (protagonist rig) | `assets/quaternius/rpg-character-pack/glTF/Rogue.gltf` | `scenes/actors/wren.tscn` | `0.50` | `1.50 m` tall; `Rogue_Dagger` hidden permanently; wears M05, wields M01 & M02 |
| Mayor Hollis | `assets/quaternius/rpg-character-pack/glTF/Cleric.gltf` | `scenes/actors/npc_mayor.tscn` | `0.55` | Pack weapon hidden by `npc.gd` |
| Mother Clove | `assets/quaternius/rpg-character-pack/glTF/Monk.gltf` | `scenes/actors/npc_clove.tscn` | `0.52` | Bakery NPC at Thistle Gate |
| Bramble (merchant) | `assets/quaternius/rpg-character-pack/glTF/Ranger.gltf` | `scenes/actors/npc_bramble.tscn` | `0.50` | Merchant Clearing NPC; pack weapon hidden |
| Captain Rook | `assets/quaternius/rpg-character-pack/glTF/Warrior.gltf` | `scenes/actors/npc_rook.tscn` | `0.56` | Zone 3 guard; pack sword hidden |
| Pip | `assets/quaternius/rpg-character-pack/glTF/Wizard.gltf` | `scenes/actors/npc_pip.tscn` | `0.38` | Small courier-kid scale; pack staff hidden |
| Moss (Pip's pet) | `assets/quaternius/cute-animated-monsters/glTF/Demon.gltf` | `scenes/actors/npc_moss.tscn` | `0.25` | Tinted soft purple (`#9A52D4`); `Icosphere` hidden |
| Teal Blob monster | `assets/quaternius/ultimate-monsters/Blob/glTF/GreenBlob.gltf` | `scenes/monsters/monster_blob.tscn` | `0.58` | `Icosphere` hidden |
| Winged Flitter monster | `assets/quaternius/cute-animated-monsters/glTF/Bat.gltf` | `scenes/monsters/monster_winged.tscn` | `0.52` | `Icosphere` hidden |
| Mushroom Sprig monster | `assets/quaternius/cute-animated-monsters/glTF/Mushroom.gltf` | `scenes/monsters/monster_mushroom.tscn` | `0.52` | Spore cloud puff attack; `Icosphere` hidden |
| Purple Furball monster | `assets/quaternius/cute-animated-monsters/glTF/Demon.gltf` | `scenes/monsters/monster_furball.tscn` | `0.58` | `Icosphere` hidden |
| Rolling Piglet monster | `assets/quaternius/cute-animated-monsters/glTF/Pig.gltf` | `scenes/monsters/monster_roller.tscn` | `0.56` | Charge roll attack; `Icosphere` hidden |
| Chief Bumble (boss) | `assets/quaternius/ultimate-monsters/Big/glTF/Yeti.gltf` | `scenes/monsters/chief_bumble.tscn` | `0.78` | Golden tint, 6 HP, lantern stuns 1 s; `Icosphere` hidden |
| Thistle Village cottages & gate | `assets/quaternius/medieval-village-megakit/glTF/` (`Wall_Plaster_*`, `Wall_UnevenBrick_Straight`, `Wall_Arch`, `Roof_RoundTiles_4x4`, `Roof_Front_Brick4`, `Door_1_Round`, `Window_Wide_Round1`, `Prop_Chimney`, `Prop_Wagon`, `Prop_WoodenFence_Single`) | `scenes/zones/zone1_path.tscn` | `1.0` (gate arch `2.7x1.65x2.2`) | Village framing & Thistle Gate |
| Ruins arches, columns, statues | `assets/quaternius/ultimate-modular-ruins/FBX/` (`Wall_ArchRound_Overgrown`, `Wall_ArchRound_Overgrown_Broken`, `Wall_Overgrown`, `Wall_Broken`, `Column_Round`, `Column_Round_Short`, `Statue_Fox`, `Statue_Stag`, `Bricks`) | Zones 1–4 | `0.95–1.50` | Mossy overgrown stone ruins |
| Stalls, crates, barrels, banners | `assets/quaternius/fantasy-props-megakit/glTF/` (`Stall_Empty`, `Stall_Cart_Empty`, `Barrel`, `Barrel_Apples`, `Crate_Wooden`, `Banner_1`, `Bench`, `Bag`) | Zones 1–2 | `0.85–1.15` | Bakery, Bramble's stall, camp props |
| Campfire pits | `assets/quaternius/medieval-village-pack/FBX/Bonfire.fbx` | Zones 1–4 | `3.1` | Stone ring and firewood under each campfire light |
| Camp tents | `assets/quaternius/survival-pack/FBX/Tent.fbx` | Zone 2 | `0.24` | Bumble's camp tents (they tip over after the fight) |
| Ruin braziers | `scenes/props/ruin_brazier.tscn`: Ruins `Column_Round_Short` (`0.9 x 0.55 x 0.9`) with `Bonfire` (`1.4`) on top | Zone 3 | `1.0` | Captain Rook's brazier route |
| Signpost | `assets/quaternius/ultimate-platformer-pack/glTF/Arrow_Side.gltf` | Zone 1 | `0.9` | Thistle Gate signpost |
| Ground cover (<1.2 m) | `assets/quaternius/stylized-nature-megakit/glTF/` (`Bush_Common`, `Bush_Common_Flowers`, `Fern_1`, `Flower_3_Group`, `Flower_4_Group`, `Grass_Wispy_Short`, `Mushroom_Common`) | Zones 1–4 | `0.36–1.55` | Low ground cover only (no pack trees/rocks) |
