# gray_box_world.tscn  (DRAFT — used from roadmap task 0.4)

Path: `scenes/world/gray_box_world.tscn`
Root: `GrayBoxWorld` (`Node3D`)   Script: (none at first; `scripts/view/gray_box_world.gd` may be added by a task)

Purpose: a flat test world for camera, grid picking, movement and collision. No art.

## Node tree
```
GrayBoxWorld (Node3D)
├─ WorldEnvironment                     (default environment; lighting is tuned later)
├─ Sun (DirectionalLight3D)             (shadows ON; adjust bias/distance for the ortho camera)
├─ Ground (StaticBody3D)                layer: world_static
│  ├─ GroundMesh (MeshInstance3D)       PlaneMesh 48 x 48 m (or a large BoxMesh), grey material
│  └─ GroundShape (CollisionShape3D)    matching box/plane shape
├─ Obstacles (Node3D)                   group "obstacles"
│  └─ Box_* (StaticBody3D)              layer: world_static; a few 1x1x1 and 2x2x1 boxes, a wall
├─ CameraRig (Node3D)                   %CameraRig  (scripts/view/camera_rig.gd; follows the player)
│  └─ Camera3D                          %Camera  projection = Orthogonal, yaw 45°, pitch per D13, `size` tuned so ~14–18 cells fit the screen height
├─ GridDebug (Node3D)                   %GridDebug  (draws the grid lines / hovered cell highlight; added by task 0.4)
└─ PlayerSpawn (Marker3D)               %PlayerSpawn at cell (0,0) center = (0.5, 0, 0.5)
```

## @export variables
| Variable | Type | Notes |
|---|---|---|
| (none yet) | | |

## Groups
`obstacles` — static blockers used for collision tests.

## Notes
- Cell (0,0) occupies world X 0..1, Z 0..1; its center is (0.5, 0, 0.5) (see `GridMath`).
- The `Player` scene is instanced as a child in this gray-box scene and assigned to the camera rig at runtime.
- The player is clamped to the playable map bounds; the camera rig follows smoothly and clamps its center so the view stays within the map.
- Lighting/shadows are placeholders. Do not tune shadow cascades until the camera angle (D13) is locked.
