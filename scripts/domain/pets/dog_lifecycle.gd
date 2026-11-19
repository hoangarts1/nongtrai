## DogLifecycle - reference-only atomic restore into the existing sole dog owner.
class_name DogLifecycle
extends RefCounted
var _config: DogConfig
var _owner: DogState
func configure(config: DogConfig, state: DogState) -> bool:
	if config == null or not config.validation_errors().is_empty() or state == null or state.is_busy(): return false
	_config = config.frozen_copy()
	_owner = state
	return true
func prepare(raw: Variant, desired: Vector2i, navigation: DogNavigation) -> Dictionary:
	if _owner == null or _owner.is_busy() or navigation == null: return {"ok": false, "reason": &"dog_busy"}
	var result: Dictionary = DogSaveCodec.normalize(_config, raw, desired)
	if not result.ok: return result
	var cell: Vector2i = Vector2i(result.snapshot.cell_x, result.snapshot.cell_y)
	if not navigation.is_walkable(cell):
		var safe: Dictionary = DogFollowRules.nearest_walkable(_config, navigation, cell)
		if not safe.ok: return safe
		result.snapshot.cell_x = safe.cell.x
		result.snapshot.cell_y = safe.cell.y
	return result
func restore(prepared: Dictionary) -> bool:
	return _owner != null and not _owner.is_busy() and prepared.get("ok") == true and prepared.get("snapshot") is Dictionary and _owner.deserialize(prepared.snapshot)
