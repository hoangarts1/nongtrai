## Detached story readout; no observation, acknowledgement or save writes.
class_name LifeStorySnapshot
extends RefCounted
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
static func capture(main: Node) -> Dictionary:
	if not is_instance_valid(main): return {"ok":false}
	var owner: StoryState = main.get("story_state") as StoryState
	if owner==null or owner.is_busy(): return {"ok":false}
	return from_wire(owner.serialize(),owner.get_revision())
static func from_wire(wire: Dictionary, revision: int = 0) -> Dictionary:
	var decoded: Dictionary = StorySnapshotCodec.decode(CONFIG,wire)
	if not decoded.ok or revision<0: return {"ok":false}
	var rows: Array[Dictionary] = []
	for goal: StoryObjectiveData in CONFIG.objectives:
		rows.append(_goal(goal,decoded.snapshot))
	var milestones: Array[Dictionary] = []
	for goal: StoryObjectiveData in CONFIG.milestones:
		milestones.append(_goal(goal,decoded.snapshot))
	var pages: Array[Dictionary] = []
	for page: StoryPageData in CONFIG.pages:
		pages.append({"id":String(page.page_id),"title_key":String(page.title_key),"body_key":String(page.body_key),
			"available":StoryRules.can_read(CONFIG,decoded.snapshot,page.page_id),"read":decoded.snapshot.read_pages.has(String(page.page_id))})
	return {"ok":true,"chapter_id":String(CONFIG.chapter_id),"title_key":String(CONFIG.title_key),"description_key":String(CONFIG.description_key),
		"revision":revision,"done_count":decoded.snapshot.completed_objectives.size(),"total_count":CONFIG.objectives.size(),
		"supported_count":CONFIG.supported_ids().size(),"chapter_complete":StoryRules.chapter_complete(CONFIG,decoded.snapshot),
		"objectives":rows,"milestones":milestones,"pages":pages}
static func _goal(goal: StoryObjectiveData, wire: Dictionary) -> Dictionary:
	return {"id":String(goal.objective_id),"title_key":String(goal.title_key),"description_key":String(goal.description_key),
		"planned":goal.planned,"done":not goal.planned and wire.completed_objectives.has(String(goal.objective_id))}
