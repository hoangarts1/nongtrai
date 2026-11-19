## StorySaveContext - trusted supported legacy owner evidence, no simulated history.
## API: capture(config,payload)->Dictionary.
class_name StorySaveContext
extends RefCounted
static func capture(config: StoryConfig, payload: Dictionary) -> Dictionary:
	var observed: Dictionary = StoryObservationSampler.legacy(config,payload)
	if not observed.ok: return observed
	var completed: Array[String] = []
	for id: String in observed.objective_ids: completed.append(id)
	var decoded: Dictionary = StorySnapshotCodec.decode(config,{"completed_objectives":completed,"read_pages":[]})
	if not decoded.ok: return decoded
	return {"ok":true,"baseline":decoded.snapshot,"provenance":observed.provenance}
