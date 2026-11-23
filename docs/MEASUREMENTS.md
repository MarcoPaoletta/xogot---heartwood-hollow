# Pack measurements

Measured on 2026-11-21 in Blender 5.2 headless from the files in `assets/`, at rest pose, world space, in Godot axes (X, Y up, Z), in the units each file declares (Godot imports glTF meters as meters and FBX with its unit scale; check the root of each imported scene before scaling). `Size` is the bounding box of all meshes, `Bottom Y` the lowest point (0 means the feet or base sit on the origin), `Tris` all triangles, `Clips` the animation names stored in the file with their length. Measured, not read from a page.

Use these numbers to set instance scales. Keep every source file and its import settings unchanged (GDD Section 10).

## Traps found while measuring

* 79 files carry a loose `Icosphere` helper mesh at the origin (Ultimate Monsters and Cute Animated Monsters style). It is excluded from the sizes below. Hide it in the game.
* Ultimate Monsters `Big/` models are in T pose at rest: scale them by height, not width.
* RPG Character Pack characters measure about 3.0 m tall at rest (T pose): scale near 0.5 for a 1.5 m Wren. The pack ships two rigs: `glTF/` (its own clips) and `Humanoid Rig Versions/FBX/` (a humanoid rig meant for retargeting, use these with the Universal Animation Library).
* Universal Animation Library: `UAL1_Standard.glb` holds the clips; `_RM` is the root motion version.
* The free tiers have no well, no gate prop and no brazier: build the gate from Medieval Village `Wall_Arch` and wall pieces, build the brazier as `scenes/props/ruin_brazier.tscn` (a Ruins `Column_Round_Short` with the Medieval Village Pack `Bonfire` on top), and skip the well if nothing fits (it is not required by any acceptance test).
* Godot 4.7.2 headless import of every asset: exit 0, one engine message, `Condition "surfaces.is_empty()"` on `rpg-character-pack/Humanoid Rig Versions/FBX/Wizard.fbx` (an empty mesh node in that file; the model imports and the glTF version is clean). Log: `docs/evidence/setup-import-headless.txt`.
* Files of Modeler categories (trees, rocks, pebbles, weapons, shields, lanterns, torches, candles, pots, vases, bottles, potions, bridges) were removed from the packs at setup on purpose.

## quaternius/medieval-village-pack

1 file (added 2026-11-23, measured in Godot 4.7.2 headless).

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `FBX/Bonfire.fbx` | 0.407 x 0.112 x 0.362 | -0.033 | 602 | 0 |  |

## quaternius/survival-pack

1 file (added 2026-11-23, measured in Godot 4.7.2 headless). The bounding box includes the guy ropes, which reach far past the canvas along Z.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `FBX/Tent.fbx` | 14.58 x 10.324 x 24.868 | -0.176 | 788 | 0 |  |

## quaternius/ultimate-platformer-pack

1 file (added 2026-11-23, measured in Godot 4.7.2 headless).

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `glTF/Arrow_Side.gltf` | 1.86 x 2.052 x 0.363 | 0.0 | 120 | 0 |  |

## quaternius/cute-animated-monsters

20 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `glTF/Alien.gltf` | 2.189 x 2.068 x 1.417 | -0.026 | 1720 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Alien_Tall.gltf` | 2.029 x 2.118 x 1.575 | -0.042 | 1592 | 5 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Bat.gltf` | 3.206 x 1.754 x 1.417 | -0.023 | 1200 | 15 | Bite_Front(1.12s), Death(1.12s), Flying(1.12s), HitRecieve(1.12s) |
| `glTF/Bee.gltf` | 2.89 x 1.897 x 1.485 | -0.02 | 1492 | 9 | Bite_Front(1.12s), Death(0.79s), Flying(1.12s), HitRecieve(1.12s) |
| `glTF/Cactus.gltf` | 2.367 x 2.235 x 1.458 | -0.167 | 1500 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Chicken.gltf` | 2.269 x 1.624 x 1.555 | -0.028 | 1040 | 6 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Crab.gltf` | 2.567 x 1.577 x 1.417 | -0.029 | 1820 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Cthulhu.gltf` | 3.206 x 1.565 x 1.49 | -0.057 | 1576 | 16 | Bite_Front(1.12s), Death(1.12s), Flying(1.12s), HitRecieve(1.12s) |
| `glTF/Cyclops.gltf` | 1.637 x 1.678 x 1.473 | -0.031 | 972 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Deer.gltf` | 1.891 x 1.908 x 1.446 | -0.04 | 1180 | 5 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Demon.gltf` | 1.978 x 1.635 x 1.417 | -0.052 | 1640 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Ghost.gltf` | 1.452 x 1.408 x 1.462 | -0.005 | 1000 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/GreenDemon.gltf` | 1.684 x 1.635 x 1.417 | -0.044 | 1280 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Mushroom.gltf` | 1.923 x 2.081 x 1.925 | -0.022 | 868 | 5 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Panda.gltf` | 1.83 x 1.652 x 1.473 | -0.03 | 1428 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Penguin.gltf` | 2.269 x 1.624 x 1.555 | -0.028 | 1040 | 6 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Pig.gltf` | 1.902 x 1.653 x 1.891 | -0.167 | 1316 | 5 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/Skull.gltf` | 1.461 x 1.56 x 1.465 | -0.085 | 450 | 5 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |
| `glTF/YellowDragon.gltf` | 3.206 x 1.647 x 1.417 | -0.045 | 1592 | 17 | Bite_Front(1.12s), Death(1.12s), Flying(1.12s), HitRecieve(1.12s) |
| `glTF/Yeti.gltf` | 1.684 x 1.677 x 1.441 | -0.02 | 1292 | 7 | Bite_Front(0.5s), Bite_InPlace(0.67s), Dance(0.83s), Death(0.46s), HitRecieve(0.38s), Idle(2.5s), Jump(0.54s), No(0.5s), Walk(0.54s), Yes(0.5s) |

## quaternius/fantasy-props-megakit

68 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `glTF/Anvil.gltf` | 1.082 x 0.556 x 0.402 | 0.003 | 750 | 0 |  |
| `glTF/Anvil_Log.gltf` | 0.929 x 1.073 x 0.821 | 0.001 | 3808 | 0 |  |
| `glTF/Bag.gltf` | 0.655 x 0.799 x 0.544 | 0.002 | 858 | 0 |  |
| `glTF/Banner_1.gltf` | 1.613 x 2.392 x 0.191 | -1.549 | 448 | 0 |  |
| `glTF/Banner_1_Cloth.gltf` | 0.81 x 2.246 x 0.057 | -2.246 | 138 | 0 |  |
| `glTF/Banner_2.gltf` | 1.613 x 2.077 x 0.191 | -1.234 | 429 | 0 |  |
| `glTF/Banner_2_Cloth.gltf` | 0.81 x 1.931 x 0.057 | -1.931 | 119 | 0 |  |
| `glTF/Barrel.gltf` | 0.698 x 0.898 x 0.698 | 0.003 | 824 | 0 |  |
| `glTF/Barrel_Apples.gltf` | 0.698 x 0.898 x 0.698 | 0.003 | 2480 | 0 |  |
| `glTF/Barrel_Holder.gltf` | 1.359 x 1.257 x 0.741 | -0.006 | 2676 | 0 |  |
| `glTF/Bed_Twin1.gltf` | 1.876 x 0.805 x 2.412 | 0.0 | 1600 | 0 |  |
| `glTF/Bed_Twin2.gltf` | 1.876 x 0.76 x 2.412 | 0.0 | 1584 | 0 |  |
| `glTF/Bench.gltf` | 2.777 x 0.533 x 0.534 | -0.007 | 404 | 0 |  |
| `glTF/BookGroup_Medium_1.gltf` | 1.063 x 0.298 x 0.247 | -0.004 | 416 | 0 |  |
| `glTF/BookGroup_Medium_2.gltf` | 1.105 x 0.295 x 0.247 | -0.0 | 468 | 0 |  |
| `glTF/BookGroup_Medium_3.gltf` | 1.042 x 0.295 x 0.247 | -0.0 | 468 | 0 |  |
| `glTF/BookGroup_Small_1.gltf` | 0.289 x 0.298 x 0.226 | -0.005 | 104 | 0 |  |
| `glTF/BookGroup_Small_2.gltf` | 0.228 x 0.283 x 0.237 | -0.001 | 104 | 0 |  |
| `glTF/BookGroup_Small_3.gltf` | 0.245 x 0.277 x 0.237 | -0.001 | 130 | 0 |  |
| `glTF/BookStand.gltf` | 0.507 x 1.447 x 0.511 | -0.002 | 1526 | 0 |  |
| `glTF/Book_5.gltf` | 0.213 x 0.064 x 0.287 | -0.032 | 96 | 0 |  |
| `glTF/Book_7.gltf` | 0.247 x 0.068 x 0.333 | -0.034 | 724 | 0 |  |
| `glTF/Book_Simplified_Single.gltf` | 0.065 x 0.268 x 0.21 | -0.001 | 52 | 0 |  |
| `glTF/Book_Stack_1.gltf` | 0.285 x 0.214 x 0.226 | 0.001 | 208 | 0 |  |
| `glTF/Book_Stack_2.gltf` | 0.274 x 0.198 x 0.227 | -0.001 | 446 | 0 |  |
| `glTF/Bookcase_2.gltf` | 1.461 x 2.545 x 0.429 | -0.017 | 2148 | 0 |  |
| `glTF/Bucket_Metal.gltf` | 0.485 x 0.365 x 0.449 | -0.005 | 540 | 0 |  |
| `glTF/Bucket_Wooden_1.gltf` | 0.434 x 0.293 x 0.383 | 0.001 | 976 | 0 |  |
| `glTF/Cabinet.gltf` | 1.362 x 0.997 x 0.357 | 0.0 | 2388 | 0 |  |
| `glTF/Cage_Small.gltf` | 0.855 x 0.805 x 0.884 | -0.042 | 4588 | 0 |  |
| `glTF/Carrot.gltf` | 0.18 x 0.566 x 0.222 | -0.238 | 634 | 0 |  |
| `glTF/Chain_Coil.gltf` | 1.07 x 0.087 x 0.908 | 0.005 | 3744 | 0 |  |
| `glTF/Chair_1.gltf` | 0.581 x 1.123 x 0.549 | -0.003 | 496 | 0 |  |
| `glTF/Chalice.gltf` | 0.118 x 0.257 x 0.125 | -0.001 | 458 | 0 |  |
| `glTF/Chest_Wood.gltf` | 1.276 x 0.715 x 0.755 | -0.023 | 2546 | 3 | Chest_Close(0.47s), Chest_Closed(0.33s), Chest_Open(0.63s), Chest_Opened(0.33s) |
| `glTF/Coin.gltf` | 0.068 x 0.068 x 0.015 | -0.034 | 304 | 0 |  |
| `glTF/Coin_Pile.gltf` | 0.197 x 0.073 x 0.154 | -0.003 | 960 | 0 |  |
| `glTF/Coin_Pile_2.gltf` | 0.279 x 0.058 x 0.2 | 0.0 | 1062 | 0 |  |
| `glTF/Crate_Metal.gltf` | 0.864 x 0.868 x 0.866 | 0.003 | 2738 | 0 |  |
| `glTF/Crate_Wooden.gltf` | 0.842 x 0.931 x 0.908 | -0.052 | 1576 | 0 |  |
| `glTF/Dummy.gltf` | 0.809 x 1.863 x 0.585 | -0.003 | 2858 | 0 |  |
| `glTF/FarmCrate_Apple.gltf` | 0.714 x 0.244 x 0.414 | -0.016 | 4028 | 0 |  |
| `glTF/FarmCrate_Carrot.gltf` | 0.714 x 0.411 x 0.567 | -0.016 | 5262 | 0 |  |
| `glTF/FarmCrate_Empty.gltf` | 0.714 x 0.244 x 0.414 | -0.016 | 1928 | 0 |  |
| `glTF/Key_Gold.gltf` | 0.058 x 0.012 x 0.122 | -0.006 | 1366 | 0 |  |
| `glTF/Key_Metal.gltf` | 0.048 x 0.012 x 0.111 | -0.006 | 546 | 0 |  |
| `glTF/Mug.gltf` | 0.192 x 0.184 x 0.147 | -0.005 | 268 | 0 |  |
| `glTF/Nightstand_Shelf.gltf` | 0.693 x 1.216 x 0.393 | -0.006 | 262 | 0 |  |
| `glTF/Peg_Rack.gltf` | 1.184 x 0.348 x 0.096 | -0.174 | 712 | 0 |  |
| `glTF/Pouch_Large.gltf` | 0.225 x 0.159 x 0.12 | 0.001 | 730 | 0 |  |
| `glTF/Rope_1.gltf` | 0.557 x 0.098 x 0.606 | -0.027 | 1748 | 0 |  |
| `glTF/Rope_2.gltf` | 0.808 x 0.124 x 0.845 | -0.003 | 1460 | 0 |  |
| `glTF/Rope_3.gltf` | 1.228 x 0.102 x 0.951 | -0.027 | 1748 | 0 |  |
| `glTF/Scroll_1.gltf` | 0.244 x 0.059 x 0.063 | 0.001 | 512 | 0 |  |
| `glTF/Scroll_2.gltf` | 0.233 x 0.059 x 0.064 | 0.0 | 672 | 0 |  |
| `glTF/Shelf_Arch.gltf` | 1.245 x 1.589 x 0.312 | -0.614 | 1286 | 0 |  |
| `glTF/Shelf_Simple.gltf` | 1.184 x 0.309 x 0.292 | -0.201 | 480 | 0 |  |
| `glTF/Stall_Cart_Empty.gltf` | 3.021 x 2.632 x 1.06 | -0.004 | 3936 | 0 |  |
| `glTF/Stall_Empty.gltf` | 1.845 x 2.627 x 0.932 | -0.005 | 1496 | 0 |  |
| `glTF/Stool.gltf` | 0.475 x 0.589 x 0.475 | -0.006 | 152 | 0 |  |
| `glTF/Table_Fork.gltf` | 0.05 x 0.006 x 0.263 | -0.003 | 108 | 0 |  |
| `glTF/Table_Knife.gltf` | 0.042 x 0.006 x 0.287 | -0.003 | 54 | 0 |  |
| `glTF/Table_Large.gltf` | 2.848 x 0.813 x 1.097 | 0.001 | 986 | 0 |  |
| `glTF/Table_Plate.gltf` | 0.333 x 0.02 x 0.337 | -0.001 | 172 | 0 |  |
| `glTF/Table_Spoon.gltf` | 0.046 x 0.018 x 0.272 | -0.015 | 164 | 0 |  |
| `glTF/Whetstone.gltf` | 1.141 x 1.17 x 0.902 | 0.003 | 1100 | 0 |  |
| `glTF/Workbench.gltf` | 2.019 x 0.895 x 1.024 | 0.0 | 1368 | 0 |  |
| `glTF/Workbench_Drawers.gltf` | 0.423 x 0.242 x 0.299 | 0.884 | 364 | 0 |  |

## quaternius/medieval-village-megakit

176 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `glTF/Balcony_Cross_Corner.gltf` | 2.104 x 1.23 x 2.104 | -0.105 | 264 | 0 |  |
| `glTF/Balcony_Cross_Straight.gltf` | 2.0 x 1.23 x 0.206 | -0.105 | 132 | 0 |  |
| `glTF/Balcony_Simple_Corner.gltf` | 2.104 x 1.23 x 2.104 | -0.105 | 2240 | 0 |  |
| `glTF/Balcony_Simple_Straight.gltf` | 2.0 x 1.23 x 0.206 | -0.105 | 1120 | 0 |  |
| `glTF/Corner_ExteriorWide_Brick.gltf` | 0.712 x 3.043 x 0.756 | -0.019 | 2882 | 0 |  |
| `glTF/Corner_ExteriorWide_Wood.gltf` | 0.29 x 3.0 x 0.331 | -0.0 | 36 | 0 |  |
| `glTF/Corner_Exterior_Brick.gltf` | 0.531 x 3.016 x 0.576 | -0.007 | 3102 | 0 |  |
| `glTF/Corner_Exterior_TopDown.gltf` | 0.093 x 2.467 x 0.093 | 0.65 | 16 | 0 |  |
| `glTF/Corner_Exterior_TopOnly.gltf` | 0.093 x 0.234 x 0.093 | 2.883 | 8 | 0 |  |
| `glTF/Corner_Exterior_Wood.gltf` | 0.21 x 3.0 x 0.24 | -0.0 | 12 | 0 |  |
| `glTF/Corner_Interior_Big.gltf` | 0.333 x 3.0 x 0.368 | -0.0 | 24 | 0 |  |
| `glTF/Corner_Interior_Small.gltf` | 0.21 x 3.0 x 0.24 | -0.0 | 12 | 0 |  |
| `glTF/DoorFrame_Flat_Brick.gltf` | 1.575 x 2.376 x 0.494 | -0.002 | 1880 | 0 |  |
| `glTF/DoorFrame_Flat_WoodDark.gltf` | 1.574 x 2.312 x 0.388 | -0.009 | 56 | 0 |  |
| `glTF/DoorFrame_Round_Brick.gltf` | 1.603 x 2.586 x 0.477 | -0.002 | 2046 | 0 |  |
| `glTF/DoorFrame_Round_WoodDark.gltf` | 1.407 x 2.563 x 0.539 | -0.009 | 320 | 0 |  |
| `glTF/Door_1_Flat.gltf` | 1.118 x 2.1 x 0.121 | 0.035 | 314 | 0 |  |
| `glTF/Door_1_Round.gltf` | 1.12 x 2.318 x 0.121 | 0.033 | 470 | 0 |  |
| `glTF/Door_2_Flat.gltf` | 1.114 x 2.1 x 0.261 | 0.04 | 6032 | 0 |  |
| `glTF/Door_2_Round.gltf` | 1.115 x 2.327 x 0.261 | 0.028 | 6188 | 0 |  |
| `glTF/Door_4_Flat.gltf` | 1.118 x 2.092 x 0.209 | 0.035 | 1044 | 0 |  |
| `glTF/Door_4_Round.gltf` | 1.115 x 2.323 x 0.209 | 0.033 | 1228 | 0 |  |
| `glTF/Door_8_Flat.gltf` | 1.118 x 2.099 x 0.199 | 0.035 | 986 | 0 |  |
| `glTF/Door_8_Round.gltf` | 1.152 x 2.324 x 0.199 | 0.033 | 1142 | 0 |  |
| `glTF/Floor_Brick.gltf` | 2.0 x 0.02 x 2.0 | -0.01 | 4 | 0 |  |
| `glTF/Floor_RedBrick.gltf` | 2.0 x 0.02 x 2.0 | -0.01 | 4 | 0 |  |
| `glTF/Floor_UnevenBrick.gltf` | 2.0 x 0.02 x 2.0 | -0.01 | 4 | 0 |  |
| `glTF/Floor_WoodDark.gltf` | 2.0 x 0.02 x 2.0 | -0.01 | 32 | 0 |  |
| `glTF/Floor_WoodDark_Half1.gltf` | 1.0 x 0.02 x 2.0 | -0.01 | 32 | 0 |  |
| `glTF/Floor_WoodDark_Half2.gltf` | 1.0 x 0.02 x 2.0 | -0.01 | 32 | 0 |  |
| `glTF/Floor_WoodDark_Half3.gltf` | 2.0 x 0.02 x 1.0 | -0.01 | 16 | 0 |  |
| `glTF/Floor_WoodDark_OverhangCorner.gltf` | 1.0 x 0.02 x 1.756 | -0.01 | 16 | 0 |  |
| `glTF/Floor_WoodDark_OverhangCorner2.gltf` | 0.957 x 0.02 x 1.75 | -0.01 | 26 | 0 |  |
| `glTF/Floor_WoodLight.gltf` | 2.0 x 0.02 x 2.0 | -0.01 | 32 | 0 |  |
| `glTF/Floor_WoodLight_OverhangCorner.gltf` | 1.0 x 0.02 x 1.756 | -0.01 | 16 | 0 |  |
| `glTF/Floor_WoodLight_OverhangCorner2.gltf` | 0.957 x 0.02 x 1.75 | -0.01 | 26 | 0 |  |
| `glTF/HoleCover_90Angle.gltf` | 2.12 x 0.21 x 2.12 | -0.105 | 20 | 0 |  |
| `glTF/HoleCover_90Half.gltf` | 1.12 x 0.21 x 1.12 | -0.105 | 16 | 0 |  |
| `glTF/HoleCover_90Stairs.gltf` | 0.324 x 0.21 x 2.12 | -0.105 | 18 | 0 |  |
| `glTF/HoleCover_Straight.gltf` | 2.0 x 0.21 x 0.24 | -0.105 | 12 | 0 |  |
| `glTF/HoleCover_StraightHalf.gltf` | 1.0 x 0.21 x 0.24 | -0.105 | 10 | 0 |  |
| `glTF/Overhang_Plaster_Corner.gltf` | 3.101 x 3.117 x 3.101 | 0.0 | 440 | 0 |  |
| `glTF/Overhang_Plaster_Corner_Front.gltf` | 3.118 x 3.14 x 3.118 | -0.023 | 142 | 0 |  |
| `glTF/Overhang_Plaster_Long.gltf` | 2.0 x 3.028 x 2.2 | 0.0 | 204 | 0 |  |
| `glTF/Overhang_Plaster_Short.gltf` | 2.0 x 3.123 x 1.323 | 0.0 | 222 | 0 |  |
| `glTF/Overhang_RoofIncline_Plaster.gltf` | 2.0 x 0.266 x 1.43 | -0.324 | 36 | 0 |  |
| `glTF/Overhang_RoofIncline_UnevenBricks.gltf` | 2.0 x 0.266 x 1.43 | -0.324 | 36 | 0 |  |
| `glTF/Overhang_Roof_Plaster.gltf` | 2.0 x 0.266 x 2.022 | -0.324 | 38 | 0 |  |
| `glTF/Overhang_Roof_UnevenBricks.gltf` | 2.0 x 0.266 x 2.022 | -0.324 | 38 | 0 |  |
| `glTF/Overhang_Side_Plaster_Long_L.gltf` | 0.479 x 6.117 x 2.314 | -0.0 | 314 | 0 |  |
| `glTF/Overhang_Side_Plaster_Long_R.gltf` | 0.479 x 6.117 x 2.314 | -0.0 | 314 | 0 |  |
| `glTF/Overhang_Side_Plaster_Short_L.gltf` | 0.479 x 6.117 x 1.437 | -0.0 | 302 | 0 |  |
| `glTF/Overhang_Side_Plaster_Short_R.gltf` | 0.479 x 6.117 x 1.437 | -0.0 | 302 | 0 |  |
| `glTF/Overhang_Side_UnevenBrick_Long_L.gltf` | 0.479 x 6.117 x 2.314 | -0.0 | 292 | 0 |  |
| `glTF/Overhang_Side_UnevenBrick_Long_R.gltf` | 0.479 x 6.117 x 2.314 | -0.0 | 292 | 0 |  |
| `glTF/Overhang_Side_UnevenBrick_Short_L.gltf` | 0.479 x 6.117 x 1.437 | -0.0 | 294 | 0 |  |
| `glTF/Overhang_Side_UnevenBrick_Short_R.gltf` | 0.479 x 6.117 x 1.437 | -0.0 | 294 | 0 |  |
| `glTF/Overhang_UnevenBrick_Corner.gltf` | 3.101 x 3.117 x 3.101 | 0.0 | 420 | 0 |  |
| `glTF/Overhang_UnevenBrick_Corner_Front.gltf` | 3.118 x 3.117 x 3.118 | 0.0 | 60 | 0 |  |
| `glTF/Overhang_UnevenBrick_Long.gltf` | 2.0 x 3.028 x 2.2 | 0.0 | 196 | 0 |  |
| `glTF/Overhang_UnevenBrick_Short.gltf` | 2.0 x 3.123 x 1.323 | 0.0 | 214 | 0 |  |
| `glTF/Prop_Brick1.gltf` | 0.346 x 0.208 x 0.25 | -0.11 | 108 | 0 |  |
| `glTF/Prop_Brick2.gltf` | 0.395 x 0.245 x 0.217 | -0.112 | 94 | 0 |  |
| `glTF/Prop_Brick3.gltf` | 0.381 x 0.25 x 0.216 | -0.115 | 126 | 0 |  |
| `glTF/Prop_Brick4.gltf` | 0.257 x 0.25 x 0.216 | -0.115 | 126 | 0 |  |
| `glTF/Prop_Chimney.gltf` | 0.946 x 3.178 x 1.0 | 0.0 | 618 | 0 |  |
| `glTF/Prop_Chimney2.gltf` | 0.946 x 3.0 x 0.988 | 0.0 | 130 | 0 |  |
| `glTF/Prop_Crate.gltf` | 1.084 x 1.06 x 1.084 | 0.003 | 230 | 0 |  |
| `glTF/Prop_ExteriorBorder_Corner.gltf` | 0.7 x 0.134 x 0.7 | 0.0 | 18 | 0 |  |
| `glTF/Prop_ExteriorBorder_Straight1.gltf` | 2.0 x 0.134 x 0.7 | 0.0 | 16 | 0 |  |
| `glTF/Prop_ExteriorBorder_Straight2.gltf` | 2.0 x 0.134 x 0.7 | 0.0 | 16 | 0 |  |
| `glTF/Prop_MetalFence_Ornament.gltf` | 1.952 x 2.852 x 0.156 | -0.0 | 3988 | 0 |  |
| `glTF/Prop_MetalFence_Simple.gltf` | 1.949 x 2.868 x 0.156 | -0.0 | 2744 | 0 |  |
| `glTF/Prop_Support.gltf` | 0.199 x 1.709 x 2.036 | 1.211 | 16 | 0 |  |
| `glTF/Prop_Vine1.gltf` | 1.536 x 2.603 x 0.219 | -2.121 | 82 | 0 |  |
| `glTF/Prop_Vine2.gltf` | 1.386 x 2.603 x 0.214 | -2.121 | 45 | 0 |  |
| `glTF/Prop_Vine4.gltf` | 1.017 x 1.588 x 0.15 | -1.014 | 31 | 0 |  |
| `glTF/Prop_Vine5.gltf` | 2.301 x 2.986 x 1.126 | -1.955 | 117 | 0 |  |
| `glTF/Prop_Vine6.gltf` | 4.137 x 2.468 x 1.47 | -1.072 | 114 | 0 |  |
| `glTF/Prop_Vine9.gltf` | 4.137 x 1.467 x 1.47 | -0.633 | 44 | 0 |  |
| `glTF/Prop_Wagon.gltf` | 1.951 x 1.529 x 4.024 | 0.003 | 1672 | 0 |  |
| `glTF/Prop_WoodenFence_Extension1.gltf` | 2.045 x 0.838 x 0.11 | -0.028 | 32 | 0 |  |
| `glTF/Prop_WoodenFence_Extension2.gltf` | 2.027 x 0.838 x 0.11 | -0.028 | 28 | 0 |  |
| `glTF/Prop_WoodenFence_Single.gltf` | 2.064 x 0.838 x 0.12 | -0.028 | 40 | 0 |  |
| `glTF/Roof_2x4_RoundTile.gltf` | 3.293 x 2.666 x 4.232 | -0.342 | 1112 | 0 |  |
| `glTF/Roof_Dormer_RoundTile.gltf` | 1.966 x 2.673 x 2.439 | 0.03 | 904 | 0 |  |
| `glTF/Roof_FrontSupports.gltf` | 5.486 x 0.231 x 0.655 | -0.118 | 60 | 0 |  |
| `glTF/Roof_Front_Brick2.gltf` | 2.607 x 1.775 x 0.751 | -0.133 | 78 | 0 |  |
| `glTF/Roof_Front_Brick4.gltf` | 4.4 x 3.069 x 1.129 | -0.132 | 252 | 0 |  |
| `glTF/Roof_Front_Brick4_Half_L.gltf` | 2.41 x 3.197 x 0.49 | -0.132 | 140 | 0 |  |
| `glTF/Roof_Front_Brick4_Half_R.gltf` | 2.416 x 3.197 x 0.49 | -0.132 | 146 | 0 |  |
| `glTF/Roof_Front_Brick6.gltf` | 6.694 x 4.516 x 1.129 | -0.132 | 328 | 0 |  |
| `glTF/Roof_Front_Brick6_Half_L.gltf` | 3.414 x 4.516 x 0.49 | -0.132 | 186 | 0 |  |
| `glTF/Roof_Front_Brick6_Half_R.gltf` | 3.4 x 4.516 x 0.49 | -0.132 | 186 | 0 |  |
| `glTF/Roof_Front_Brick8.gltf` | 8.511 x 5.446 x 1.129 | -0.132 | 364 | 0 |  |
| `glTF/Roof_Front_Brick8_Half_L.gltf` | 4.327 x 5.446 x 0.49 | -0.132 | 204 | 0 |  |
| `glTF/Roof_Front_Brick8_Half_R.gltf` | 4.349 x 5.446 x 0.49 | -0.132 | 204 | 0 |  |
| `glTF/Roof_Log.gltf` | 1.149 x 1.387 x 10.696 | 3.849 | 164 | 0 |  |
| `glTF/Roof_Modular_RoundTiles.gltf` | 0.663 x 0.505 x 2.252 | 0.006 | 136 | 0 |  |
| `glTF/Roof_RoundTile_2x1.gltf` | 3.297 x 2.659 x 1.952 | -0.342 | 612 | 0 |  |
| `glTF/Roof_RoundTile_2x1_Long.gltf` | 4.347 x 3.325 x 1.952 | -1.008 | 628 | 0 |  |
| `glTF/Roof_RoundTiles_4x4.gltf` | 5.513 x 4.249 x 5.561 | -0.516 | 1996 | 0 |  |
| `glTF/Roof_RoundTiles_4x6.gltf` | 5.513 x 4.234 x 7.572 | -0.516 | 2520 | 0 |  |
| `glTF/Roof_RoundTiles_4x8.gltf` | 5.513 x 4.229 x 9.683 | -0.516 | 3116 | 0 |  |
| `glTF/Roof_RoundTiles_6x10.gltf` | 8.25 x 5.672 x 11.852 | -0.782 | 4300 | 0 |  |
| `glTF/Roof_RoundTiles_6x12.gltf` | 8.25 x 5.672 x 13.658 | -0.782 | 4752 | 0 |  |
| `glTF/Roof_RoundTiles_6x14.gltf` | 8.25 x 5.672 x 15.706 | -0.782 | 5372 | 0 |  |
| `glTF/Roof_RoundTiles_6x4.gltf` | 8.25 x 5.672 x 4.992 | -0.782 | 2192 | 0 |  |
| `glTF/Roof_RoundTiles_6x6.gltf` | 8.25 x 5.672 x 8.032 | -0.782 | 3244 | 0 |  |
| `glTF/Roof_RoundTiles_6x8.gltf` | 8.25 x 5.672 x 9.683 | -0.782 | 3796 | 0 |  |
| `glTF/Roof_RoundTiles_8x10.gltf` | 9.952 x 6.781 x 11.859 | -0.78 | 4480 | 0 |  |
| `glTF/Roof_RoundTiles_8x12.gltf` | 9.952 x 6.781 x 14.132 | -0.78 | 6356 | 0 |  |
| `glTF/Roof_RoundTiles_8x14.gltf` | 9.952 x 6.781 x 15.706 | -0.78 | 5484 | 0 |  |
| `glTF/Roof_RoundTiles_8x8.gltf` | 9.952 x 6.781 x 10.332 | -0.78 | 3888 | 0 |  |
| `glTF/Roof_Support2.gltf` | 0.2 x 0.743 x 0.765 | -0.677 | 84 | 0 |  |
| `glTF/Roof_Tower_RoundTiles.gltf` | 5.651 x 7.361 x 5.427 | -0.572 | 4024 | 0 |  |
| `glTF/Roof_Wooden_2x1.gltf` | 2.258 x 1.248 x 1.56 | -0.161 | 224 | 0 |  |
| `glTF/Roof_Wooden_2x1_Center.gltf` | 2.0 x 1.208 x 1.499 | -0.145 | 52 | 0 |  |
| `glTF/Roof_Wooden_2x1_Center_Mirror.gltf` | 2.0 x 1.208 x 1.499 | -0.145 | 52 | 0 |  |
| `glTF/Roof_Wooden_2x1_Corner.gltf` | 1.544 x 1.183 x 1.557 | -0.169 | 82 | 0 |  |
| `glTF/Roof_Wooden_2x1_L.gltf` | 2.129 x 1.248 x 1.56 | -0.161 | 158 | 0 |  |
| `glTF/Roof_Wooden_2x1_Middle.gltf` | 2.0 x 0.138 x 2.0 | 0.924 | 24 | 0 |  |
| `glTF/Roof_Wooden_2x1_R.gltf` | 2.129 x 1.248 x 1.56 | -0.161 | 158 | 0 |  |
| `glTF/Stair_Interior_Rails.gltf` | 1.717 x 3.931 x 4.563 | 0.023 | 3144 | 0 |  |
| `glTF/Stair_Interior_Simple.gltf` | 1.676 x 3.035 x 4.62 | -0.01 | 208 | 0 |  |
| `glTF/Stair_Interior_Solid.gltf` | 1.769 x 3.046 x 4.71 | -0.018 | 306 | 0 |  |
| `glTF/Stair_Interior_SolidExtended.gltf` | 1.769 x 3.046 x 6.158 | -0.018 | 376 | 0 |  |
| `glTF/Stairs_Exterior_NoFirstStep.gltf` | 2.0 x 1.0 x 2.077 | -0.0 | 52 | 0 |  |
| `glTF/Stairs_Exterior_Platform.gltf` | 2.0 x 1.0 x 2.001 | -0.0 | 32 | 0 |  |
| `glTF/Stairs_Exterior_Platform45.gltf` | 2.001 x 1.0 x 2.001 | -0.0 | 55 | 0 |  |
| `glTF/Stairs_Exterior_Platform45Clean.gltf` | 2.0 x 1.0 x 2.001 | -0.0 | 45 | 0 |  |
| `glTF/Stairs_Exterior_PlatformU.gltf` | 2.0 x 1.0 x 2.001 | -0.0 | 68 | 0 |  |
| `glTF/Stairs_Exterior_SidePlatform.gltf` | 2.0 x 1.0 x 2.001 | -0.0 | 30 | 0 |  |
| `glTF/Stairs_Exterior_Sides.gltf` | 2.0 x 1.0 x 2.0 | -0.0 | 16 | 0 |  |
| `glTF/Stairs_Exterior_Sides45.gltf` | 2.0 x 1.0 x 2.0 | -0.0 | 28 | 0 |  |
| `glTF/Stairs_Exterior_SidesU.gltf` | 2.0 x 1.0 x 2.0 | -0.0 | 56 | 0 |  |
| `glTF/Stairs_Exterior_SingleSide.gltf` | 0.2 x 1.0 x 2.0 | 0.0 | 12 | 0 |  |
| `glTF/Stairs_Exterior_SingleSideThick.gltf` | 0.4 x 1.0 x 2.0 | 0.0 | 12 | 0 |  |
| `glTF/Stairs_Exterior_Straight.gltf` | 2.0 x 1.204 x 2.078 | -0.204 | 62 | 0 |  |
| `glTF/Stairs_Exterior_Straight_Center.gltf` | 2.0 x 1.022 x 2.078 | -0.204 | 50 | 0 |  |
| `glTF/Stairs_Exterior_Straight_L.gltf` | 2.0 x 1.204 x 2.078 | -0.204 | 56 | 0 |  |
| `glTF/Stairs_Exterior_Straight_R.gltf` | 2.0 x 1.204 x 2.078 | -0.204 | 56 | 0 |  |
| `glTF/Wall_Arch.gltf` | 2.0 x 3.0 x 0.064 | -0.0 | 196 | 0 |  |
| `glTF/Wall_BottomCover.gltf` | 2.0 x 0.238 x 0.432 | -0.117 | 36 | 0 |  |
| `glTF/Wall_Plaster_Door_Flat.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 92 | 0 |  |
| `glTF/Wall_Plaster_Door_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 137 | 0 |  |
| `glTF/Wall_Plaster_Door_RoundInset.gltf` | 2.0 x 3.123 x 1.092 | -0.0 | 180 | 0 |  |
| `glTF/Wall_Plaster_Straight.gltf` | 2.0 x 3.125 x 0.406 | -0.002 | 86 | 0 |  |
| `glTF/Wall_Plaster_Straight_Base.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 64 | 0 |  |
| `glTF/Wall_Plaster_Straight_L.gltf` | 2.002 x 3.123 x 0.406 | 0.0 | 72 | 0 |  |
| `glTF/Wall_Plaster_Straight_R.gltf` | 2.002 x 3.123 x 0.406 | 0.0 | 72 | 0 |  |
| `glTF/Wall_Plaster_Window_Thin_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 166 | 0 |  |
| `glTF/Wall_Plaster_Window_Wide_Flat.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 96 | 0 |  |
| `glTF/Wall_Plaster_Window_Wide_Flat2.gltf` | 2.0 x 3.146 x 0.406 | -0.023 | 122 | 0 |  |
| `glTF/Wall_Plaster_Window_Wide_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 124 | 0 |  |
| `glTF/Wall_Plaster_WoodGrid.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 248 | 0 |  |
| `glTF/Wall_UnevenBrick_Door_Flat.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 74 | 0 |  |
| `glTF/Wall_UnevenBrick_Door_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 136 | 0 |  |
| `glTF/Wall_UnevenBrick_Straight.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 56 | 0 |  |
| `glTF/Wall_UnevenBrick_Window_Thin_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 158 | 0 |  |
| `glTF/Wall_UnevenBrick_Window_Wide_Flat.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 88 | 0 |  |
| `glTF/Wall_UnevenBrick_Window_Wide_Round.gltf` | 2.0 x 3.123 x 0.406 | 0.0 | 116 | 0 |  |
| `glTF/WindowShutters_Thin_Flat_Closed.gltf` | 0.852 x 1.424 x 0.136 | 1.093 | 96 | 0 |  |
| `glTF/WindowShutters_Thin_Flat_Open.gltf` | 1.354 x 1.424 x 0.377 | 1.093 | 96 | 0 |  |
| `glTF/WindowShutters_Thin_Round_Closed.gltf` | 0.867 x 1.518 x 0.136 | 1.093 | 112 | 0 |  |
| `glTF/WindowShutters_Thin_Round_Open.gltf` | 1.606 x 1.518 x 0.376 | 1.093 | 112 | 0 |  |
| `glTF/WindowShutters_Wide_Flat_Closed.gltf` | 1.347 x 1.424 x 0.136 | 1.093 | 120 | 0 |  |
| `glTF/WindowShutters_Wide_Flat_Open.gltf` | 2.481 x 1.424 x 0.457 | 1.093 | 120 | 0 |  |
| `glTF/WindowShutters_Wide_Round_Closed.gltf` | 1.347 x 1.647 x 0.136 | 1.093 | 136 | 0 |  |
| `glTF/WindowShutters_Wide_Round_Open.gltf` | 2.303 x 1.647 x 0.472 | 1.093 | 136 | 0 |  |
| `glTF/Window_Roof_Thin.gltf` | 0.852 x 1.177 x 1.179 | 1.338 | 46 | 0 |  |
| `glTF/Window_Roof_Wide.gltf` | 1.416 x 1.181 x 1.179 | 1.338 | 66 | 0 |  |
| `glTF/Window_Thin_Flat1.gltf` | 0.788 x 1.558 x 0.436 | 0.975 | 112 | 0 |  |
| `glTF/Window_Thin_Round1.gltf` | 0.888 x 1.605 x 0.344 | 1.016 | 418 | 0 |  |
| `glTF/Window_Wide_Flat1.gltf` | 1.608 x 1.58 x 0.683 | 0.944 | 160 | 0 |  |
| `glTF/Window_Wide_Round1.gltf` | 1.365 x 1.726 x 0.53 | 1.016 | 354 | 0 |  |

## quaternius/rpg-character-pack

12 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `Humanoid Rig Versions/FBX/Cleric.fbx` | 3.065 x 2.992 x 1.078 | -0.003 | 3400 | 38 |  |
| `Humanoid Rig Versions/FBX/Monk.fbx` | 3.276 x 2.948 x 0.838 | 0.0 | 6714 | 38 |  |
| `Humanoid Rig Versions/FBX/Ranger.fbx` | 3.031 x 2.957 x 0.891 | 0.0 | 2526 | 38 |  |
| `Humanoid Rig Versions/FBX/Rogue.fbx` | 3.098 x 3.007 x 1.004 | -0.003 | 1658 | 38 |  |
| `Humanoid Rig Versions/FBX/Warrior.fbx` | 3.044 x 2.942 x 1.15 | -0.003 | 4690 | 38 |  |
| `Humanoid Rig Versions/FBX/Wizard.fbx` | 3.052 x 3.078 x 1.098 | -0.003 | 4090 | 38 |  |
| `glTF/Cleric.gltf` | 3.187 x 2.992 x 2.44 | -0.003 | 5104 | 32 | Death(1.17s), Idle(3.12s), Idle_Weapon(3.12s), PickUp(1.25s), Punch(0.75s), RecieveHit(0.62s), RecieveHit_Attacking(0.62s), Run(0.88s), Spell1(1.21s), Staff_Attack(0.75s), Walk(1.25s) |
| `glTF/Monk.gltf` | 3.276 x 2.948 x 0.838 | 0.0 | 6714 | 32 | Attack(0.83s), Attack2(0.83s), Death(1.17s), Idle(3.12s), Idle_Attacking(1.67s), PickUp(1.25s), RecieveHit(0.62s), RecieveHit_2(0.62s), Roll(1.0s), Run(0.88s), Walk(1.25s) |
| `glTF/Ranger.gltf` | 3.102 x 2.957 x 2.157 | 0.0 | 3806 | 32 | Bow_Draw(1.25s), Bow_Shoot(0.62s), Death(1.17s), Idle(3.12s), Idle_Attacking(1.67s), Idle_Weapon(3.12s), PickUp(1.25s), Punch(0.75s), RecieveHit(0.62s), RecieveHit_2(0.62s), Roll(1.0s), Run(0.88s), Run_Holding(0.88s), Walk(1.25s) |
| `glTF/Rogue.gltf` | 3.098 x 3.007 x 1.686 | -0.003 | 2326 | 32 | Attacking_Idle(1.67s), Dagger_Attack(0.75s), Dagger_Attack2(1.25s), Death(1.17s), Idle(3.12s), PickUp(1.25s), Punch(0.75s), RecieveHit(0.62s), RecieveHit_2(0.62s), Roll(1.0s), Run(0.88s), Walk(1.25s) |
| `glTF/Warrior.gltf` | 3.044 x 2.942 x 2.493 | -0.003 | 5402 | 32 | Death(1.17s), Idle(3.12s), Idle_Attacking(1.67s), Idle_Weapon(3.12s), PickUp(1.25s), Punch(0.75s), RecieveHit(0.62s), Roll(1.0s), Run(0.88s), Run_Weapon(0.88s), Sword_Attack(0.83s), Sword_Attack2(0.83s), Walk(1.25s) |
| `glTF/Wizard.gltf` | 3.052 x 3.078 x 2.153 | -0.003 | 5376 | 32 | Death(1.17s), Idle(3.12s), Idle_Attacking(1.67s), Idle_Weapon(3.12s), PickUp(1.25s), Punch(0.75s), RecieveHit(0.62s), RecieveHit_2(0.62s), Roll(1.0s), Run(0.88s), Run_Weapon(0.88s), Spell1(1.21s), Spell2(1.46s), Staff_Attack(0.75s), Walk(1.25s) |

## quaternius/stylized-nature-megakit

24 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `glTF/Bush_Common.gltf` | 1.915 x 1.582 x 1.965 | -0.235 | 900 | 0 |  |
| `glTF/Bush_Common_Flowers.gltf` | 1.915 x 1.582 x 1.965 | -0.235 | 1368 | 0 |  |
| `glTF/Clover_1.gltf` | 0.796 x 1.145 x 0.764 | -0.013 | 379 | 0 |  |
| `glTF/Clover_2.gltf` | 0.851 x 1.264 x 0.837 | -0.002 | 615 | 0 |  |
| `glTF/Fern_1.gltf` | 2.827 x 0.84 x 2.652 | -0.077 | 288 | 0 |  |
| `glTF/Flower_3_Group.gltf` | 1.488 x 2.055 x 1.591 | -0.035 | 755 | 0 |  |
| `glTF/Flower_3_Single.gltf` | 0.907 x 2.068 x 0.878 | -0.018 | 285 | 0 |  |
| `glTF/Flower_4_Group.gltf` | 1.781 x 2.487 x 1.368 | -0.057 | 1690 | 0 |  |
| `glTF/Flower_4_Single.gltf` | 1.072 x 2.419 x 0.773 | -0.03 | 642 | 0 |  |
| `glTF/Grass_Common_Short.gltf` | 0.639 x 1.334 x 0.737 | -0.022 | 155 | 0 |  |
| `glTF/Grass_Common_Tall.gltf` | 0.895 x 1.873 x 0.993 | -0.031 | 326 | 0 |  |
| `glTF/Grass_Wispy_Short.gltf` | 1.322 x 1.072 x 1.21 | -0.086 | 494 | 0 |  |
| `glTF/Grass_Wispy_Tall.gltf` | 1.54 x 1.672 x 1.594 | -0.036 | 622 | 0 |  |
| `glTF/Mushroom_Common.gltf` | 0.564 x 0.463 x 0.779 | -0.017 | 880 | 0 |  |
| `glTF/Mushroom_Laetiporus.gltf` | 1.366 x 0.767 x 1.103 | -0.16 | 3216 | 0 |  |
| `glTF/Petal_1.gltf` | 0.46 x 0.244 x 0.455 | 0.0 | 13 | 0 |  |
| `glTF/Petal_2.gltf` | 0.673 x 0.236 x 0.631 | 0.0 | 15 | 0 |  |
| `glTF/Petal_3.gltf` | 0.619 x 0.189 x 0.606 | 0.0 | 15 | 0 |  |
| `glTF/Petal_4.gltf` | 0.329 x 0.252 x 0.244 | -0.0 | 30 | 0 |  |
| `glTF/Petal_5.gltf` | 0.834 x 0.289 x 0.795 | 0.001 | 15 | 0 |  |
| `glTF/Plant_1.gltf` | 1.273 x 1.014 x 1.386 | -0.035 | 120 | 0 |  |
| `glTF/Plant_1_Big.gltf` | 1.807 x 2.348 x 1.954 | -0.035 | 360 | 0 |  |
| `glTF/Plant_7.gltf` | 1.048 x 0.25 x 0.962 | 0.079 | 48 | 0 |  |
| `glTF/Plant_7_Big.gltf` | 1.311 x 0.253 x 1.362 | 0.05 | 112 | 0 |  |

## quaternius/ultimate-modular-ruins

56 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `FBX/Arch_Gothic.fbx` | 3.092 x 3.76 x 0.491 | -0.0 | 2904 | 0 |  |
| `FBX/Arch_Gothic_RoundColumn.fbx` | 3.092 x 3.759 x 0.489 | 0.002 | 3224 | 0 |  |
| `FBX/Arch_Round.fbx` | 3.092 x 3.533 x 0.491 | -0.0 | 2956 | 0 |  |
| `FBX/Arch_Round_RoundColumn.fbx` | 3.092 x 3.531 x 0.489 | 0.002 | 3276 | 0 |  |
| `FBX/Brick.fbx` | 0.53 x 0.319 x 0.285 | -0.002 | 76 | 0 |  |
| `FBX/Bricks.fbx` | 1.824 x 0.546 x 1.61 | -0.002 | 312 | 0 |  |
| `FBX/Column_Round.fbx` | 0.657 x 3.99 x 0.657 | -0.0 | 1010 | 0 |  |
| `FBX/Column_Round_Short.fbx` | 0.489 x 1.83 x 0.489 | -0.0 | 634 | 0 |  |
| `FBX/Column_Square.fbx` | 0.657 x 3.99 x 0.657 | -0.0 | 690 | 0 |  |
| `FBX/Curve_1.fbx` | 2.275 x 1.997 x 2.069 | -0.002 | 2302 | 0 |  |
| `FBX/Curve_1_Overgrown.fbx` | 2.305 x 2.001 x 2.069 | -0.002 | 2444 | 0 |  |
| `FBX/Curve_2.fbx` | 2.275 x 1.997 x 2.069 | -0.002 | 2302 | 0 |  |
| `FBX/Curve_2_Overgrown.fbx` | 2.305 x 2.001 x 2.069 | -0.002 | 2444 | 0 |  |
| `FBX/Doors_GothicArch.fbx` | 2.313 x 3.21 x 0.274 | -0.006 | 2184 | 0 |  |
| `FBX/Doors_GothicArch_Covered.fbx` | 2.523 x 3.21 x 0.279 | -0.006 | 2096 | 0 |  |
| `FBX/Doors_RoundArch.fbx` | 2.313 x 2.969 x 0.274 | -0.006 | 2184 | 0 |  |
| `FBX/Doors_RoundArch_Covered.fbx` | 2.523 x 2.969 x 0.279 | -0.006 | 2096 | 0 |  |
| `FBX/Flag_GothicArch.fbx` | 2.188 x 1.216 x 0.316 | 2.25 | 144 | 0 |  |
| `FBX/Flag_RoundArch.fbx` | 2.169 x 1.127 x 0.316 | 2.25 | 132 | 0 |  |
| `FBX/Flag_Wall.fbx` | 0.923 x 2.018 x 0.316 | -0.033 | 204 | 0 |  |
| `FBX/Flag_Wall2.fbx` | 1.127 x 2.354 x 0.322 | -2.307 | 368 | 0 |  |
| `FBX/Floor_Diamond.fbx` | 2.0 x 0.118 x 2.0 | -0.102 | 400 | 0 |  |
| `FBX/Floor_Hole_Corner.fbx` | 1.995 x 0.143 x 1.997 | -0.082 | 327 | 0 |  |
| `FBX/Floor_Hole_Straight.fbx` | 2.0 x 0.143 x 1.104 | -0.082 | 227 | 0 |  |
| `FBX/Floor_SquareLarge.fbx` | 1.979 x 0.108 x 1.98 | -0.081 | 118 | 0 |  |
| `FBX/Floor_Squares.fbx` | 1.992 x 0.116 x 1.996 | -0.082 | 413 | 0 |  |
| `FBX/Floor_Standard.fbx` | 1.99 x 0.286 x 1.977 | -0.253 | 1304 | 0 |  |
| `FBX/Floor_Standard_Half.fbx` | 1.996 x 0.116 x 1.999 | -0.082 | 821 | 0 |  |
| `FBX/Rail_Corner.fbx` | 1.168 x 0.488 x 1.168 | -0.003 | 468 | 0 |  |
| `FBX/Rail_Divider.fbx` | 0.363 x 0.488 x 0.363 | -0.003 | 208 | 0 |  |
| `FBX/Rail_Straight.fbx` | 0.363 x 0.488 x 2.0 | -0.003 | 428 | 0 |  |
| `FBX/Stairs.fbx` | 2.015 x 0.922 x 2.152 | -0.019 | 2272 | 0 |  |
| `FBX/Stairs_2.fbx` | 2.152 x 1.782 x 2.015 | -0.003 | 2072 | 0 |  |
| `FBX/Statue_Fox.fbx` | 1.351 x 3.752 x 1.679 | -0.0 | 2152 | 0 |  |
| `FBX/Statue_Stag.fbx` | 2.307 x 4.634 x 1.272 | -0.0 | 4042 | 0 |  |
| `FBX/Support_Center.fbx` | 3.0 x 4.11 x 0.665 | -0.0 | 4432 | 0 |  |
| `FBX/Support_Left.fbx` | 1.645 x 4.096 x 0.659 | -0.0 | 3570 | 0 |  |
| `FBX/Support_Right.fbx` | 1.645 x 4.096 x 0.659 | -0.0 | 3570 | 0 |  |
| `FBX/Support_Tall.fbx` | 0.795 x 4.122 x 0.654 | -0.0 | 674 | 0 |  |
| `FBX/Wall.fbx` | 1.998 x 2.001 x 0.286 | -0.001 | 1296 | 0 |  |
| `FBX/Wall_ArchGothic.fbx` | 4.004 x 3.994 x 0.286 | 0.003 | 2352 | 0 |  |
| `FBX/Wall_ArchRound.fbx` | 4.004 x 3.994 x 0.31 | 0.003 | 2364 | 0 |  |
| `FBX/Wall_ArchRound_Broken.fbx` | 3.993 x 3.985 x 0.31 | 0.003 | 1604 | 0 |  |
| `FBX/Wall_ArchRound_Overgrown.fbx` | 4.004 x 3.994 x 0.316 | 0.003 | 2602 | 0 |  |
| `FBX/Wall_ArchRound_Overgrown_Broken.fbx` | 3.993 x 3.985 x 0.316 | 0.003 | 1826 | 0 |  |
| `FBX/Wall_Broken.fbx` | 1.99 x 1.947 x 0.286 | 0.013 | 976 | 0 |  |
| `FBX/Wall_Double_Broken.fbx` | 1.99 x 0.987 x 0.566 | 0.003 | 856 | 0 |  |
| `FBX/Wall_Double_Hole.fbx` | 1.994 x 1.976 x 0.565 | 0.003 | 1880 | 0 |  |
| `FBX/Wall_Half.fbx` | 0.996 x 2.001 x 0.286 | -0.001 | 632 | 0 |  |
| `FBX/Wall_Hole.fbx` | 1.998 x 2.001 x 0.286 | 0.035 | 912 | 0 |  |
| `FBX/Wall_Overgrown.fbx` | 1.99 x 1.985 x 0.304 | 0.013 | 1370 | 0 |  |
| `FBX/Window_Bars.fbx` | 1.99 x 1.987 x 0.303 | 0.002 | 1222 | 0 |  |
| `FBX/Window_Bars_Double_Overgrown.fbx` | 2.009 x 3.987 x 0.31 | 0.002 | 2192 | 0 |  |
| `FBX/Window_Bars_Overgrown.fbx` | 1.99 x 1.987 x 0.305 | 0.002 | 1352 | 0 |  |
| `FBX/Window_Open.fbx` | 1.99 x 1.987 x 0.303 | 0.002 | 1148 | 0 |  |
| `FBX/Window_Open_Double.fbx` | 1.99 x 3.987 x 0.304 | 0.002 | 1952 | 0 |  |

## quaternius/ultimate-monsters

50 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `Big/glTF/Alien.gltf` | 4.649 x 3.547 x 1.488 | -0.003 | 7676 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Birb.gltf` | 4.649 x 3.328 x 1.65 | -0.003 | 5704 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/BlueDemon.gltf` | 4.628 x 2.841 x 2.157 | -0.007 | 5799 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Bunny.gltf` | 4.791 x 3.444 x 1.81 | -0.004 | 8282 | 49 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Cactoro.gltf` | 4.649 x 3.957 x 2.136 | -0.003 | 6398 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Demon.gltf` | 4.656 x 3.12 x 2.32 | -0.015 | 6712 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Dino.gltf` | 4.649 x 3.226 x 1.919 | -0.003 | 5414 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Fish.gltf` | 4.662 x 3.755 x 2.364 | -0.003 | 6854 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Frog.gltf` | 4.649 x 2.695 x 1.556 | -0.015 | 5016 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Monkroose.gltf` | 4.649 x 2.985 x 1.493 | -0.003 | 5824 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/MushroomKing.gltf` | 4.648 x 3.609 x 2.056 | -0.011 | 6044 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Ninja.gltf` | 4.649 x 3.021 x 3.049 | -0.014 | 5964 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Orc.gltf` | 4.685 x 3.209 x 1.871 | -0.013 | 7344 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Orc_Skull.gltf` | 4.688 x 3.268 x 1.861 | -0.013 | 7363 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Tribal.gltf` | 4.649 x 3.929 x 1.359 | 0.004 | 6620 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Big/glTF/Yeti.gltf` | 4.649 x 2.828 x 1.472 | -0.011 | 6094 | 43 | Death(0.77s), Duck(1.67s), HitReact(0.6s), Idle(1.0s), Jump(0.37s), Jump_Idle(0.5s), Jump_Land(0.37s), No(1.67s), Punch(0.87s), Run(0.57s), Walk(1.0s), Wave(1.67s), Weapon(0.87s), Yes(1.67s) |
| `Blob/glTF/Alien.gltf` | 3.869 x 3.158 x 2.26 | 0.017 | 2616 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Birb.gltf` | 2.795 x 2.814 x 2.65 | -0.14 | 3164 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Cactoro.gltf` | 4.074 x 3.494 x 3.52 | -0.0 | 2388 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Cat.gltf` | 2.099 x 1.856 x 1.743 | -0.032 | 1772 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Chicken.gltf` | 2.349 x 2.394 x 2.125 | -0.066 | 2904 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Dog.gltf` | 2.136 x 1.814 x 1.726 | -0.017 | 1392 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Fish.gltf` | 2.795 x 2.826 x 2.577 | -0.013 | 3346 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/GreenBlob.gltf` | 2.249 x 1.869 x 2.144 | -0.013 | 1520 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/GreenSpikyBlob.gltf` | 3.5 x 4.159 x 4.089 | -0.053 | 4888 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Mushnub.gltf` | 2.751 x 3.258 x 2.709 | -0.051 | 1248 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Mushnub_Evolved.gltf` | 3.402 x 4.461 x 3.647 | -0.061 | 3072 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Ninja.gltf` | 2.483 x 2.987 x 2.829 | -0.069 | 2160 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Orc.gltf` | 2.638 x 2.364 x 1.808 | -0.036 | 2296 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Pigeon.gltf` | 2.349 x 1.787 x 2.034 | 0.007 | 2184 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/PinkBlob.gltf` | 1.834 x 1.997 x 1.848 | -0.074 | 1030 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Wizard.gltf` | 2.33 x 2.586 x 2.267 | 0.003 | 1674 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Blob/glTF/Yeti.gltf` | 2.547 x 2.418 x 2.739 | -0.02 | 2136 | 4 | Bite_Front(0.4s), Dance(0.67s), Death(0.37s), HitRecieve(0.3s), Idle(2.0s), Jump(0.43s), No(1.0s), Walk(0.43s), Yes(0.97s) |
| `Flying/glTF/Alpaking.gltf` | 4.304 x 2.139 x 2.238 | 1.165 | 2508 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Alpaking_Evolved.gltf` | 4.304 x 3.192 x 2.973 | 0.54 | 4684 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Armabee.gltf` | 4.304 x 1.886 x 2.059 | 1.19 | 2280 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Armabee_Evolved.gltf` | 4.304 x 2.138 x 2.046 | 0.82 | 3200 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Demon.gltf` | 5.472 x 1.676 x 2.064 | 1.138 | 4784 | 43 | Flying_Idle(1.17s) |
| `Flying/glTF/Dragon.gltf` | 4.382 x 1.541 x 2.43 | 1.6 | 4562 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Dragon_Evolved.gltf` | 5.475 x 2.858 x 2.416 | 0.3 | 7440 | 46 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.5s), Headbutt(1.5s), HitReact(0.67s), No(1.17s), Punch(1.33s), Yes(1.17s) |
| `Flying/glTF/Ghost.gltf` | 5.5 x 3.101 x 1.236 | 0.28 | 3192 | 38 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Ghost_Skull.gltf` | 5.5 x 3.101 x 1.534 | 0.283 | 3146 | 38 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Glub.gltf` | 4.304 x 2.351 x 2.171 | 1.377 | 2528 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Glub_Evolved.gltf` | 4.304 x 3.707 x 2.008 | 0.524 | 4452 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Goleling.gltf` | 4.382 x 1.552 x 1.942 | 1.489 | 3696 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Goleling_Evolved.gltf` | 4.382 x 2.568 x 2.186 | 1.24 | 5864 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Hywirl.gltf` | 5.543 x 2.745 x 1.768 | 0.027 | 3296 | 38 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Pigeon.gltf` | 4.135 x 1.37 x 2.172 | 1.567 | 3512 | 13 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Squidle.gltf` | 5.472 x 1.987 x 2.123 | 0.994 | 4880 | 43 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |
| `Flying/glTF/Tribal.gltf` | 5.5 x 4.108 x 1.377 | 0.329 | 5252 | 38 | Death(0.67s), Fast_Flying(0.83s), Flying_Idle(1.17s), Headbutt(1.17s), HitReact(0.47s), No(1.17s), Punch(1.17s), Yes(1.17s) |

## quaternius/universal-animation-library

2 files.

| File | Size X x Y(up) x Z (m) | Bottom Y | Tris | Bones | Clips |
| :-- | :-- | --: | --: | --: | :-- |
| `Unreal-Godot/UAL1_Standard.glb` | 1.944 x 1.829 x 0.37 | 0.0 | 13743 | 65 | A_TPose(2.5s), Crouch_Fwd_Loop(2.0s), Crouch_Idle_Loop(2.93s), Dance_Loop(1.0s), Death01(2.4s), Driving_Loop(1.67s), Fixing_Kneeling(5.2s), Hit_Chest(0.33s), Hit_Head(0.43s), Idle_Loop(2.5s), Idle_Talking_Loop(2.93s), Idle_Torch_Loop(1.27s), Interact(2.0s), Jog_Fwd_Loop(0.93s), Jump_Land(1.27s), Jump_Loop(2.5s), Jump_Start(1.33s), PickUp_Table(0.83s), Pistol_Aim_Down(0.17s), Pistol_Aim_Neutral(0.17s), Pistol_Aim_Up(0.17s), Pistol_Idle_Loop(1.67s), Pistol_Reload(1.67s), Pistol_Shoot(0.63s), Punch_Cross(1.0s), Punch_Jab(0.87s), Push_Loop(2.67s), Roll(1.47s), Sitting_Enter(1.3s), Sitting_Exit(1.03s), Sitting_Idle_Loop(1.67s), Sitting_Talking_Loop(2.93s), Spell_Simple_Enter(0.53s), Spell_Simple_Exit(0.43s), Spell_Simple_Idle_Loop(2.1s), Spell_Simple_Shoot(0.5s), Sprint_Loop(0.67s), Swim_Fwd_Loop(1.33s), Swim_Idle_Loop(3.33s), Sword_Attack(1.53s), Sword_Idle(1.67s), Walk_Formal_Loop(1.33s), Walk_Loop(1.33s) |
| `Unreal-Godot/UAL1_Standard_RM.glb` | 1.944 x 1.829 x 0.37 | 0.0 | 13743 | 65 | A_TPose(2.5s), Crouch_Fwd_Loop(2.0s), Crouch_Idle_Loop(2.93s), Dance_Loop(1.0s), Death01(2.4s), Driving_Loop(1.67s), Fixing_Kneeling(5.2s), Hit_Chest(0.33s), Hit_Head(0.43s), Idle_Loop(2.5s), Idle_Talking_Loop(2.93s), Idle_Torch_Loop(1.27s), Interact(2.0s), Jog_Fwd_Loop(0.93s), Jump_Land(1.27s), Jump_Loop(2.5s), Jump_Start(1.33s), PickUp_Table(0.83s), Pistol_Aim_Down(0.17s), Pistol_Aim_Neutral(0.17s), Pistol_Aim_Up(0.17s), Pistol_Idle_Loop(1.67s), Pistol_Reload(1.67s), Pistol_Shoot(0.63s), Punch_Cross(1.0s), Punch_Jab(0.87s), Push_Loop(2.67s), Roll(1.47s), Sitting_Enter(1.3s), Sitting_Exit(1.03s), Sitting_Idle_Loop(1.67s), Sitting_Talking_Loop(2.93s), Spell_Simple_Enter(0.53s), Spell_Simple_Exit(0.43s), Spell_Simple_Idle_Loop(2.1s), Spell_Simple_Shoot(0.5s), Sprint_Loop(0.67s), Swim_Fwd_Loop(1.33s), Swim_Idle_Loop(3.33s), Sword_Attack(1.53s), Sword_Idle(1.67s), Walk_Formal_Loop(1.33s), Walk_Loop(1.33s) |
