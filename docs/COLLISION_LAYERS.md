# COLLISION LAYERS — THE LIFE (2D Physics)

ISO-1 sets these same names/numbers in Project Settings → Layer Names → 2D Physics. Current runtime still uses the legacy 3D layers until that milestone is implemented. Agents use ONLY these numbers/names and must never invent a layer. See D33.

| Layer # | Name | Purpose |
|---|---|---|
| 1 | `world_static` | terrain, walls, solid buildings |
| 2 | `player` | the player character |
| 3 | `interactable` | Area2D regions of things the player can interact with |
| 4 | `npc` | NPCs and pets |
| 5 | `trigger` | trigger zones (events, audio regions) |
| 6 | `water` | water volumes (fishing, footsteps) |
| 7 | `occluder_fade` | zones that fade/dither occluding objects |
| 8 | `placement` | blockers for building placement |

## Recommended layer / mask per object type

| Object | Layer (I am) | Mask (I detect) |
|---|---|---|
| Ground / walls / solid props | 1 | — |
| Player `CharacterBody2D` | 2 | 1 |
| Player interaction detector `Area2D` | — | 3 |
| `Interactable` Area2D (on doors, mailbox, bed, machines…) | 3 | — |
| NPC / pet | 4 | 1 |
| Trigger zone | 5 | 2 |
| Water volume | 6 | 2 |
| Occluder-fade zone (around the player) | 7 | — (it detects occluding objects placed on layer 7 as needed) |
| Placement blocker | 8 | — |

## Bit-value reminder (Godot)

Layer N corresponds to bit value `1 << (N - 1)`: layer 1 = 1, layer 2 = 2, layer 3 = 4, layer 4 = 8, layer 5 = 16, layer 6 = 32, layer 7 = 64, layer 8 = 128. In the Inspector they are checkboxes; in code use `set_collision_layer_value(n, true)` / `set_collision_mask_value(n, true)` rather than raw integers.

Changes to this table require a `docs/DECISIONS.md` entry and the human editing Project Settings.

Ground tiles are walkable presentation; only actual obstacles/walls use blocking shapes. Placeholder art never supplies hidden collision or new interaction reach. ISO-1 must check these names against `project.godot` and verify player/world collision in 2D.

ISO-1: Player uses a 12×6 RectangleShape2D foot collider. World Obstacle_<index> StaticBody2D nodes use convex CollisionPolygon2D shapes derived from the existing NPC navigation solids, excluding the farm rectangle (which blocks NPC routes, not player walking). No new collision layer was added. House/shop/bin logical cells are data-owned in isometric_world_config.tres.
