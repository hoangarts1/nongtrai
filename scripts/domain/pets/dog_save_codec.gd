## DogSaveCodec - pure dog-only fallback; never changes any previous save component.
class_name DogSaveCodec
extends RefCounted
static func normalize(config: DogConfig, raw: Variant, desired: Vector2i) -> Dictionary:
	if config == null or not config.validation_errors().is_empty(): return {"ok": false, "reason": &"invalid_dog_config"}
	var decoded: Dictionary = DogSnapshotCodec.decode(config, raw)
	if decoded.ok: return {"ok": true, "snapshot": decoded.snapshot, "used_fallback": false}
	var name: String = ""
	if raw is Dictionary:
		var checked: Dictionary = DogNameRules.normalize(config, raw.get("name"), true)
		if checked.ok: name = checked.name
	var navigation: DogNavigation = DogNavigation.new()
	if not navigation.configure(config): return {"ok": false, "reason": &"invalid_dog_navigation"}
	var safe: Dictionary = DogFollowRules.nearest_walkable(config, navigation, desired)
	if not safe.ok: return safe
	return {"ok": true, "snapshot": {"name":name,"cell_x":safe.cell.x,"cell_y":safe.cell.y}, "used_fallback":true}
