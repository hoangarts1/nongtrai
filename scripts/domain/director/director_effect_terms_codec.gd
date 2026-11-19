## DirectorEffectTermsCodec - validated transient active terms; no effect/state owner.
## API: active(profile,raw,day)->Dictionary; water(config,raw)->Dictionary.
class_name DirectorEffectTermsCodec
extends RefCounted

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

static func active(profile: DirectorProfile, raw: Variant, day: int) -> Dictionary:
	if profile == null or not profile.validation_errors().is_empty() or not DirectorActivityCodec.valid_integer(day) or not DirectorScheduleRules.valid_terms(profile, raw) or int(raw.start_day) > day or int(raw.end_day) <= day:
		return {"ok": false, "reason": &"invalid_active_terms"}
	return {"ok": true, "event": DirectorHistoryRules.copy_json(raw)}

static func water(config: WateringCanConfig, raw: Variant) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or not raw is Dictionary:
		return {"ok": false, "reason": &"invalid_water_terms"}
	var extra: int = 0
	var day: int = -1
	var id: String = ""
	if not raw.is_empty():
		if raw.size() != 2 or not DirectorActivityCodec.valid_integer(raw.get("day_index")) or not raw.get("event") is Dictionary:
			return {"ok": false, "reason": &"invalid_water_terms"}
		day = int(raw.day_index)
		if not raw.event.is_empty():
			var checked: Dictionary = active(PROFILE, raw.event, day)
			if not checked.ok or checked.event.effect.kind != "extra_water_charge":
				return {"ok": false, "reason": &"invalid_water_terms"}
			extra = int(checked.event.effect.extra_charge)
			id = checked.event.event_id
	if extra > WateringCanConfig.MAX_JSON_INTEGER - config.manual_charge_cost:
		return {"ok": false, "reason": &"water_cost_overflow"}
	return {"ok": true, "charge_cost": config.manual_charge_cost + extra, "extra_charge": extra, "day_index": day, "event_id": id}
