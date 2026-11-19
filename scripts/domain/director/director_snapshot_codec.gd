## DirectorSnapshotCodec - strict detached owner wire; no draw, mutation or replay.
## API: baseline(day)->Dictionary; decode(profile,raw)->Dictionary.
class_name DirectorSnapshotCodec
extends RefCounted

const FIELDS: PackedStringArray = ["day_index", "started_day", "enabled", "enabled_day", "last_positive_day", "last_negative_start", "cooldowns", "season_usage", "event_usage", "pending", "active", "forced", "history"]

static func baseline(day: int) -> Dictionary:
	return {"day_index": day, "started_day": day, "enabled": false, "enabled_day": day, "last_positive_day": null, "last_negative_start": null, "cooldowns": {}, "season_usage": {}, "event_usage": {}, "pending": [], "active": [], "forced": "", "history": []}

static func decode(profile: DirectorProfile, raw: Variant) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty() or not raw is Dictionary or raw.size() != FIELDS.size():
		return _failure("invalid director profile/wire")
	for field: String in FIELDS:
		if not raw.has(field):
			return _failure("missing director field")
	if not DirectorActivityCodec.valid_integer(raw.day_index) or not DirectorActivityCodec.valid_integer(raw.started_day) or int(raw.started_day) > int(raw.day_index) or not raw.enabled is bool or not raw.forced is String or (not raw.forced.is_empty() and profile.get_event(StringName(raw.forced)) == null):
		return _failure("invalid director day/gate/force")
	var day: int = int(raw.day_index)
	if not raw.pending is Array or not raw.active is Array or not raw.history is Array or raw.history.size() != mini(profile.history_limit, day - int(raw.started_day)):
		return _failure("invalid director schedule/history span")
	if not raw.enabled and (not raw.pending.is_empty() or not raw.active.is_empty() or not raw.forced.is_empty()):
		return _failure("disabled director cannot apply or force events")
	var context: Dictionary = {"enabled_day": raw.enabled_day, "last_positive_day": raw.last_positive_day, "last_negative_start": raw.last_negative_start, "cooldowns": raw.cooldowns, "season_usage": raw.season_usage, "event_usage": raw.event_usage, "scheduled": []}
	if not DirectorCandidateRules.valid_context(profile, day, context):
		return _failure("invalid director counters")
	var seen: Dictionary = {}
	var scheduled: Array[Dictionary] = []
	for group: String in ["pending", "active"]:
		if raw[group].size() > profile.events.size():
			return _failure("too many scheduled events")
		for event: Variant in raw[group]:
			if not DirectorScheduleRules.valid_terms(profile, event) or seen.has(event.event_id) or int(event.decision_day) > day or int(event.end_day) <= day or ((int(event.start_day) > day) != (group == "pending")):
				return _failure("invalid captured scheduled terms")
			for other: Dictionary in scheduled:
				if other.mutex_group == event.mutex_group and int(other.start_day) < int(event.end_day) and int(event.start_day) < int(other.end_day):
					return _failure("conflicting schedules")
			seen[event.event_id] = true
			scheduled.append(event)
			var season: String = str(int(DirectorSnapshot.calendar(profile, int(event.start_day)).start_day))
			if int(raw.cooldowns.get(event.event_id, 0)) < int(event.cooldown_until) or int((raw.event_usage.get(event.event_id, {}) as Dictionary).get(season, 0)) <= 0 or (event.is_negative and int(raw.season_usage.get(season, 0)) <= 0):
				return _failure("unbooked schedule")
	var expected: int = day - raw.history.size() + 1
	var minimum_usage: Dictionary = {}
	var minimum_negative: Dictionary = {}
	var current_season: int = int(DirectorSnapshot.calendar(profile, day).start_day)
	var previous: Dictionary = {}
	var negative_start: int = -1
	var recorded: Dictionary = {}
	for decision: Variant in raw.history:
		if not DirectorHistoryRules.valid_decision(profile, decision, expected):
			return _failure("invalid ordered decision history")
		expected += 1
		if not decision.event.is_empty():
			var event: Dictionary = decision.event
			if previous.has(event.event_id) and int(event.start_day) < int(previous[event.event_id]):
				return _failure("history violated cooldown")
			previous[event.event_id] = int(event.cooldown_until)
			if int(raw.cooldowns.get(event.event_id, 0)) < int(event.cooldown_until):
				return _failure("history cooldown was lost")
			if event.is_negative:
				if (negative_start >= 0 and int(event.start_day) - negative_start < profile.min_negative_gap) or (int(event.decision_day) >= int(raw.enabled_day) and int(event.start_day) - int(raw.enabled_day) < profile.grace_days):
					return _failure("history violated negative grace/spacing")
				negative_start = int(event.start_day)
			recorded[str(int(event.decision_day))] = event
			var season: String = str(int(DirectorSnapshot.calendar(profile, int(event.start_day)).start_day))
			if season.to_int() >= current_season:
				var key: String = event.event_id + ":" + season
				minimum_usage[key] = int(minimum_usage.get(key, 0)) + 1
				if event.is_negative:
					minimum_negative[season] = int(minimum_negative.get(season, 0)) + 1
	for key: String in minimum_usage:
		var parts: PackedStringArray = key.split(":")
		if int((raw.event_usage.get(parts[0], {}) as Dictionary).get(parts[1], 0)) < int(minimum_usage[key]):
			return _failure("history usage was lost")
	for season: String in minimum_negative:
		if int(raw.season_usage.get(season, 0)) < int(minimum_negative[season]):
			return _failure("negative reservations were lost")
	for event: Dictionary in scheduled:
		if int(event.decision_day) >= day - raw.history.size() + 1 and not DirectorSnapshot._same(recorded.get(str(int(event.decision_day))), event):
			return _failure("scheduled event has no committed decision")
	# JSON normalization detaches every primitive; RNG state remains its exact string.
	return {"ok": true, "snapshot": DirectorHistoryRules.copy_json(raw)}

static func _failure(message: String) -> Dictionary:
	return {"ok": false, "errors": PackedStringArray([message])}
