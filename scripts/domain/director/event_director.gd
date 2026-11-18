## EventDirector — pure tagged weighted choice, captured terms and an honest trace.
## API: static decide(profile,snapshot,context,force_id=&"")->Dictionary;
## event_terms(event,decision_day)->Dictionary. No state, Nodes or global randomness.
class_name EventDirector
extends RefCounted

static func decide(profile: DirectorProfile, snapshot: Dictionary, context: Variant, force_id: StringName = &"") -> Dictionary:
	var trace: Dictionary = DirectorCandidateRules.evaluate(profile, snapshot, context)
	if not trace.ok:
		return trace
	var result: Dictionary = {"ok": true, "day_index": int(snapshot.day_index), "event_id": "", "reason": String(trace.reason), "seed_used": null, "rng_state": "", "event": {}, "trace": trace.duplicate(true)}
	if not trace.ready:
		return result
	var choices: Array[Dictionary] = []
	for row: Dictionary in trace.candidates:
		if row.eligible:
			choices.append(row)
	if not force_id.is_empty():
		var eligible: bool = false
		for row: Dictionary in choices:
			if row.id == String(force_id):
				eligible = true
		if not eligible:
			return {"ok": false, "reason": &"forced_ineligible", "trace": trace}
	if choices.is_empty():
		result.reason = "pity_waiting_eligible" if trace.pity_due else "no_eligible_event"
		return result
	var rng: RandomNumberGenerator = DetRandom.make_rng(int(snapshot.world_seed), int(snapshot.day_index), DetRandom.TAG_DIRECTOR)
	result.seed_used = rng.seed
	var selected: StringName = force_id
	if force_id.is_empty():
		var pick: float = rng.randf() * float(trace.total_weight)
		var cursor: float = float(trace.no_event_weight)
		if pick >= cursor:
			for row: Dictionary in choices:
				cursor += float(row.score)
				if pick < cursor:
					selected = StringName(row.id)
					break
			# randf can include its upper endpoint; stay within the last interval.
			if selected.is_empty():
				selected = StringName(choices.back().id)
	result.rng_state = str(rng.state)
	result.trace["forced"] = not force_id.is_empty()
	if not selected.is_empty():
		result.event_id = String(selected)
		result.event = event_terms(profile.get_event(selected), int(snapshot.day_index))
		result.reason = "forced" if not force_id.is_empty() else "chosen"
	else:
		result.reason = "no_event"
	return result

static func event_terms(event: DirectorEventData, decision_day: int) -> Dictionary:
	var start: int = decision_day + event.telegraph_days
	return {"event_id": String(event.id), "decision_day": decision_day, "start_day": start, "end_day": start + event.duration_days, "is_negative": event.is_negative, "mutex_group": String(event.mutex_group), "cooldown_until": start + event.cooldown_days, "title_key": String(event.title_key), "explanation_key": String(event.explanation_key), "counter_hint_key": String(event.counter_hint_key), "effect": (event.effects[0] as DirectorEffectData).terms()}
