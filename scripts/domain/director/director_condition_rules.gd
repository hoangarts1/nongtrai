## DirectorConditionRules — current measured levels and saved start-day weather only.
## API: static evaluate(profile,event,snapshot)->Dictionary{eligible,reason,details}.
class_name DirectorConditionRules
extends RefCounted

static func evaluate(profile: DirectorProfile, event: DirectorEventData, snapshot: Dictionary) -> Dictionary:
	if not DirectorSnapshot.valid(profile, snapshot) or event == null or not event.validation_errors(profile.ecology, profile.npc_world, profile.weather).is_empty():
		return {"eligible": false, "reason": &"invalid_observations", "details": []}
	if not snapshot.ready:
		return {"eligible": false, "reason": snapshot.reason, "details": []}
	var details: Array[Dictionary] = []
	var reason: StringName = &"eligible"
	for condition: DirectorConditionData in event.conditions:
		var result: Dictionary = _one(profile, condition, event, snapshot)
		details.append(result)
		if not result.passed and reason == &"eligible":
			reason = result.reason
	return {"eligible": reason == &"eligible", "reason": reason, "details": details}

static func _one(profile: DirectorProfile, condition: DirectorConditionData, event: DirectorEventData, snapshot: Dictionary) -> Dictionary:
	var passed: bool = false
	var reason: StringName = &"condition_failed"
	if String(condition.kind).begins_with("metric_"):
		var id: String = String(condition.metric_id)
		if not bool(snapshot.available.get(id, false)):
			return {"kind": String(condition.kind), "passed": false, "reason": &"metric_unavailable"}
		for row: Dictionary in profile.ecology.get_thresholds():
			if row.metric_id == id and row.id == String(condition.threshold_id):
				passed = float(snapshot.metrics[id]) >= float(row.value) if condition.kind == &"metric_min" else float(snapshot.metrics[id]) < float(row.value)
				reason = &"threshold"
	elif condition.kind == &"dry_start":
		var offset: int = event.telegraph_days
		var id: StringName = StringName(snapshot.weather.today if offset == 0 else snapshot.weather.forecast[offset - 1])
		passed = not bool(profile.weather.get_entry(id).rain)
		reason = &"rain_at_start"
	elif condition.kind == &"extra_visit":
		var effect: DirectorEffectData = event.effects[0] as DirectorEffectData
		passed = not bool(snapshot.merchant_regular.get(String(effect.npc_id), true))
		reason = &"regular_visit"
	return {"kind": String(condition.kind), "passed": passed, "reason": &"passed" if passed else reason}
