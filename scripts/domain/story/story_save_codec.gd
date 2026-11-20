## StorySaveCodec - preserve valid story exactly; fallback only this component.
## API: normalize(config,raw,payload,legacy=false)->Dictionary.
## without_clearing(config,raw)->Variant: strip only the source unavailable pre17.
class_name StorySaveCodec
extends RefCounted
static func normalize(config: StoryConfig, raw: Variant, payload: Dictionary, legacy: bool = false) -> Dictionary:
	var context: Dictionary = StorySaveContext.capture(config,payload)
	if not context.ok: return context
	if not legacy:
		var metadata: Dictionary = StoryObservationSampler.section(payload.get("meta"))
		var version: Variant = metadata.get("save_version")
		var previous: bool = (version is int or version is float) and is_finite(float(version)) and float(version)<ClearingSaveCodec.INTRODUCED_VERSION
		var candidate: Variant = without_clearing(config,raw) if previous else raw
		var decoded: Dictionary = StorySnapshotCodec.decode(config,candidate)
		if decoded.ok: return {"ok":true,"snapshot":decoded.snapshot,"fallback":false,"reason":&"preserved_story"}
	return {"ok":true,"snapshot":context.baseline,"fallback":true,"reason":&"legacy_story" if legacy else &"story_fallback"}

static func without_clearing(config: StoryConfig, raw: Variant) -> Variant:
	if config==null or not raw is Dictionary or not raw.get("completed_objectives") is Array: return raw
	var copy: Dictionary = raw.duplicate(true)
	for index: int in range(copy.completed_objectives.size()-1,-1,-1):
		var id: Variant = copy.completed_objectives[index]
		if typeof(id)!=TYPE_STRING: continue
		var goal: StoryObjectiveData = config.get_objective(StringName(id))
		if goal!=null and goal.source==&"scenery_cleared": copy.completed_objectives.remove_at(index)
	return copy
