# player.tscn  (DRAFT — used from roadmap task 1.1)

Path: `scenes/player/player.tscn`
Root: `Player` (`CharacterBody3D`)   Script: `scripts/player/player.gd`   `class_name`: `Player`

## Node tree
```
Player (CharacterBody3D)                      layer: player (2) · mask: world_static (1)
├─ CollisionShape3D                            CapsuleShape3D, ~0.35 m radius, ~1.3 m tall (character ≈ 1.2–1.5 cells)
├─ Visual (Node3D)                             %Visual   gray-box capsule/box now; the real model later
├─ StateMachine (Node)                         %StateMachine   (script added in task 1.4)
│  ├─ IdleState (Node)                         script: scripts/player/states/idle_state.gd
│  └─ MoveState (Node)                         script: scripts/player/states/move_state.gd
└─ InteractionDetector (Area3D)                %InteractionDetector   layer: — · mask: interactable (3)  (task 1.5)
   └─ CollisionShape3D                         small sphere/box in front of the player, ~1.2 m reach
```
(The camera rig is a SIBLING in the world scene, not a child of the player.)

## @export variables
| Variable | Type | Assigned to |
|---|---|---|
| `camera` | `Camera3D` | the world's `%Camera` (assigned in the world scene, or set at spawn) |
| `config` | `PlayerConfig` | `data/player_config.tres` (walk speed, sprint speed, acceleration, reach_cells) |

## Signals
| Signal | Parameters | Emitted by |
|---|---|---|
| `tool_hit` | — | an `AnimationPlayer` call-method track at the exact "contact" frame (task 4.3) |
| `target_changed` | `interactable: Interactable` (nullable) | InteractionDetector logic (task 1.5) |

## Groups
`player`

## Notes
- Movement = `velocity` + `move_and_slide()` (no arguments), camera-relative (see `docs/CODE_PATTERNS.md` §4).
- Position is saved as `cell` + `facing`, never as a world position.
- Input actions only from `docs/INPUT_MAP.md`.
