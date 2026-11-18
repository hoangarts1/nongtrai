## EcologySampler — stateless targets from validated farm and ownership snapshots.
## API: static sample(config, farm_snapshot, crops, owned_regions, current_metrics) -> Dictionary.
## Returns {ok, targets, counts, available} or {ok:false, reason}; never updates an owner.
class_name EcologySampler
extends RefCounted

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const INT32_MIN: int = -2147483648
const INT32_MAX: int = 2147483647
const BOOLEAN_FIELDS: PackedStringArray = ["tilled", "regrowing", "watered", "withered"]
const COUNTER_FIELDS: PackedStringArray = ["growth_days", "growth_target", "consecutive_dry_days", "withered_days"]

static func sample(config: EcologySamplingConfig, farm_snapshot: Variant, crops: Array[Resource], owned_regions: Array[Rect2i], current_metrics: Dictionary) -> Dictionary:
	if config == null:
		return _failure("ecology sampling config is required")
	var errors: PackedStringArray = config.validation_errors(crops)
	if not errors.is_empty():
		return _failure("; ".join(errors))
	var current: Dictionary = EcologySnapshotCodec.decode_metrics(PROFILE, current_metrics)
	if not current.ok:
		return _failure("ecology sampling requires complete valid current metrics")
	for region: Rect2i in owned_regions:
		# Check endpoints in int64 before any Rect2i end addition could wrap.
		if region.size.x <= 0 or region.size.y <= 0 or int(region.position.x) + int(region.size.x) > INT32_MAX or int(region.position.y) + int(region.size.y) > INT32_MAX:
			return _failure("ecology sampling owned regions must have positive nonoverflowing bounds")
	if not farm_snapshot is Dictionary or not farm_snapshot.get("plots") is Array:
		return _failure("ecology sampling farm requires plots array")
	var known: Dictionary = {}
	for resource: Resource in crops:
		var crop: CropData = resource as CropData
		known[String(crop.crop_id)] = crop
	var seen: Dictionary = {}
	var species: Dictionary = {}
	var mature_trees: int = 0
	var healthy_plants: int = 0
	for raw: Variant in farm_snapshot.plots:
		var reason: String = _plot_error(raw, known)
		if not reason.is_empty():
			return _failure(reason)
		var cell: Vector2i = Vector2i(int(raw.cell_x), int(raw.cell_y))
		if seen.has(cell):
			return _failure("ecology sampling duplicate plot cell")
		seen[cell] = true
		var id: String = String(raw.crop_id)
		if id.is_empty() or raw.withered or not _owned(cell, owned_regions):
			continue
		healthy_plants += 1
		species[String(config.species_aliases.get(id, id))] = true
		if config.fruit_tree_ids.has(id) and (raw.regrowing or int(raw.growth_days) >= int(raw.growth_target)):
			mature_trees += 1
	var scale: float = EcologyMetricData.PERCENT_SCALE
	return {
		"ok": true,
		"targets": {
			"tree_cover": minf(scale, scale * float(mature_trees) / float(config.mature_tree_goal)),
			"biodiversity": minf(scale, scale * float(species.size()) / float(config.species_goal)),
			"water_clarity": current.metrics.water_clarity
		},
		"counts": {"mature_fruit_trees": mature_trees, "healthy_plants": healthy_plants, "species": species.size()},
		"available": {"tree_cover": true, "biodiversity": true, "water_clarity": false}
	}

static func _plot_error(raw: Variant, known: Dictionary) -> String:
	if not raw is Dictionary:
		return "ecology sampling plot must be a dictionary"
	if not _integer(raw.get("cell_x"), INT32_MIN) or not _integer(raw.get("cell_y"), INT32_MIN):
		return "ecology sampling plot cell must be integral int32"
	for field: String in BOOLEAN_FIELDS:
		if not raw.get(field) is bool:
			return "ecology sampling plot flag must be boolean: " + field
	for field: String in COUNTER_FIELDS:
		if not _integer(raw.get(field), 0):
			return "ecology sampling plot counter must be nonnegative int32: " + field
	var raw_id: Variant = raw.get("crop_id")
	if not raw_id is String and not raw_id is StringName:
		return "ecology sampling crop id must be a string"
	var id: String = String(raw_id)
	if id.is_empty():
		if raw.regrowing or raw.withered or int(raw.growth_target) != 0 or int(raw.growth_days) != 0:
			return "ecology sampling empty plot has crop state"
		return ""
	var crop: CropData = known.get(id) as CropData
	if crop == null:
		return "ecology sampling crop id is unknown"
	if not raw.tilled or int(raw.growth_target) <= 0 or (raw.regrowing and crop.regrow_days <= 0):
		return "ecology sampling planted crop has invalid tilled/growth/regrow state"
	return ""

static func _integer(value: Variant, minimum: int) -> bool:
	if value is int:
		return value >= minimum and value <= INT32_MAX
	return value is float and is_finite(value) and value == floorf(value) and value >= minimum and value <= INT32_MAX

static func _owned(cell: Vector2i, regions: Array[Rect2i]) -> bool:
	for region: Rect2i in regions:
		if region.has_point(cell):
			return true
	return false

static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
