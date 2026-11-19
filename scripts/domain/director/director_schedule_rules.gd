## DirectorScheduleRules - pure captured schedule validation and expiry.
## API: valid_terms(profile,raw)->bool; advance(snapshot,day)->Dictionary;
## context(snapshot)->Dictionary; book(profile,snapshot,event)->void.
class_name DirectorScheduleRules
extends RefCounted

static func valid_terms(profile: DirectorProfile, raw: Variant) -> bool:
	if not raw is Dictionary or raw.size() != 11 or not EcologyMetricData.valid_id(raw.get("event_id")):
		return false
	var event: DirectorEventData = profile.get_event(StringName(raw.event_id))
	if event == null:
		return false
	for key: String in ["decision_day", "start_day", "end_day", "cooldown_until"]:
		if not DirectorActivityCodec.valid_integer(raw.get(key)):
			return false
	var day: int = int(raw.decision_day)
	if day > DirectorActivityCodec.MAX_JSON_INTEGER - event.telegraph_days - maxi(event.duration_days, event.cooldown_days):
		return false
	# These are the captured terms of this catalogue version, never rerolled on restore.
	return DirectorSnapshot._same(raw, EventDirector.event_terms(event, day))

static func advance(snapshot: Dictionary, day: int) -> Dictionary:
	var result: Dictionary = snapshot.duplicate(true)
	var active: Array[Dictionary] = []
	var pending: Array[Dictionary] = []
	for event: Dictionary in result.active + result.pending:
		if int(event.end_day) <= day:
			continue
		if int(event.start_day) > day:
			pending.append(event)
		else:
			active.append(event)
			if event.is_negative:
				result.last_negative_start = int(event.start_day) if result.last_negative_start == null else maxi(int(result.last_negative_start), int(event.start_day))
	result.active = active
	result.pending = pending
	result.day_index = day
	return result

static func context(snapshot: Dictionary) -> Dictionary:
	var result: Dictionary = DirectorCandidateRules.fresh_context(int(snapshot.enabled_day))
	for key: String in ["last_positive_day", "last_negative_start", "cooldowns", "season_usage", "event_usage"]:
		result[key] = snapshot[key].duplicate(true) if snapshot[key] is Dictionary else snapshot[key]
	for event: Dictionary in snapshot.pending + snapshot.active:
		result.scheduled.append({"event_id": event.event_id, "start_day": event.start_day, "end_day": event.end_day, "is_negative": event.is_negative, "mutex_group": event.mutex_group})
	return result

static func book(profile: DirectorProfile, snapshot: Dictionary, event: Dictionary) -> void:
	var id: String = event.event_id
	var season: String = str(int(DirectorSnapshot.calendar(profile, int(event.start_day)).start_day))
	if not snapshot.event_usage.has(id):
		snapshot.event_usage[id] = {}
	snapshot.event_usage[id][season] = int(snapshot.event_usage[id].get(season, 0)) + 1
	if event.is_negative:
		snapshot.season_usage[season] = int(snapshot.season_usage.get(season, 0)) + 1
	else:
		snapshot.last_positive_day = int(event.start_day)
	snapshot.cooldowns[id] = int(event.cooldown_until)
	if int(event.start_day) > int(snapshot.day_index):
		snapshot.pending.append(event.duplicate(true))
	else:
		snapshot.active.append(event.duplicate(true))
		if event.is_negative:
			snapshot.last_negative_start = int(event.start_day)
	# A still-active cross-season event retains its original booking until expiry.
	var current: int = int(DirectorSnapshot.calendar(profile, int(snapshot.day_index)).start_day)
	var retained: Dictionary = {}
	for scheduled: Dictionary in snapshot.active + snapshot.pending:
		retained[str(int(DirectorSnapshot.calendar(profile, int(scheduled.start_day)).start_day))] = true
	for usage: Dictionary in [snapshot.season_usage] + snapshot.event_usage.values():
		for key: String in usage.keys():
			if key.to_int() < current and not retained.has(key):
				usage.erase(key)
