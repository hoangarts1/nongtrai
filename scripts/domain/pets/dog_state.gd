## DogState — sole companion name/logical-cell owner; no route, Node or economy.
## API: configure(config,cell)->bool; serialize()/deserialize(raw)->bool;
## get_name()/get_cell()/get_revision()/is_busy(); try_set_name/try_set_cell.
class_name DogState
extends RefCounted

signal changed(cell: Vector2i, dog_name: String)
var _config: DogConfig
var _snapshot: Dictionary = {}
var _revision: int = 0
var _notifying: bool = false

func configure(config: DogConfig, cell: Vector2i) -> bool:
	if is_busy() or config == null or not config.validation_errors().is_empty() or not config.world.player_region.has_point(cell):
		return false
	_config = config.frozen_copy()
	_snapshot = {"name": "", "cell_x": cell.x, "cell_y": cell.y}
	_revision += 1
	return true

func is_busy() -> bool:
	return _notifying

func get_name() -> String:
	return String(_snapshot.get("name", ""))

func get_cell() -> Vector2i:
	return Vector2i(int(_snapshot.get("cell_x", 0)), int(_snapshot.get("cell_y", 0)))

func get_revision() -> int:
	return _revision

func serialize() -> Dictionary:
	return _snapshot.duplicate(true)

func deserialize(raw: Dictionary) -> bool:
	if is_busy():
		return false
	var decoded: Dictionary = DogSnapshotCodec.decode(_config, raw)
	if not decoded.ok:
		return false
	_snapshot = decoded.snapshot
	_revision += 1 # Successful replacement invalidates prior command quotes, silently.
	return true

func try_set_name(value: String, expected_revision: int = -1) -> Dictionary:
	var ready: Dictionary = _preflight(expected_revision)
	if not ready.ok:
		return ready
	var name: Dictionary = DogNameRules.normalize(_config, value)
	if not name.ok:
		return name
	var candidate: Dictionary = serialize()
	candidate.name = String(name.name)
	return _publish(candidate)

func try_set_cell(cell: Vector2i, expected_revision: int = -1) -> Dictionary:
	# Navigation/adjacency belong to DogMovementService; this sole owner enforces
	# current config bounds. Spawn/load recovery may legitimately replace a cell.
	var ready: Dictionary = _preflight(expected_revision)
	if not ready.ok:
		return ready
	if not _config.world.player_region.has_point(cell):
		return {"ok": false, "reason": &"dog_cell_outside_map"}
	var candidate: Dictionary = serialize()
	candidate.cell_x = cell.x
	candidate.cell_y = cell.y
	return _publish(candidate)

func _preflight(expected: int) -> Dictionary:
	if _notifying or _config == null:
		return {"ok": false, "reason": &"dog_busy_or_unconfigured"}
	if expected != -1 and expected != _revision:
		return {"ok": false, "reason": &"stale_dog_quote"}
	return {"ok": true}

func _publish(candidate: Dictionary) -> Dictionary:
	if candidate == _snapshot:
		return {"ok": true, "changed": false, "revision": _revision}
	_snapshot = candidate
	_revision += 1
	_notifying = true
	changed.emit(get_cell(), get_name())
	_notifying = false
	return {"ok": true, "changed": true, "revision": _revision}
