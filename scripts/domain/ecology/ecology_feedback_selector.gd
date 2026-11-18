## EcologyFeedbackSelector — deterministic detached current-level selection, no history/RNG.
class_name EcologyFeedbackSelector
extends RefCounted

static func select(profile: EcologyFeedbackProfile, ecology: EcologyProfile, metrics: Variant, available: Variant) -> Dictionary:
	if profile == null or not profile.validation_errors(ecology).is_empty():
		return {"ok": false, "reason": &"invalid_profile"}
	var decoded: Dictionary = EcologySnapshotCodec.decode_metrics(ecology, metrics)
	if not decoded.ok or not available is Dictionary or available.size() != ecology.metrics.size():
		return {"ok": false, "reason": &"invalid_metrics_or_availability"}
	for id: String in decoded.metrics:
		if not available.get(id) is bool or (id == "water_clarity" and bool(available[id])):
			return {"ok": false, "reason": &"invalid_availability"}
	var effects: Array[Dictionary] = []
	var total: int = 0
	for row: Dictionary in profile.effects:
		if not bool(available[row.metric_id]):
			continue
		for threshold: Dictionary in ecology.get_thresholds():
			if row.threshold_id == threshold.id and float(decoded.metrics[row.metric_id]) >= float(threshold.value):
				effects.append(row.duplicate(true))
				total += int(row.count)
	return {"ok": true, "effects": effects, "total": total}
