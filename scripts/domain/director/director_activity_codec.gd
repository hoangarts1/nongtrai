## DirectorActivityCodec — strict detached observation wire; no clocks/Nodes/events.
## API: static decode(config,raw)->Dictionary; valid_integer(value)->bool; empty_counts(config).
class_name DirectorActivityCodec
extends RefCounted

const MAX_JSON_INTEGER: int = 9007199254740991

static func valid_integer(value: Variant) -> bool:
	if value is int:
		return value >= 0 and value <= MAX_JSON_INTEGER
	return value is float and is_finite(value) and value >= 0.0 and value <= MAX_JSON_INTEGER and value == floorf(value)

static func empty_counts(config: DirectorActivityConfig) -> Dictionary:
	var counts: Dictionary = {}
	if config != null:
		for id: String in config.activity_ids:
			counts[id] = 0
	return counts

static func decode(config: DirectorActivityConfig, raw: Variant) -> Dictionary:
	if config == null or not config.validation_errors().is_empty():
		return _failure("director activity requires a valid config")
	if not raw is Dictionary or raw.size() != 5 or not valid_integer(raw.get("current_day")) or not valid_integer(raw.get("started_day")) or not raw.get("current_complete") is bool or not raw.get("completed_days") is Array:
		return _failure("director activity requires complete day/coverage/history fields")
	var day: int = int(raw.current_day)
	var start: int = int(raw.started_day)
	if start > day or raw.completed_days.size() != mini(config.window_days, day - start):
		return _failure("director activity history does not match observed day span")
	var current: Dictionary = _counts(config, raw.get("current_counts"))
	if not current.ok:
		return current
	var total: Dictionary = current.counts.duplicate()
	var completed: Array[Dictionary] = []
	var expected: int = day - raw.completed_days.size()
	for value: Variant in raw.completed_days:
		if not value is Dictionary or value.size() != 3 or not valid_integer(value.get("day_index")) or int(value.day_index) != expected or not value.get("complete") is bool:
			return _failure("director activity completed days must be ordered adjacent observations")
		var decoded: Dictionary = _counts(config, value.get("counts"))
		if not decoded.ok:
			return decoded
		for id: String in config.activity_ids:
			if int(decoded.counts[id]) > MAX_JSON_INTEGER - int(total[id]):
				return _failure("director activity window count overflow")
			total[id] += int(decoded.counts[id])
		completed.append({"day_index": expected, "complete": value.complete, "counts": decoded.counts})
		expected += 1
	return {"ok": true, "snapshot": {"current_day": day, "started_day": start, "current_complete": raw.current_complete, "current_counts": current.counts, "completed_days": completed}}

static func _counts(config: DirectorActivityConfig, raw: Variant) -> Dictionary:
	if not raw is Dictionary or raw.size() != config.activity_ids.size():
		return _failure("director activity requires all configured counts")
	var counts: Dictionary = {}
	for key: Variant in raw:
		if not DirectorActivityConfig.valid_id(key) or not config.activity_ids.has(String(key)) or counts.has(String(key)) or not valid_integer(raw[key]):
			return _failure("director activity count must be a known exact nonnegative JSON integer")
		counts[String(key)] = int(raw[key])
	return {"ok": true, "counts": counts}

static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([reason])}
