## EcologySaveContext — detached legacy farm/land normalization using existing codecs.
## API: static capture(payload,crops,land,legacy)->Dictionary {ok,reason,farm?,regions?}.
class_name EcologySaveContext
extends RefCounted

const SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")

static func capture(payload: Variant, crops: Array[Resource], land: LandExpansionConfig, legacy: CropMigrationConfig) -> Dictionary:
	if not payload is Dictionary or legacy == null or not LandExpansionRules.validate(land).is_empty() or not SAMPLING.validation_errors(crops).is_empty():
		return _failure(&"invalid_context_configuration")
	var known: Dictionary = {}
	for resource: Resource in crops:
		var crop: CropData = resource as CropData
		known[crop.crop_id] = crop
	for id: Variant in legacy.previous_growth_days:
		var value: Variant = legacy.previous_growth_days[id]
		if not EcologyMetricData.valid_id(id) or not known.has(StringName(id)) or not EcologySnapshotCodec.valid_day(value) or int(value) <= 0 or int(value) > EcologySampler.INT32_MAX:
			return _failure(&"invalid_crop_migration")
	var raw_farm: Variant = payload.get("farm", {})
	if not raw_farm is Dictionary:
		return _failure(&"invalid_farm_component")
	var rows: Variant = raw_farm.get("plots", [])
	if not rows is Array:
		return _failure(&"invalid_farm_component")
	# Existing decoder casts this one field directly: reject unsafe casts before delegation.
	for row: Variant in rows:
		if row is Dictionary and row.has("withered_days"):
			var value: Variant = row.withered_days
			if not EcologyMetricData.number(value) or float(value) < EcologySampler.INT32_MIN or float(value) > EcologySampler.INT32_MAX:
				return _failure(&"invalid_withered_counter")
	var decoded: Dictionary = FarmSaveCodec.decode(raw_farm, known, legacy)
	if not decoded.success:
		return _failure(&"invalid_farm_component")
	var ownership: LandOwnershipState = LandOwnershipState.new()
	ownership.configure(land)
	var raw_land: Variant = payload.get("land_ownership", {})
	ownership.deserialize(raw_land if raw_land is Dictionary else {})
	return {"ok": true, "reason": &"captured", "farm": FarmSaveCodec.encode(decoded.plots), "regions": ownership.get_owned_regions()}

static func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
