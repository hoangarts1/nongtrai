## DirectorSnapshot — detached validated observations; never infers missing activity.
## API: static capture(profile,clock,ecology,activity,weather,gates); valid(profile,snapshot);
## calendar(profile,day)->Dictionary; ACTIVITY is the actual configured observation window.
class_name DirectorSnapshot
extends RefCounted

const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const GATES: PackedStringArray = ["enabled", "story_unlocked", "debug_preview", "busy"]
const MINUTES_PER_DAY: int = 1440

static func capture(profile: DirectorProfile, clock: Variant, ecology: Variant, activity: Variant, weather: Variant, gates: Variant) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty():
		return _failure(&"invalid_profile")
	if not gates is Dictionary or gates.size() != GATES.size():
		return _failure(&"invalid_gates")
	for id: String in GATES:
		if not gates.get(id) is bool:
			return _failure(&"invalid_gates")
	if gates.busy:
		return _failure(&"busy")
	if not clock is Dictionary or clock.size() != 4 or not DirectorActivityCodec.valid_integer(clock.get("day_index")) or not DirectorActivityCodec.valid_integer(clock.get("minute")) or not DirectorActivityCodec.valid_integer(clock.get("year")):
		return _failure(&"invalid_clock")
	var day: int = int(clock.day_index)
	var season: Dictionary = calendar(profile, day)
	if not season.ok or int(season.end_day) > DirectorActivityCodec.MAX_JSON_INTEGER or clock.get("season") != season.season_id or int(clock.year) != int(season.year) or int(clock.minute) >= MINUTES_PER_DAY * 2:
		return _failure(&"inconsistent_calendar")
	if not ecology is Dictionary or ecology.size() != 2:
		return _failure(&"invalid_ecology")
	var eco: Dictionary = EcologySnapshotCodec.decode(profile.ecology, ecology.get("state"))
	var available: Variant = ecology.get("available")
	if not eco.ok or int(eco.snapshot.day_index) != day or not available is Dictionary or available.size() != profile.ecology.metrics.size():
		return _failure(&"invalid_or_stale_ecology")
	var availability: Dictionary = {}
	for metric: EcologyMetricData in profile.ecology.metrics:
		var id: String = String(metric.metric_id)
		if not available.get(id) is bool or (id == "water_clarity" and bool(available[id])):
			return _failure(&"invalid_metric_availability")
		availability[id] = bool(available[id])
	var observed: Dictionary = DirectorActivityCodec.decode(ACTIVITY, activity)
	if not weather is Dictionary or weather.size() != 4:
		return _failure(&"invalid_weather")
	var forecast: Dictionary = WeatherSnapshotCodec.decode_at_day(profile.weather, weather, day)
	if not observed.ok or int(observed.snapshot.current_day) != day or not forecast.ok:
		return _failure(&"invalid_or_stale_activity_weather")
	var observations: Dictionary = _observations(observed.snapshot)
	var enabled: bool = gates.enabled and (gates.story_unlocked or gates.debug_preview)
	var ready: bool = enabled and observations.available
	var reason: StringName = &"ready" if ready else (&"disabled" if not gates.enabled else (&"locked" if not enabled else &"observations_incomplete"))
	var canonical_clock: Dictionary = {"day_index": day, "minute": int(clock.minute), "season": season.season_id, "year": int(clock.year)}
	var canonical_gates: Dictionary = {}
	for key: String in GATES:
		canonical_gates[key] = bool(gates[key])
	var normal: Dictionary = {}
	for resource: Resource in profile.npc_world.npcs:
		var npc: NpcData = resource as NpcData
		if npc == null:
			return _failure(&"invalid_npc_context")
		if npc.is_merchant:
			var visit: Dictionary = _regular_visit(profile, npc, day, StringName(season.season_id))
			if not visit.ok:
				return _failure(&"invalid_npc_context")
			normal[String(npc.npc_id)] = visit.regular
	return {"ok": true, "ready": ready, "reason": reason, "day_index": day, "world_seed": int(forecast.snapshot.world_seed), "clock": canonical_clock.duplicate(), "calendar": season, "metrics": eco.snapshot.metrics.duplicate(), "available": availability.duplicate(), "activity": observations, "weather": forecast.snapshot.duplicate(true), "merchant_regular": normal,
		"source": {"clock": canonical_clock, "ecology": {"state": eco.snapshot, "available": availability}, "activity": observed.snapshot, "weather": forecast.snapshot, "gates": canonical_gates}}

static func valid(profile: DirectorProfile, snapshot: Dictionary) -> bool:
	var source: Variant = snapshot.get("source")
	if not source is Dictionary or source.size() != 5:
		return false
	var rebuilt: Dictionary = capture(profile, source.get("clock"), source.get("ecology"), source.get("activity"), source.get("weather"), source.get("gates"))
	return rebuilt.get("ok", false) and _same(rebuilt, snapshot)

static func _same(expected: Variant, actual: Variant) -> bool:
	# JSON reads integers as doubles. Compare exact values without accepting bools,
	# fractions, missing fields or an epsilon around gameplay thresholds.
	if expected is Dictionary:
		if not actual is Dictionary or expected.size() != actual.size():
			return false
		for key: Variant in expected:
			if not actual.has(key) or not _same(expected[key], actual[key]):
				return false
		return true
	if expected is Array or expected is PackedStringArray:
		if (not actual is Array and not actual is PackedStringArray) or expected.size() != actual.size():
			return false
		for index: int in range(expected.size()):
			if not _same(expected[index], actual[index]):
				return false
		return true
	if expected is int:
		return EcologyMetricData.number(actual) and absf(float(actual)) <= DirectorActivityCodec.MAX_JSON_INTEGER and float(actual) == floorf(float(actual)) and int(actual) == int(expected)
	if expected is float:
		return EcologyMetricData.number(actual) and float(actual) == float(expected)
	if expected is String or expected is StringName:
		return (actual is String or actual is StringName) and String(actual) == String(expected)
	return typeof(expected) == typeof(actual) and expected == actual

@warning_ignore("integer_division")
static func calendar(profile: DirectorProfile, day: int) -> Dictionary:
	if profile == null or not DirectorActivityCodec.valid_integer(day) or not profile.validation_errors().is_empty():
		return _failure(&"invalid_calendar")
	var year_days: int = 0
	for season: SeasonData in profile.seasons:
		year_days += season.days_in_season
	var cycles: int = day / year_days
	var start: int = cycles * year_days
	for index: int in range(profile.seasons.size()):
		var season: SeasonData = profile.seasons[index] as SeasonData
		var end: int = start + season.days_in_season
		if day < end:
			return {"ok": true, "season_id": String(season.season_id), "start_day": start, "end_day": end, "year": cycles + 1, "ordinal": cycles * profile.seasons.size() + index}
		start = end
	return _failure(&"invalid_calendar")

static func _observations(raw: Dictionary) -> Dictionary:
	var complete: int = 0
	var totals: Dictionary = DirectorActivityCodec.empty_counts(ACTIVITY)
	var active_days: Dictionary = DirectorActivityCodec.empty_counts(ACTIVITY)
	for row: Dictionary in raw.completed_days:
		if row.complete:
			complete += 1
		for id: String in ACTIVITY.activity_ids:
			totals[id] += int(row.counts[id])
			if int(row.counts[id]) > 0:
				active_days[id] += 1
	var available: bool = raw.completed_days.size() == ACTIVITY.window_days and complete == ACTIVITY.window_days
	var frequency: Dictionary = {}
	if available:
		for id: String in ACTIVITY.activity_ids:
			frequency[id] = float(active_days[id]) / float(ACTIVITY.window_days)
	return {"available": available, "window_days": ACTIVITY.window_days, "observed_days": raw.completed_days.size(), "complete_days": complete, "totals": totals if available else {}, "frequencies": frequency}

static func _regular_visit(profile: DirectorProfile, npc: NpcData, day: int, season: StringName) -> Dictionary:
	var weekday: int = posmod(day, profile.npc_world.days_per_week) + 1
	var regular: bool = false
	for resource: Resource in npc.schedule:
		var entry: NpcScheduleEntry = resource as NpcScheduleEntry
		if entry == null or entry.start_minute < 0 or entry.end_minute <= entry.start_minute or entry.end_minute > MINUTES_PER_DAY * 2:
			return {"ok": false}
		for value: int in entry.weekdays:
			if value < 1 or value > profile.npc_world.days_per_week:
				return {"ok": false}
		if (entry.seasons.is_empty() or entry.seasons.has(String(season))) and (entry.weekdays.is_empty() or entry.weekdays.has(weekday)):
			regular = true
	return {"ok": true, "regular": regular}

static func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
