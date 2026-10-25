# API INDEX — THE LIFE

Public methods and signals of every system. Agents read THIS instead of scanning code, and update it at the end of every task. Source of truth for each entry is the `## API:` header at the top of the script.

Format:

```
## ClassName  (path/to/script.gd)
- func name(arg: Type) -> ReturnType        — one-line meaning
- signal name(arg: Type)                    — when it fires
- Notes: invariants, who owns the state, edge cases
```

---

## GridMath  (scripts/util/grid_math.gd)
- static func world_to_cell(position: Vector3) -> Vector2i — converts a world XZ position to a logical cell using floor-safe division
- static func cell_to_world(cell: Vector2i) -> Vector3 — returns the center of a logical cell
- static func footprint_cells(origin: Vector2i, size: Vector2i, rotation_steps: int) -> Array[Vector2i] — returns occupied cells for a 90-degree footprint rotation
- Notes: the logical grid is Vector2i on the XZ plane; one cell is 1 metre.

## GrayBoxWorld  (scripts/view/gray_box_world.gd)
- func pick_cell(screen_position: Vector2) -> Variant — projects a screen point onto the ground plane and returns a Vector2i cell or null
- Notes: placeholder view only; it owns no gameplay state.

## CameraRig  (scripts/view/camera_rig.gd)
- func set_target(target_node: Node3D) -> void — assigns the node followed by the rig
- Notes: follows with exponential smoothing and clamps the camera center to the gray-box map bounds.

<!-- Example of a finished entry (delete when real ones exist):

## EconomyService  (scripts/domain/economy/economy_service.gd)
- func try_spend(amount: int, reason: StringName, key: StringName = &"") -> bool   — false if not enough coins
- func earn(amount: int, reason: StringName, key: StringName = &"") -> void
- signal coins_changed(new_total: int, delta: int, reason: StringName)             — via Events
- Notes: coins are int; every change is written to Ledger with a reason; only this class changes coins.
-->
