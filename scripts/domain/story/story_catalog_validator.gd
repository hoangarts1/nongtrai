## StoryCatalogValidator - pure DATA validation; no Node, unlock or game state.
## API: validate(config:StoryConfig)->PackedStringArray.
class_name StoryCatalogValidator
extends RefCounted
const SOURCES: PackedStringArray = ["crop_planted","crop_harvested","item_sold","quest_completed","parcel_owned"]
static func validate(config: StoryConfig) -> PackedStringArray:
	var errors: PackedStringArray = []
	if config==null: return PackedStringArray(["story config required"])
	if config.chapter_id.is_empty() or config.objectives.is_empty() or config.pages.is_empty(): errors.append("story chapter/objectives/pages required")
	if config.delivery==null or config.delivery.quest_id.is_empty() or config.land==null or not LandExpansionRules.validate(config.land).is_empty(): errors.append("story requires actual delivery and land DATA")
	var goals: Dictionary = {}
	for row: StoryObjectiveData in config.objectives+config.milestones:
		if row==null: errors.append("story null objective"); continue
		var id: String = String(row.objective_id)
		if id.is_empty() or goals.has(id): errors.append("story duplicate/empty objective")
		goals[id] = row.requires
		if row.planned:
			if row.source!=&"planned" or row.target!=0 or not row.source_id.is_empty() or row.tutorial_step!=-1: errors.append("planned story cannot claim a live source")
		elif not SOURCES.has(String(row.source)) or row.target!=1: errors.append("story source/first-occurrence target invalid")
		elif row.source==&"quest_completed":
			if config.delivery==null or row.source_id!=config.delivery.quest_id or row.tutorial_step!=-1: errors.append("story delivery reference invalid")
		elif row.source==&"parcel_owned":
			if config.land==null or config.land.parcels.is_empty() or row.source_id!=config.land.parcels[0].parcel_id or row.tutorial_step!=-1: errors.append("story first parcel reference invalid")
		else:
			var step: int = {&"crop_planted":1,&"crop_harvested":4,&"item_sold":5}.get(row.source,-1)
			if row.tutorial_step!=step or not row.source_id.is_empty(): errors.append("story legacy tutorial evidence invalid")
	for row: StoryObjectiveData in config.milestones:
		if row!=null and not row.planned: errors.append("M2 milestone is not implemented")
	errors.append_array(_graph_errors(goals))
	var pages: Dictionary = {}
	for page: StoryPageData in config.pages:
		if page==null: errors.append("story null page"); continue
		var id: String = String(page.page_id)
		if id.is_empty() or pages.has(id): errors.append("story duplicate/empty page")
		pages[id] = page.requires_pages
		if not page.objective_id.is_empty():
			var goal: StoryObjectiveData = config.get_objective(page.objective_id)
			if goal==null or goal.planned: errors.append("story page must reference a supported objective")
	errors.append_array(_graph_errors(pages))
	for key: String in config.translation_keys():
		if key.is_empty() or key!=key.to_upper() or not key.is_valid_identifier(): errors.append("story translation key invalid")
	return errors
static func _graph_errors(graph: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	for key: String in graph:
		for dependency: String in graph[key]:
			if not graph.has(dependency): errors.append("story unknown dependency")
	var done: Dictionary = {}
	for key: String in graph:
		if _cyclic(key,graph,{},done): errors.append("story cyclic dependency"); break
	return errors
static func _cyclic(key: String, graph: Dictionary, visiting: Dictionary, done: Dictionary) -> bool:
	if visiting.has(key): return true
	if done.has(key) or not graph.has(key): return false
	visiting[key] = true
	for dependency: String in graph[key]:
		if _cyclic(dependency,graph,visiting,done): return true
	visiting.erase(key)
	done[key] = true
	return false
