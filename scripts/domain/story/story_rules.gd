## StoryRules - pure availability queries; never grant story entitlements.
## API: can_read(config,wire,page_id)->bool; chapter_complete(config,wire)->bool.
class_name StoryRules
extends RefCounted
static func can_read(config: StoryConfig, wire: Dictionary, page_id: StringName) -> bool:
	var decoded: Dictionary = StorySnapshotCodec.decode(config,wire)
	if not decoded.ok: return false
	var page: StoryPageData = config.get_page(page_id)
	if page==null: return false
	if not page.objective_id.is_empty() and not decoded.snapshot.completed_objectives.has(String(page.objective_id)): return false
	for required: String in page.requires_pages:
		if not decoded.snapshot.read_pages.has(required): return false
	return true
static func chapter_complete(config: StoryConfig, wire: Dictionary) -> bool:
	var decoded: Dictionary = StorySnapshotCodec.decode(config,wire)
	if not decoded.ok: return false
	for goal: StoryObjectiveData in config.objectives:
		if goal.planned or not decoded.snapshot.completed_objectives.has(String(goal.objective_id)): return false
	return true
