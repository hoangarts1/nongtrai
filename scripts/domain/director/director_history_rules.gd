## DirectorHistoryRules - bounded immutable decision records and JSON-safe validation.
class_name DirectorHistoryRules
extends RefCounted

const REASONS: PackedStringArray = ["disabled", "locked", "observations_incomplete", "chosen", "forced", "no_event", "no_eligible_event", "pity_waiting_eligible", "forced_ineligible"]

static func empty_decision(day: int, reason: String = "disabled") -> Dictionary:
	return {"ok": true, "day_index": day, "event_id": "", "reason": reason, "seed_used": null, "rng_state": "", "event": {}, "trace": {}}

static func valid_decision(profile: DirectorProfile, raw: Variant, day: int) -> bool:
	if not raw is Dictionary or raw.size() != 8 or raw.get("ok") != true or not raw.get("ok") is bool or not DirectorActivityCodec.valid_integer(raw.get("day_index")) or int(raw.day_index) != day:
		return false
	for field: String in ["ok", "day_index", "event_id", "reason", "seed_used", "rng_state", "event", "trace"]:
		if not raw.has(field):
			return false
	if not raw.get("event_id") is String or not raw.get("reason") is String or not REASONS.has(raw.reason) or not raw.get("rng_state") is String or not raw.get("trace") is Dictionary or not raw.get("event") is Dictionary or not json_value(raw):
		return false
	if raw.seed_used != null and not DirectorActivityCodec.valid_integer(raw.seed_used):
		return false
	if raw.seed_used == null:
		if raw.rng_state != "":
			return false
	elif not raw.rng_state.is_valid_int() or str(raw.rng_state.to_int()) != raw.rng_state:
		return false
	if raw.event_id.is_empty():
		return raw.event.is_empty() and raw.reason not in ["chosen", "forced"]
	return raw.reason in ["chosen", "forced"] and raw.seed_used != null and DirectorScheduleRules.valid_terms(profile, raw.event) and raw.event.event_id == raw.event_id and int(raw.event.decision_day) == day

static func json_value(value: Variant, depth: int = 0) -> bool:
	if depth > 12:
		return false
	if value == null or value is bool:
		return true
	if value is int:
		return value >= -DirectorActivityCodec.MAX_JSON_INTEGER and value <= DirectorActivityCodec.MAX_JSON_INTEGER
	if value is float:
		return is_finite(value) and absf(value) <= DirectorActivityCodec.MAX_JSON_INTEGER
	if value is String or value is StringName:
		return value.length() <= 4096
	if value is Array:
		if value.size() > 128:
			return false
		for item: Variant in value:
			if not json_value(item, depth + 1):
				return false
		return true
	if value is Dictionary:
		if value.size() > 128:
			return false
		for key: Variant in value:
			if (not key is String and not key is StringName) or key.length() > 128 or not json_value(value[key], depth + 1):
				return false
		return true
	return false

static func copy_json(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key: Variant in value:
			result[String(key)] = copy_json(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(copy_json(item))
		return result
	if value is StringName:
		return String(value)
	if value is float and value == floorf(value):
		return int(value)
	return value

static func append(profile: DirectorProfile, snapshot: Dictionary, decision: Dictionary) -> void:
	snapshot.history.append(decision.duplicate(true))
	while snapshot.history.size() > profile.history_limit:
		snapshot.history.pop_front()
