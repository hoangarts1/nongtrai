## DogSnapshotCodec — strict three-field wire, signed cells and JSON-safe exact ints.
class_name DogSnapshotCodec
extends RefCounted

const INT32_MIN: int = -2147483648
const INT32_MAX: int = 2147483647

static func integer(value: Variant) -> bool:
	return (value is int or (value is float and is_finite(value) and value == floorf(value))) and value >= INT32_MIN and value <= INT32_MAX

static func decode(config: DogConfig, raw: Variant) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or not raw is Dictionary or raw.size() != 3 or not raw.has("name") or not raw.has("cell_x") or not raw.has("cell_y"):
		return {"ok": false, "reason": &"invalid_dog_snapshot"}
	var name: Dictionary = DogNameRules.normalize(config, raw.name, true)
	if not name.ok or not integer(raw.cell_x) or not integer(raw.cell_y):
		return {"ok": false, "reason": &"invalid_dog_snapshot"}
	var cell: Vector2i = Vector2i(int(raw.cell_x), int(raw.cell_y))
	if not config.world.player_region.has_point(cell):
		return {"ok": false, "reason": &"dog_cell_outside_map"}
	return {"ok": true, "snapshot": {"name": String(name.name), "cell_x": cell.x, "cell_y": cell.y}}
