# player.tscn — ISO-1 implemented contract (D33/D36)

ISO-8b/D45 changes only Visual's cosmetic hair drawing when configure_profile receives normalized player customization. Shared AvatarHair2D supplies six silhouettes matching the UI preview; get_hair_style() -> StringName exposes display ID. Existing body/actions, nodes, geometry/collision/movement/save owners remain. NPC/no-customization legacy hair is unchanged. No .tscn edit.

Status: ISO-1 implementation and automated checks delivered; human editor playtest pending. The Player resource path, class name and movement gate remain stable.

Path: `scenes/player/player.tscn`
Root: `Player` (`CharacterBody2D`)   Script: `scripts/player/player.gd`   `class_name`: `Player`

## Node tree
```
Player (CharacterBody2D)                      layer: player (2) · mask: world_static (1)
├─ CollisionShape2D                          RectangleShape2D 12×6; foot collider, no scaled shape
├─ Visual (Node2D)                           %Visual; PlaceholderAvatar2D, feet at local origin
└─ Camera (Camera2D)                         %Camera; follows player; no rotation
```
The Camera is a CHILD of Player. CameraRig is now a nonvisual Node under GrayBoxWorld; it drives this single Camera2D's center/zoom from data. The old StateMachine/InteractionDetector entries were future draft nodes absent from the actual C4 scene and are not ISO-1 requirements.

## @export variables
| Variable | Type | Assigned to |
|---|---|---|
| `camera` | `Camera2D` | the player's child `%Camera` |
| `config` | `PlayerConfig` | `data/player_2d_config.tres`, existing class `scripts/player/player_config.gd`; walk/sprint speeds are pixels per second before vertical compression |
| `map_min`, `map_max` | `Vector2` | inclusive logical-cell bounds injected from IsometricWorldConfig.player_region; no metre/pixel reinterpretation |

`movement_enabled: bool` remains the existing modal/sleep gate. `grid: IsometricGrid` is a VIEW-only adapter injected by GrayBoxWorld; `get_cell()` and `move_to_cell(cell)` never change domain farm/NPC state. Speeds are in player_2d_config.tres, map/zoom/reach in isometric_world_config.tres and collider dimensions in this scene's Inspector.

## Historical draft signals (not implemented by the current Player)
| Signal | Parameters | Emitted by |
|---|---|---|
| `tool_hit` | — | an `AnimationPlayer` call-method track at the exact "contact" frame (task 4.3) |
| `target_changed` | `interactable: Interactable` (nullable) | InteractionDetector logic (task 1.5) |

## Groups
No player group is currently declared by the scene/script; the old draft group was never implemented. Callers use the typed GrayBoxWorld.player reference.

## Notes
- Movement = `velocity` + `move_and_slide()` (no arguments). Target input follows screen axes, normalizes before vertical ×0.5, and is not normalized again. See CODE_PATTERNS §4.
- Position is resolved to a logical cell before saving. The actual v4 wire schema retains legacy player.position.x/y/z cell-center coordinates for compatibility (D36); canvas pixels are never saved. Restore snaps subcell offsets to a valid cell center. No facing/save field was invented.
- Input actions only from `docs/INPUT_MAP.md`.
- Sprite/placeholder replacement cannot change collision, movement, inventory, crop state or saved cell IDs. The active player subtree must have no 3D node after ISO-1.

## D72-C1 preserved player/render boundary (D73)

Player movement/collider/scene/save are untouched. The inherited procedural chibi avatar and shared six-style hair remain, with cosmetic phases pausing and existing real-time action/emotion feedback expiry retained. Camera pan extents are new Resource fields with inherited values; camera returns smoothly on walking and immediately on double-right/reset. Native wheel routing does not alter the player or tool domain. Preview tests retain actual resolved skin/hair/outfit choices; generated farmer_sheet PNG is an offline draft, not the live avatar.

## Phase8.5f dog companion boundary

Main.dog_runtime reads actual Player.get_cell() and shared IsometricGrid only; never writes movement, collider, camera, stamina or input. Actor is a nonblocking Node2D under world.objects. Existing player controls remain. Dog uses its separate bounded39x39 navigation cache; no NPC schedule/grid changes. Sparse machine/owned-land/coop snapshots and current WorldLocations supply dog exclusions, independently from NPC nav policy. Manual F5: walk/sprint to map edges, change machines/land/coop, pause/debug/sleep/title, check one dog and normal tools/camera. Automated evidence in PROGRESS.
