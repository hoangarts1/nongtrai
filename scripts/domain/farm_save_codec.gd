## FarmSaveCodec — stateless validated farm wire conversion; owner keeps the plots.
## API:
##   static func encode(plots: Dictionary) -> Dictionary
##   static func decode(data: Dictionary, crops: Dictionary, legacy: CropMigrationConfig) -> Dictionary
class_name FarmSaveCodec
extends RefCounted

static func encode(plots: Dictionary) -> Dictionary:
	var entries: Array[Dictionary] = []
	for cell: Vector2i in plots:
		var plot: Dictionary = plots[cell].duplicate(true)
		plot["cell_x"] = cell.x
		plot["cell_y"] = cell.y
		plot["crop_id"] = String(plot.get("crop_id", &""))
		entries.append(plot)
	return {"plots": entries}

static func decode(data: Dictionary, crops: Dictionary, legacy: CropMigrationConfig) -> Dictionary:
	var entries: Variant = data.get("plots", [])
	if not entries is Array:
		push_warning("FarmSaveCodec: malformed plots retained previous farm")
		return {"success": false, "plots": {}}
	var restored: Dictionary = {}
	for entry: Variant in entries:
		if not entry is Dictionary:
			push_warning("FarmSaveCodec: invalid plot ignored")
			continue
		var id: Variant = entry.get("crop_id", "")
		if not (id is String or id is StringName) or not _valid_integer(entry.get("cell_x", 0)) or not _valid_integer(entry.get("cell_y", 0)) or not _valid_integer(entry.get("growth_days", 0)):
			push_warning("FarmSaveCodec: invalid plot fields ignored")
			continue
		var crop_id: StringName = StringName(id)
		var crop: CropData = crops.get(crop_id) as CropData
		if not crop_id.is_empty() and crop == null:
			push_warning("FarmSaveCodec: unknown crop ignored")
			continue
		var cell: Vector2i = Vector2i(int(entry.get("cell_x", 0)), int(entry.get("cell_y", 0)))
		var limit: int = crop.max_consecutive_dry_days if crop != null and crop.water_need > 0 else 0
		var dry: int = _dry_count(entry.get("consecutive_dry_days", 0), limit)
		var raw_repeat: Variant = entry.get("regrowing", false)
		var repeating: bool = raw_repeat is bool and raw_repeat and crop != null and crop.regrow_days > 0
		var target: int = _target(entry.get("growth_target"), crop, repeating, legacy)
		var plot: Dictionary = {
			"tilled": entry.get("tilled", false) == true,
			"crop_id": crop_id,
			"growth_days": maxi(0, int(entry.get("growth_days", 0))),
			"growth_target": target,
			"regrowing": repeating,
			"watered": entry.get("watered", false) == true,
			"consecutive_dry_days": dry,
			"withered": entry.get("withered", false) == true or (limit > 0 and dry >= limit)
		}
		if plot["tilled"] or not crop_id.is_empty():
			restored[cell] = plot
	return {"success": true, "plots": restored}

static func _target(raw: Variant, crop: CropData, repeating: bool, legacy: CropMigrationConfig) -> int:
	if crop == null:
		return 0
	var fallback: int = crop.regrow_days if repeating else crop.growth_days
	if raw == null:
		return fallback
	var previous: int = int(legacy.previous_growth_days.get(crop.crop_id, fallback))
	if _valid_integer(raw) and (int(raw) == fallback or (not repeating and int(raw) == previous)):
		return int(raw)
	push_warning("FarmSaveCodec: invalid growth target uses current crop data")
	return fallback

static func _valid_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value)) and float(value) >= -2147483648.0 and float(value) <= 2147483647.0

static func _dry_count(value: Variant, limit: int) -> int:
	if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floorf(float(value)):
		push_warning("FarmSaveCodec: invalid dry counter defaults to zero")
		return 0
	return int(clampf(float(value), 0.0, float(limit)))
