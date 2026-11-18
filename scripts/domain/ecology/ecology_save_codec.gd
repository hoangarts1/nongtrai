## EcologySaveCodec — validates a clock-aligned component or calibrates explicit fallback.
## API: static normalize(profile,config,raw,day,crops,context)->Dictionary.
## Success snapshot is existing ecology wire; sample/reason are transient diagnostics.
class_name EcologySaveCodec
extends RefCounted

static func normalize(profile: EcologyProfile, config: EcologySamplingConfig, raw: Variant, day: int, crops: Array[Resource], context: Dictionary) -> Dictionary:
	if not context.get("ok") is bool or not context.ok or not context.get("regions") is Array:
		return {"ok": false, "reason": &"invalid_context"}
	var regions: Array[Rect2i] = []
	for value: Variant in context.regions:
		if not value is Rect2i:
			return {"ok": false, "reason": &"invalid_regions"}
		regions.append(value)
	return EcologyLifecycle.resolve(profile, config, raw, day, context.get("farm"), crops, regions)
