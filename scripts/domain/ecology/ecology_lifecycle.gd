## EcologyLifecycle — stateless calibration, silent restore and sampled daily updates.
## API: static calibrate(profile,config,farm,crops,regions,day)->Dictionary;
## resolve(profile,config,raw,day,farm,crops,regions)->Dictionary;
## restore(state,profile,config,raw,day,farm,crops,regions)->Dictionary;
## advance(state,config,day,farm,crops,regions)->Dictionary.
class_name EcologyLifecycle
extends RefCounted

static func calibrate(profile: EcologyProfile, config: EcologySamplingConfig, farm: Variant, crops: Array[Resource], regions: Array[Rect2i], day: int) -> Dictionary:
	var candidate: EcologyState = EcologyState.new()
	if not candidate.configure(profile, day):
		return _failure(&"invalid_profile_or_day")
	var sample: Dictionary = EcologySampler.sample(config, farm, crops, regions, candidate.get_metrics())
	if not sample.ok:
		return _failure(&"invalid_context", sample.reason)
	# Calibration is a current-garden estimate, never replayed historical growth.
	var snapshot: Dictionary = {"day_index": day, "metrics": sample.targets.duplicate(true), "triggered": []}
	if not candidate.deserialize(snapshot):
		return _failure(&"incompatible_profile")
	return {"ok": true, "reason": &"calibrated", "snapshot": candidate.serialize(), "sample": sample}

static func resolve(profile: EcologyProfile, config: EcologySamplingConfig, raw: Variant, day: int, farm: Variant, crops: Array[Resource], regions: Array[Rect2i]) -> Dictionary:
	if not EcologySnapshotCodec.valid_day(day):
		return _failure(&"invalid_day")
	var decoded: Dictionary = EcologySnapshotCodec.decode(profile, raw)
	if decoded.ok and int(decoded.snapshot.day_index) == day:
		var sample: Dictionary = EcologySampler.sample(config, farm, crops, regions, decoded.snapshot.metrics)
		if not sample.ok:
			return _failure(&"invalid_context", sample.reason)
		return {"ok": true, "reason": &"restored", "snapshot": decoded.snapshot, "sample": sample}
	var result: Dictionary = calibrate(profile, config, farm, crops, regions, day)
	if result.ok:
		result["reason"] = &"calibrated_day_mismatch" if decoded.ok else &"calibrated_missing_or_invalid"
	return result

static func restore(state: EcologyState, profile: EcologyProfile, config: EcologySamplingConfig, raw: Variant, day: int, farm: Variant, crops: Array[Resource], regions: Array[Rect2i]) -> Dictionary:
	if state == null or state.is_busy():
		return _failure(&"unavailable_owner")
	var result: Dictionary = resolve(profile, config, raw, day, farm, crops, regions)
	if not result.ok:
		return result
	# Resolve validated the entire candidate; these silent calls publish no callback gap.
	if not state.configure(profile, day) or not state.deserialize(result.snapshot):
		return _failure(&"restore_rejected")
	return result

static func advance(state: EcologyState, config: EcologySamplingConfig, day: int, farm: Variant, crops: Array[Resource], regions: Array[Rect2i]) -> Dictionary:
	if state == null or state.is_busy() or state.serialize().is_empty():
		return _failure(&"unavailable_owner")
	if not EcologySnapshotCodec.valid_day(day) or state.get_day_index() >= EcologySnapshotCodec.MAX_JSON_INTEGER or day != state.get_day_index() + 1:
		return _failure(&"wrong_day")
	var sample: Dictionary = EcologySampler.sample(config, farm, crops, regions, state.get_metrics())
	if not sample.ok:
		return _failure(&"invalid_context", sample.reason)
	var result: Dictionary = state.advance_day(day, sample.targets)
	if result.ok:
		result["sample"] = sample
	return result

static func _failure(reason: StringName, detail: String = "") -> Dictionary:
	return {"ok": false, "reason": reason, "detail": detail}
