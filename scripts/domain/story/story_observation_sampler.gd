## StoryObservationSampler - stored owner evidence only, never invent past receipts.
## API: legacy(config,payload)->Dictionary; string_ids(raw)->Array[String];
## first_parcel(config,ownership)->bool; section(raw)->Dictionary.
class_name StoryObservationSampler
extends RefCounted

static func legacy(config: StoryConfig, payload: Dictionary) -> Dictionary:
	if not StoryCatalogValidator.validate(config).is_empty(): return {"ok":false,"reason":&"invalid_story_config"}
	var tutorial: Dictionary = section(payload.get("quests"))
	var steps: Variant = tutorial.get("completed")
	var social: Dictionary = section(payload.get("social"))
	var quests: Dictionary = section(social.get("quests"))
	var completed: Array[String] = string_ids(quests.get("completed"))
	var owned: bool = first_parcel(config,section(payload.get("land_ownership")))
	var ids: PackedStringArray = []
	for goal: StoryObjectiveData in config.objectives:
		if goal.planned: continue
		var proven: bool = false
		if goal.tutorial_step>=0 and steps is Array and steps.size()>goal.tutorial_step:
			proven = typeof(steps[goal.tutorial_step])==TYPE_BOOL and steps[goal.tutorial_step]
		elif goal.source==&"quest_completed": proven = completed.has(String(goal.source_id))
		elif goal.source==&"parcel_owned": proven = owned
		if proven: ids.append(String(goal.objective_id))
	return {"ok":true,"objective_ids":ids,"provenance":&"saved_owner_progress"}

static func section(raw: Variant) -> Dictionary:
	return raw if raw is Dictionary else {}

static func string_ids(raw: Variant) -> Array[String]:
	var ids: Array[String] = []
	if not raw is Array: return ids
	for value: Variant in raw:
		if typeof(value)!=TYPE_STRING or ids.has(value): return []
		ids.append(value)
	return ids

static func first_parcel(config: StoryConfig, ownership: Dictionary) -> bool:
	if config==null or config.land==null: return false
	var raw: Variant = ownership.get("owned_parcels")
	if not raw is Array or raw.is_empty() or raw.size()>config.land.parcels.size(): return false
	var ids: Array[String] = string_ids(raw)
	if ids.size()!=raw.size(): return false
	for index: int in range(ids.size()):
		if config.land.parcels[index]==null or ids[index]!=String(config.land.parcels[index].parcel_id): return false
	return true
