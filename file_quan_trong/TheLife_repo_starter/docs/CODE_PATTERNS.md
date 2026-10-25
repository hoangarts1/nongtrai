# CODE PATTERNS — approved reference snippets

These are SHAPES to follow, not copy-paste truth. The agent must check each one against the PINNED Godot version (see `docs/PROJECT_RULES.md` §1) before using it, and run the parse check. If an API differs in the pinned version, adapt the snippet and note it in `docs/PROGRESS.md`.

## 1. Typed signal bus (autoload `Events`)

```gdscript
# scripts/core/events.gd   (autoload name: Events — do NOT also give this script a class_name "Events")
extends Node

@warning_ignore("unused_signal")
signal day_started(day_index: int)
@warning_ignore("unused_signal")
signal crop_harvested(cell: Vector2i, crop_id: StringName, quantity: int, quality: int)
@warning_ignore("unused_signal")
signal coins_changed(new_total: int, delta: int, reason: StringName)

# emit:     Events.crop_harvested.emit(cell, crop_id, qty, quality)
# connect:  Events.day_started.connect(_on_day_started)
```

Rules: local signals for parent-child relations; the bus only for cross-system events. Every new bus signal is added to the event catalog in `docs/ARCHITECTURE.md`. (If your pinned version has no `unused_signal` warning, the annotation is unnecessary — check.)

## 2. GridMath — the only world↔cell converter

```gdscript
class_name GridMath
extends RefCounted

const CELL_SIZE := 1.0

static func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / CELL_SIZE), floori(p.z / CELL_SIZE))   # floori, never int()

static func cell_to_world(c: Vector2i) -> Vector3:
	return Vector3((c.x + 0.5) * CELL_SIZE, 0.0, (c.y + 0.5) * CELL_SIZE)   # cell CENTER, y = 0
```

Even/odd footprint offsets are handled here and nowhere else (`footprint_cells(origin, size, rotation_steps)`).

## 3. Mouse → cell with an orthographic Camera3D

```gdscript
func pick_cell(camera: Camera3D, mouse_pos: Vector2) -> Variant:   # Vector2i or null
	var from := camera.project_ray_origin(mouse_pos)
	var dir := camera.project_ray_normal(mouse_pos)
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
	if hit == null:
		return null
	return GridMath.world_to_cell(hit as Vector3)
```

One function, unit-tested, used by everything that targets a cell.

## 4. Camera-relative movement (CharacterBody3D)

```gdscript
func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var b := camera.global_transform.basis
	var fwd := Vector3(-b.z.x, 0.0, -b.z.z).normalized()
	var right := Vector3(b.x.x, 0.0, b.x.z).normalized()
	var dir := right * input.x + fwd * -input.y
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()   # NO arguments in Godot 4
```

Extract the direction math into a pure static function so it can be unit-tested for yaw = 0 / 45 / 90.

## 5. Deterministic randomness

```gdscript
class_name DetRandom
extends RefCounted

const TAG_WEATHER := 1
const TAG_DIRECTOR := 2
const TAG_ORDERS := 3
const TAG_FORAGE := 4
const MOD := 2147483647

static func mix(a: int, b: int) -> int:
	var h: int = posmod(a, MOD) * 1103515245 + posmod(b, MOD) + 12345   # stays below 2^62
	return posmod(h, MOD)

static func make_rng(world_seed: int, day: int, tag: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = mix(mix(world_seed, day), tag)
	return rng
```

Why not `hash()`: its output is not guaranteed stable between engine versions, which would silently break golden tests. A golden test for `make_rng` also detects a change of the engine's RNG sequence after a Godot upgrade.

## 6. State machine node (one script per state)

```gdscript
class_name PlayerState
extends Node

signal transition_requested(next_state: StringName, msg: Dictionary)

func enter(_msg: Dictionary = {}) -> void: pass
func exit() -> void: pass
func handle_input(_event: InputEvent) -> void: pass
func physics_update(_delta: float) -> void: pass
```

Adding a state = adding a file and registering it in the state machine. `player.gd` is not edited.

## 7. Tool strategy (Resource)

```gdscript
class_name ToolAction
extends Resource

func can_execute(_world: WorldState, _cell: Vector2i, _actor: Node) -> bool:
	return false

func execute(_world: WorldState, _cell: Vector2i, _actor: Node) -> bool:
	return false

# HoeAction, WaterAction, SeedAction, HarvestAction... extend this. ToolData points to a ToolAction.
# The animation emits `tool_hit`; farming logic reacts to that signal, never to a guessed Timer.
```

## 8. Interactable component

```gdscript
class_name Interactable
extends Area3D

signal interacted(actor: Node)

@export var prompt_key: String = "PROMPT_INTERACT"

func interact(actor: Node) -> void:
	interacted.emit(actor)
```

## 9. Domain class skeleton (serialize / deserialize)

```gdscript
## FarmGridState — plots by cell: till / plant / water / advance_day / harvest.
## API:
##   func till(cell: Vector2i) -> bool
##   func serialize() -> Dictionary
##   func deserialize(d: Dictionary) -> void
class_name FarmGridState
extends RefCounted

var _plots: Dictionary = {}   # Vector2i -> PlotState

func serialize() -> Dictionary:
	var out: Array = []
	for cell: Vector2i in _plots:
		out.append({"cell": "%d,%d" % [cell.x, cell.y], "plot": (_plots[cell] as PlotState).serialize()})
	return {"plots": out}

func deserialize(d: Dictionary) -> void:
	_plots.clear()
	for entry: Dictionary in d.get("plots", []):
		var parts := String(entry.get("cell", "0,0")).split(",")
		var cell := Vector2i(int(parts[0]), int(parts[1]))   # JSON numbers come back as float: cast
		var plot := PlotState.new()
		plot.deserialize(entry.get("plot", {}))
		_plots[cell] = plot
```

(Typed `for` loops over Dictionary/Array are version-sensitive; verify on the pinned version.)

## 10. Network gateway shape (Phase 10)

```gdscript
class_name NetworkGateway
extends RefCounted
# All methods are async (await) and return a Result {ok: bool, error: String, data: Variant}.
func sign_in() -> Result: return null
func send_gift(to_player_id: String, item_id: StringName, qty: int, idempotency_key: String) -> Result: return null
func fetch_inbox() -> Result: return null
func claim_gift(gift_id: String) -> Result: return null
func upload_snapshot(snapshot_json: String) -> Result: return null
func fetch_friend_snapshot(player_id: String) -> Result: return null
func contribute_project(project_id: String, contribution: Dictionary, idempotency_key: String) -> Result: return null
```

`MockBackend` implements the same interface locally for development and tests. Gameplay talks only to `Net`.
