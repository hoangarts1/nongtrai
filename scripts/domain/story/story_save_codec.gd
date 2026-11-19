## StorySaveCodec - preserve valid story exactly; fallback only this component.
## API: normalize(config,raw,payload,legacy=false)->Dictionary.
class_name StorySaveCodec
extends RefCounted
static func normalize(config: StoryConfig, raw: Variant, payload: Dictionary, legacy: bool = false) -> Dictionary:
	var context: Dictionary = StorySaveContext.capture(config,payload)
	if not context.ok: return context
	if not legacy:
		var decoded: Dictionary = StorySnapshotCodec.decode(config,raw)
		if decoded.ok: return {"ok":true,"snapshot":decoded.snapshot,"fallback":false,"reason":&"preserved_story"}
	return {"ok":true,"snapshot":context.baseline,"fallback":true,"reason":&"legacy_story" if legacy else &"story_fallback"}
