## EcologySnapshotCodec — strict independent wire validation; no owners or events.
## API: static decode(profile,raw); decode_metrics(profile,raw); valid_day(value).
class_name EcologySnapshotCodec
extends RefCounted

const MAX_JSON_INTEGER: int = 9007199254740991

static func valid_day(value: Variant) -> bool:
	if value is int:
		return value >= 0 and value <= MAX_JSON_INTEGER
	if value is float:
		return is_finite(value) and value >= 0.0 and value <= MAX_JSON_INTEGER and value == floorf(value)
	return false

static func decode_metrics(profile: EcologyProfile, raw: Variant) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty():
		return _failure("ecology requires a valid profile")
	if not raw is Dictionary or raw.size() != profile.metrics.size():
		return _failure("ecology metrics must contain the complete configured set")
	var values: Dictionary = {}
	for key: Variant in raw:
		if not EcologyMetricData.valid_id(key):
			return _failure("ecology metric key must be a known string id")
		var metric: EcologyMetricData = profile.get_metric(StringName(key))
		if metric == null or values.has(String(key)):
			return _failure("ecology metric key is unknown/duplicate")
		var value: Variant = raw[key]
		if not EcologyMetricData.number(value) or float(value) < metric.minimum or float(value) > metric.maximum:
			return _failure("ecology metric value must be finite within its configured range")
		values[String(key)] = float(value)
	return {"ok": true, "metrics": values}

static func decode(profile: EcologyProfile, raw: Variant) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty():
		return _failure("ecology requires a valid profile")
	if not raw is Dictionary or not valid_day(raw.get("day_index")):
		return _failure("ecology snapshot requires an exact nonnegative JSON-safe day")
	var decoded: Dictionary = decode_metrics(profile, raw.get("metrics"))
	if not decoded.ok:
		return decoded
	var saved: Variant = raw.get("triggered")
	if not saved is Array and not saved is PackedStringArray:
		return _failure("ecology triggered must be an array of known unique ids")
	var thresholds: Array[Dictionary] = profile.get_thresholds()
	var known: Dictionary = {}
	for row: Dictionary in thresholds:
		known[row.id] = true
	var seen: Dictionary = {}
	for id: Variant in saved:
		if not EcologyMetricData.valid_id(id) or not known.has(String(id)) or seen.has(String(id)):
			return _failure("ecology triggered contains an unknown/non-string/duplicate id")
		seen[String(id)] = true
	var triggered: Array[String] = []
	for row: Dictionary in thresholds:
		if seen.has(row.id):
			triggered.append(row.id)
	return {"ok": true, "snapshot": {"day_index": int(raw.day_index), "metrics": decoded.metrics, "triggered": triggered}}

static func _failure(message: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([message])}
