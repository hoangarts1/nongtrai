## DirectorActivityLifecycle - silent current-day observation restore, never replay.
## API: baseline(config,day); resolve(config,raw,day); restore(state,config,raw,day).
class_name DirectorActivityLifecycle
extends RefCounted

static func baseline(config: DirectorActivityConfig, day: int) -> Dictionary:
	var owner: DirectorActivityState = DirectorActivityState.new()
	if not owner.configure(config, day, false):
		return {"ok": false, "reason": &"invalid_activity_configuration"}
	return {"ok": true, "reason": &"partial_baseline", "snapshot": owner.serialize()}

static func resolve(config: DirectorActivityConfig, raw: Variant, day: int) -> Dictionary:
	if not DirectorActivityCodec.valid_integer(day):
		return {"ok": false, "reason": &"invalid_day"}
	var decoded: Dictionary = DirectorActivityCodec.decode(config, raw)
	if decoded.ok and int(decoded.snapshot.current_day) == day:
		return {"ok": true, "reason": &"restored", "snapshot": decoded.snapshot}
	var result: Dictionary = baseline(config, day)
	if result.ok:
		result.reason = &"activity_day_mismatch" if decoded.ok else &"activity_missing_or_invalid"
	return result

static func restore(state: DirectorActivityState, config: DirectorActivityConfig, raw: Variant, day: int) -> Dictionary:
	if state == null or state.is_busy():
		return {"ok": false, "reason": &"activity_busy"}
	var result: Dictionary = resolve(config, raw, day)
	if not result.ok:
		return result
	if not state.configure(config, day) or not state.deserialize(result.snapshot):
		return {"ok": false, "reason": &"activity_restore_rejected"}
	return result
