## DirectorSaveCodec - pure paired component validation/fallback for future save14.
## API: normalize(profile,config,activity,director,context,legacy=false)->Dictionary.
class_name DirectorSaveCodec
extends RefCounted

static func normalize(profile: DirectorProfile, config: DirectorActivityConfig, activity: Variant, director: Variant, context: Dictionary, legacy: bool = false) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or not DirectorSaveContext.valid(profile, context):
		return {"ok": false, "reason": &"invalid_director_save_context"}
	var day: int = int(context.day_index)
	var observations: Dictionary = DirectorActivityCodec.decode(config, activity)
	var decisions: Dictionary = DirectorSnapshotCodec.decode(profile, director)
	if not legacy and observations.ok and decisions.ok and int(observations.snapshot.current_day) == day and int(decisions.snapshot.day_index) == day:
		return {"ok": true, "reason": &"restored", "used_fallback": false, "director_activity": observations.snapshot.duplicate(true), "director": decisions.snapshot.duplicate(true)}
	var baseline: Dictionary = DirectorActivityLifecycle.baseline(config, day)
	if not baseline.ok:
		return baseline
	var reason: StringName = &"legacy_baseline" if legacy else (&"component_missing_or_invalid" if not observations.ok or not decisions.ok else &"component_day_mismatch")
	# A broken pair cannot claim that a saved decision has a fully observed source.
	return {"ok": true, "reason": reason, "used_fallback": true, "director_activity": baseline.snapshot, "director": DirectorSnapshotCodec.baseline(day)}
