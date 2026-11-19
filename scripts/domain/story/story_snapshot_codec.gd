## StorySnapshotCodec - strict two-field story wire, no state or runtime references.
## API: empty()->Dictionary; decode(config:StoryConfig,raw:Variant)->Dictionary.
class_name StorySnapshotCodec
extends RefCounted
static func empty() -> Dictionary:
	return {"completed_objectives":[],"read_pages":[]}
static func decode(config: StoryConfig, raw: Variant) -> Dictionary:
	if not StoryCatalogValidator.validate(config).is_empty(): return {"ok":false,"reason":&"invalid_story_config"}
	if not raw is Dictionary or raw.size()!=2 or not raw.has("completed_objectives") or not raw.has("read_pages"): return _failure()
	for key: Variant in raw:
		if typeof(key)!=TYPE_STRING: return _failure()
	var completed: Dictionary = _ids(raw.completed_objectives,config.supported_ids())
	var page_ids: PackedStringArray = []
	for page: StoryPageData in config.pages: page_ids.append(String(page.page_id))
	var read: Dictionary = _ids(raw.read_pages,page_ids)
	if not completed.ok or not read.ok: return _failure()
	for id: String in completed.ids:
		for required: String in config.get_objective(StringName(id)).requires:
			if not completed.ids.has(required): return _failure()
	for id: String in read.ids:
		var page: StoryPageData = config.get_page(StringName(id))
		if not page.objective_id.is_empty() and not completed.ids.has(String(page.objective_id)): return _failure()
		for required: String in page.requires_pages:
			if not read.ids.has(required): return _failure()
	return {"ok":true,"snapshot":{"completed_objectives":completed.ids,"read_pages":read.ids}}
static func _ids(raw: Variant, allowed: PackedStringArray) -> Dictionary:
	if not raw is Array or raw.size()>allowed.size(): return {"ok":false}
	var seen: Dictionary = {}
	for id: Variant in raw:
		if typeof(id)!=TYPE_STRING or not allowed.has(id) or seen.has(id): return {"ok":false}
		seen[id] = true
	var result: Array[String] = []
	for id: String in allowed:
		if seen.has(id): result.append(id)
	return {"ok":true,"ids":result}
static func _failure() -> Dictionary:
	return {"ok":false,"reason":&"invalid_story_snapshot"}
