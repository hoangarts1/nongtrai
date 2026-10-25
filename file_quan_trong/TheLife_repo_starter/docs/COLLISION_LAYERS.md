# COLLISION LAYERS — THE LIFE (3D Physics)

Set these names in Project Settings → Layer Names → 3D Physics BEFORE writing any gameplay code. Agents use ONLY these numbers/names and must never invent a layer.

| Layer # | Name | Purpose |
|---|---|---|
| 1 | `world_static` | terrain, walls, solid buildings |
| 2 | `player` | the player character |
| 3 | `interactable` | Area3D volumes of things the player can interact with |
| 4 | `npc` | NPCs and pets |
| 5 | `trigger` | trigger zones (events, audio regions) |
| 6 | `water` | water volumes (fishing, footsteps) |
| 7 | `occluder_fade` | zones that fade/dither occluding objects |
| 8 | `placement` | blockers for building placement |

## Recommended layer / mask per object type

| Object | Layer (I am) | Mask (I detect) |
|---|---|---|
| Ground / walls / solid props | 1 | — |
| Player `CharacterBody3D` | 2 | 1 |
| Player interaction detector `Area3D` | — | 3 |
| `Interactable` Area3D (on doors, mailbox, bed, machines…) | 3 | — |
| NPC / pet | 4 | 1 |
| Trigger zone | 5 | 2 |
| Water volume | 6 | 2 |
| Occluder-fade zone (around the player) | 7 | — (it detects occluding objects placed on layer 7 as needed) |
| Placement blocker | 8 | — |

## Bit-value reminder (Godot)

Layer N corresponds to bit value `1 << (N - 1)`: layer 1 = 1, layer 2 = 2, layer 3 = 4, layer 4 = 8, layer 5 = 16, layer 6 = 32, layer 7 = 64, layer 8 = 128. In the Inspector they are checkboxes; in code use `set_collision_layer_value(n, true)` / `set_collision_mask_value(n, true)` rather than raw integers.

Changes to this table require a `docs/DECISIONS.md` entry and the human editing Project Settings.
