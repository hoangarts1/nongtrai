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

## 2. GridMath — pure logical-cell operations (D33)

`GridMath.footprint_cells(origin, size, rotation_steps)` stays the pure owner of even/odd footprints and logical 90° rotation. Existing XZ `world_to_cell` / `cell_to_world` APIs are legacy implemented APIs; ISO-1 must handle their callers and compatibility explicitly. Do not replace them with hand-written isometric projection or pass TileMapLayer into DOMAIN. Rendering conversion belongs in VIEW.

## 3. Mouse → cell with TileMapLayer (2D target)

```gdscript
func mouse_cell(layer: TileMapLayer) -> Vector2i:
	return layer.local_to_map(layer.to_local(layer.get_global_mouse_position()))

func cell_global_position(layer: TileMapLayer, cell: Vector2i) -> Vector2:
	return layer.to_global(layer.map_to_local(cell))
```

These are reference snippet shapes; ISO-1 implements the bound-layer adapter as IsometricGrid (see API_INDEX). One view adapter is shared by picking, highlight and visuals; test layer transforms, camera zoom/pan, negative cells and cell-center round trips. If an API accepts a viewport screen point instead, convert it through the canvas transform before `local_to_map`; never treat pixels as cells. Domain code receives only the resulting logical cell.

## 4. Screen-relative movement (CharacterBody2D target)

```gdscript
static func screen_direction(input_vector: Vector2) -> Vector2:
	var direction: Vector2 = input_vector.limit_length(1.0)
	direction.y *= 0.5
	return direction
```

Use the result times data-defined movement speed for `velocity`, then `move_and_slide()` without arguments. Input comes from `Input.get_vector` with documented actions and honors the existing modal/sleep movement lock. Do not renormalize after y compression. Test zero/cardinal/diagonal/analog input in uncompressed movement space; raw screen-space vertical speed is deliberately half horizontal speed. No yaw/pitch math remains in the target player.

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
extends Area2D

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
