## StoryReceiptRules - pure committed-command projection, not a producer subscriber.
## API: from_command(config,source,counts,committed)->Dictionary;
## delivery(config,id,quests,committed); parcel(config,id,ownership,committed).
class_name StoryReceiptRules
extends RefCounted
const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const SOURCES: PackedStringArray = ["tool","water","seed_shop","shipping_bin","minh","chicken_feed"]

static func from_command(config: StoryConfig, source: StringName, counts: Dictionary, committed: bool) -> Dictionary:
	if not committed or not SOURCES.has(String(source)) or not StoryCatalogValidator.validate(config).is_empty(): return _failure()
	var normalized: Dictionary = {}
	for key: Variant in counts:
		if typeof(key) not in [TYPE_STRING,TYPE_STRING_NAME] or not ACTIVITY.activity_ids.has(String(key)): return _failure()
		var value: Variant = counts[key]
		if typeof(value)!=TYPE_INT or value<=0 or value>DirectorActivityCodec.MAX_JSON_INTEGER: return _failure()
		normalized[String(key)] = value
	var ids: PackedStringArray = []
	for goal: StoryObjectiveData in config.objectives:
		if goal.planned or not normalized.has(String(goal.source)): continue
		var allowed: bool = (goal.source in [&"crop_planted",&"crop_harvested"] and source==&"tool") or (goal.source==&"item_sold" and source in [&"shipping_bin",&"minh"])
		if not allowed: return _failure()
		if int(normalized[String(goal.source)])>=goal.target: ids.append(String(goal.objective_id))
	return _success(ids)

static func delivery(config: StoryConfig, id: StringName, quests: Dictionary, committed: bool) -> Dictionary:
	if not committed or not StoryCatalogValidator.validate(config).is_empty() or id!=config.delivery.quest_id or not StoryObservationSampler.string_ids(quests.get("completed")).has(String(id)): return _failure()
	return _matching(config,&"quest_completed",id)

static func parcel(config: StoryConfig, id: StringName, ownership: Dictionary, committed: bool) -> Dictionary:
	if not committed or not StoryCatalogValidator.validate(config).is_empty() or not StoryObservationSampler.first_parcel(config,ownership): return _failure()
	return _matching(config,&"parcel_owned",id)

static func _matching(config: StoryConfig, source: StringName, id: StringName) -> Dictionary:
	var ids: PackedStringArray = []
	for goal: StoryObjectiveData in config.objectives:
		if not goal.planned and goal.source==source and goal.source_id==id: ids.append(String(goal.objective_id))
	return _success(ids) if not ids.is_empty() else _failure()

static func _success(ids: PackedStringArray) -> Dictionary:
	return {"ok":true,"objective_ids":ids,"provenance":&"committed_command"}

static func _failure() -> Dictionary:
	return {"ok":false,"reason":&"unproven_story_command"}
