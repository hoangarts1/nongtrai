## DirectorEffectProjector - reversible actual-day projection, without world mutations.
## API: project(profile,owner,observation)->Dictionary.
class_name DirectorEffectProjector
extends RefCounted

static func project(profile: DirectorProfile, owner: Variant, observation: Dictionary) -> Dictionary:
	var decoded: Dictionary = DirectorSnapshotCodec.decode(profile, owner)
	if not decoded.ok or not DirectorSnapshot.valid(profile, observation) or int(decoded.snapshot.day_index) != int(observation.day_index):
		return {"ok": false, "reason": &"invalid_effect_context"}
	var day: int = int(observation.day_index)
	var gates: Dictionary = observation.source.gates
	var enabled: bool = decoded.snapshot.enabled and gates.enabled and (gates.story_unlocked or gates.debug_preview)
	var result: Dictionary = {"ok": true, "day_index": day, "enabled": enabled, "water": {"day_index": day, "event": {}}, "visitor": {}, "accent": [], "event_ids": [], "dust_reason": "inactive"}
	if not enabled:
		return result
	for captured: Dictionary in decoded.snapshot.active:
		var checked: Dictionary = DirectorEffectTermsCodec.active(profile, captured, day)
		if not checked.ok:
			return {"ok": false, "reason": &"invalid_active_effect"}
		var event: Dictionary = checked.event
		var terms: Dictionary = event.effect
		result.event_ids.append(event.event_id)
		match String(terms.kind):
			"extra_water_charge":
				var available: bool = bool(observation.available[terms.exempt_metric_id])
				var sheltered: bool = false
				for threshold: Dictionary in profile.ecology.get_thresholds():
					if threshold.metric_id == terms.exempt_metric_id and threshold.id == terms.exempt_threshold_id:
						sheltered = available and float(observation.metrics[terms.exempt_metric_id]) >= float(threshold.value)
				var rainy: bool = bool(profile.weather.get_entry(StringName(observation.weather.today)).get("rain", false))
				result.dust_reason = "canopy_unmeasured" if not available else ("rain" if rainy and terms.waive_rain else ("canopy" if sheltered else "extra_charge"))
				if result.dust_reason == "extra_charge":
					result.water.event = event.duplicate(true)
			"merchant_visit":
				result.visitor = {"day_index": day, "npc_id": terms.npc_id, "location_id": terms.location_id}
			"butterfly_accent":
				# Eligibility/counts still belong to existing ecology feedback, never this event.
				result.accent = terms.accent.duplicate()
	return result
