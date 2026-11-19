## DogNavigationCodec — canonical derived obstacle context; never a game-save root.
class_name DogNavigationCodec
extends RefCounted

static func rectangle(region: Rect2i) -> Dictionary:
	return {"x": region.position.x, "y": region.position.y, "w": region.size.x, "h": region.size.y}

static func from_regions(config: DogConfig, regions: Array[Rect2i]) -> Dictionary:
	var raw: Array[Dictionary] = []
	for region: Rect2i in regions:
		raw.append(rectangle(region))
	return decode(config, {"bounds": rectangle(config.world.player_region) if config != null and config.world != null else {}, "dynamic": raw})

static func decode(config: DogConfig, raw: Variant) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or not raw is Dictionary or raw.size() != 2 or not raw.get("bounds") is Dictionary or not raw.get("dynamic") is Array:
		return {"ok": false, "reason": &"invalid_navigation_context"}
	var bounds: Dictionary = _rect(raw.bounds)
	if not bounds.ok or bounds.region != config.world.player_region or raw.dynamic.size() > config.world.player_region.get_area():
		return {"ok": false, "reason": &"invalid_navigation_bounds"}
	var regions: Array[Dictionary] = []
	for value: Variant in raw.dynamic:
		var checked: Dictionary = _rect(value)
		if not checked.ok:
			return checked
		var rectangle_region: Rect2i = checked.region
		var clipped: Rect2i = rectangle_region.intersection(config.world.player_region)
		if clipped.has_area():
			var row: Dictionary = rectangle(clipped)
			if not regions.has(row): regions.append(row)
	regions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		for key: String in ["y", "x", "w", "h"]:
			if a[key] != b[key]: return a[key] < b[key]
		return false)
	return {"ok": true, "context": {"bounds": rectangle(config.world.player_region), "dynamic": regions}}

static func _rect(raw: Variant) -> Dictionary:
	if not raw is Dictionary or raw.size() != 4:
		return {"ok": false, "reason": &"invalid_navigation_rectangle"}
	for key: String in ["x", "y", "w", "h"]:
		if not DogSnapshotCodec.integer(raw.get(key)):
			return {"ok": false, "reason": &"invalid_navigation_rectangle"}
	if int(raw.w) <= 0 or int(raw.h) <= 0 or int(raw.x) + int(raw.w) > DogSnapshotCodec.INT32_MAX or int(raw.y) + int(raw.h) > DogSnapshotCodec.INT32_MAX:
		return {"ok": false, "reason": &"invalid_navigation_rectangle"}
	return {"ok": true, "region": Rect2i(int(raw.x), int(raw.y), int(raw.w), int(raw.h))}
