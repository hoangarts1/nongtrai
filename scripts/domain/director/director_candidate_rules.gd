## DirectorCandidateRules — pure bounded filters/scores/trace, without RNG or owners.
class_name DirectorCandidateRules
extends RefCounted

const CONTEXT_FIELDS: PackedStringArray = ["enabled_day", "last_positive_day", "last_negative_start", "cooldowns", "season_usage", "event_usage", "scheduled"]

static func fresh_context(enabled_day: int) -> Dictionary:
	return {"enabled_day": enabled_day, "last_positive_day": null, "last_negative_start": null, "cooldowns": {}, "season_usage": {}, "event_usage": {}, "scheduled": []}

static func evaluate(profile: DirectorProfile, snapshot: Dictionary, context: Variant) -> Dictionary:
	if not DirectorSnapshot.valid(profile, snapshot):
		return {"ok": false, "reason": &"invalid_snapshot"}
	var rows: Array[Dictionary] = []
	if not snapshot.ready:
		for event: DirectorEventData in profile.events:
			rows.append({"id": String(event.id), "eligible": false, "reason": String(snapshot.reason), "score": 0.0, "conditions": [], "checks": {}})
		return {"ok": true, "ready": false, "reason": String(snapshot.reason), "candidates": rows, "pity_due": false, "pity": false, "no_event_weight": 0.0, "total_weight": 0.0}
	if not valid_context(profile, int(snapshot.day_index), context):
		return {"ok": false, "reason": &"invalid_context"}
	var positive: bool = false
	for event: DirectorEventData in profile.events:
		var row: Dictionary = _candidate(profile, event, snapshot, context)
		rows.append(row)
		if row.eligible and not event.is_negative and float(row.score) > 0.0:
			positive = true
	var since: int = int(context.enabled_day) if context.last_positive_day == null else int(context.last_positive_day)
	var due: bool = int(snapshot.day_index) - since >= profile.pity_days
	var none_weight: float = 0.0 if due and positive else profile.no_event_weight
	var total: float = none_weight
	for row: Dictionary in rows:
		if due and profile.get_event(StringName(row.id)).is_negative and row.eligible:
			row.eligible = false
			row.reason = "positive_pity" if positive else "pity_waiting_eligible"
			row.score = 0.0
		total += float(row.score)
	if not is_finite(total) or total <= 0.0:
		return {"ok": false, "reason": &"invalid_total_weight"}
	return {"ok": true, "ready": true, "reason": "pity_waiting_eligible" if due and not positive else "ready", "candidates": rows, "pity_due": due, "pity": due and positive, "no_event_weight": none_weight, "total_weight": total}

static func _candidate(profile: DirectorProfile, event: DirectorEventData, snapshot: Dictionary, context: Dictionary) -> Dictionary:
	var condition: Dictionary = DirectorConditionRules.evaluate(profile, event, snapshot)
	var reason: String = String(condition.reason)
	var checks: Dictionary = {}
	var day: int = int(snapshot.day_index)
	var maximum: int = DirectorActivityCodec.MAX_JSON_INTEGER
	var safe: bool = day <= maximum - event.telegraph_days and day + event.telegraph_days <= maximum - maxi(event.duration_days, event.cooldown_days)
	checks.headroom = safe
	if not safe:
		return {"id": String(event.id), "eligible": false, "reason": "day_overflow", "score": 0.0, "conditions": condition.details, "checks": checks}
	var start: int = day + event.telegraph_days
	var end: int = start + event.duration_days
	var season: Dictionary = DirectorSnapshot.calendar(profile, start)
	var season_key: String = str(int(season.start_day))
	checks.cooldown = start >= int(context.cooldowns.get(String(event.id), 0))
	checks.event_cap = event.max_per_season == 0 or int((context.event_usage.get(String(event.id), {}) as Dictionary).get(season_key, 0)) < event.max_per_season
	checks.grace = not event.is_negative or start - int(context.enabled_day) >= profile.grace_days
	checks.negative_cap = not event.is_negative or int(context.season_usage.get(season_key, 0)) < profile.max_negative_per_season
	checks.negative_spacing = not event.is_negative or context.last_negative_start == null or start - int(context.last_negative_start) >= profile.min_negative_gap
	checks.conflict = true
	for scheduled: Dictionary in context.scheduled:
		if scheduled.mutex_group == String(event.mutex_group) and start < int(scheduled.end_day) and int(scheduled.start_day) < end:
			checks.conflict = false
		if event.is_negative and scheduled.is_negative and absi(start - int(scheduled.start_day)) < profile.min_negative_gap:
			checks.negative_spacing = false
	for key: String in ["cooldown", "event_cap", "grace", "negative_cap", "negative_spacing", "conflict"]:
		if not checks[key] and reason == "eligible":
			reason = key
	var bonus: float = 0.0
	if not event.activity_affinities.is_empty():
		for activity: String in event.activity_affinities:
			bonus += float(snapshot.activity.frequencies[activity])
		bonus = profile.activity_bonus_max * bonus / float(event.activity_affinities.size())
	var score: float = event.weight + bonus
	var eligible: bool = reason == "eligible" and is_finite(score) and score > 0.0
	return {"id": String(event.id), "eligible": eligible, "reason": reason if eligible or reason != "eligible" else "zero_weight", "score": score if eligible else 0.0, "base_weight": event.weight, "activity_bonus": bonus, "start_day": start, "end_day": end, "season_start": int(season.start_day), "conditions": condition.details, "checks": checks}

static func valid_context(profile: DirectorProfile, day: int, raw: Variant) -> bool:
	if not raw is Dictionary or raw.size() != CONTEXT_FIELDS.size():
		return false
	for field: String in CONTEXT_FIELDS:
		if not raw.has(field):
			return false
	if not DirectorActivityCodec.valid_integer(raw.enabled_day) or int(raw.enabled_day) > day:
		return false
	for field: String in ["last_positive_day", "last_negative_start"]:
		if raw[field] != null and (not DirectorActivityCodec.valid_integer(raw[field]) or int(raw[field]) > day):
			return false
	if not raw.cooldowns is Dictionary or not raw.event_usage is Dictionary or not raw.season_usage is Dictionary or not raw.scheduled is Array:
		return false
	if raw.cooldowns.size() > profile.events.size() or raw.event_usage.size() > profile.events.size() or raw.scheduled.size() > profile.history_limit:
		return false
	for id: Variant in raw.cooldowns:
		if not EcologyMetricData.valid_id(id) or profile.get_event(StringName(id)) == null or not DirectorActivityCodec.valid_integer(raw.cooldowns[id]):
			return false
	if not _usage(profile, raw.season_usage, profile.max_negative_per_season):
		return false
	for id: Variant in raw.event_usage:
		if not EcologyMetricData.valid_id(id) or profile.get_event(StringName(id)) == null or not _usage(profile, raw.event_usage[id], profile.get_event(StringName(id)).max_per_season):
			return false
	var seen: Dictionary = {}
	for row: Variant in raw.scheduled:
		if not row is Dictionary or row.size() != 5 or not EcologyMetricData.valid_id(row.get("event_id")):
			return false
		var event: DirectorEventData = profile.get_event(StringName(row.event_id))
		if event == null or not DirectorActivityCodec.valid_integer(row.get("start_day")) or not DirectorActivityCodec.valid_integer(row.get("end_day")) or int(row.end_day) <= int(row.start_day) or not row.get("is_negative") is bool or row.is_negative != event.is_negative or row.get("mutex_group") != String(event.mutex_group) or seen.has(String(row.event_id)):
			return false
		seen[String(row.event_id)] = true
	return true

static func _usage(profile: DirectorProfile, raw: Variant, cap: int) -> bool:
	if not raw is Dictionary or raw.size() > profile.history_limit:
		return false
	for key: Variant in raw:
		if not key is String or not key.is_valid_int() or str(key.to_int()) != key or not DirectorActivityCodec.valid_integer(key.to_int()) or not DirectorActivityCodec.valid_integer(raw[key]) or (cap > 0 and int(raw[key]) > cap):
			return false
		var season: Dictionary = DirectorSnapshot.calendar(profile, key.to_int())
		if not season.ok or int(season.start_day) != key.to_int():
			return false
	return true
