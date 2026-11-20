## NeighborRules - proven introduction evidence over existing saved social owners.
## API: validate(config)->PackedStringArray; observed(config,social,day)->PackedStringArray;
## normalize_social(config,raw,day,legacy=false)->Dictionary. Never counts visibility/points.
class_name NeighborRules
extends RefCounted
const INTRODUCED_VERSION: int = 18

static func validate(config: StoryConfig) -> PackedStringArray:
	if config==null or config.land==null or config.land.npc_world==null or config.neighbor_introductions.is_empty(): return PackedStringArray(["neighbor introduction DATA required"])
	var world: NpcWorldData = config.land.npc_world
	var lines: Dictionary = {}
	for id: StringName in config.neighbor_introductions:
		if id.is_empty() or config.neighbor_introductions[id].is_empty() or lines.has(config.neighbor_introductions[id]): return PackedStringArray(["unique neighbor introduction IDs required"])
		var registered: bool = false
		for resource: Resource in world.npcs:
			var npc: NpcData = resource as NpcData
			if npc!=null and npc.npc_id==id: registered = true
		var matched: bool = false
		for resource: Resource in world.dialogues:
			var line: DialogueData = resource as DialogueData
			if line!=null and line.npc_id==id and line.dialogue_id==config.neighbor_introductions[id]: matched = true
		if not registered or not matched: return PackedStringArray(["neighbor must reference a real NPC and its dialogue"])
		lines[config.neighbor_introductions[id]] = true
	return PackedStringArray()

static func observed(config: StoryConfig, social: Dictionary, day: int) -> PackedStringArray:
	var result: PackedStringArray = []
	if day<0 or not validate(config).is_empty() or not social.get("heard") is Array or not social.get("talk_days") is Dictionary or not social.get("introduced") is Array: return result
	var introduced: Dictionary = {}
	var known: Dictionary = {}
	for resource: Resource in config.land.npc_world.npcs:
		var npc: NpcData = resource as NpcData
		if npc!=null: known[String(npc.npc_id)] = true
	for value: Variant in social.introduced:
		if typeof(value) not in [TYPE_STRING,TYPE_STRING_NAME] or not known.has(String(value)) or introduced.has(String(value)): return PackedStringArray()
		introduced[String(value)] = true
	var heard: Dictionary = {}
	for value: Variant in social.heard:
		if typeof(value) not in [TYPE_STRING,TYPE_STRING_NAME] or heard.has(String(value)): return PackedStringArray()
		heard[String(value)] = true
	for id: StringName in config.neighbor_introductions:
		var raw: Variant = social.talk_days.get(String(id),social.talk_days.get(id))
		if introduced.has(String(id)) and heard.has(String(config.neighbor_introductions[id])) and _valid_day(raw,day): result.append(String(id))
	return result

static func normalize_social(config: StoryConfig, raw: Variant, day: int, legacy: bool = false) -> Dictionary:
	if not validate(config).is_empty() or day<0: return {"ok":false,"reason":&"invalid_neighbor_context"}
	var social: Dictionary = raw.duplicate(true) if raw is Dictionary else {}
	# Only the guarded visible-conversation commit writes this new saved marker.
	# Programmatic talk()/friendship/seeing an actor does not mark an introduction.
	if legacy or not social.get("introduced") is Array: social["introduced"] = []
	var observed_ids: PackedStringArray = observed(config,social,day) if not legacy else PackedStringArray()
	for id: StringName in config.neighbor_introductions:
		# Earlier versions never registered these NPCs. Do not import injected facts.
		if legacy:
			for key: String in ["friendship","cells"]:
				if social.get(key) is Dictionary:
					social[key].erase(id)
					social[key].erase(String(id))
		if legacy or not observed_ids.has(String(id)):
			if social.get("introduced") is Array:
				social.introduced.erase(id)
				social.introduced.erase(String(id))
			if social.get("talk_days") is Dictionary:
				social.talk_days.erase(id)
				social.talk_days.erase(String(id))
			if social.get("heard") is Array:
				for index: int in range(social.heard.size()-1,-1,-1):
					var value: Variant = social.heard[index]
					if typeof(value) not in [TYPE_STRING,TYPE_STRING_NAME]: continue
					for resource: Resource in config.land.npc_world.dialogues:
						var line: DialogueData = resource as DialogueData
						if line!=null and line.npc_id==id and String(line.dialogue_id)==String(value):
							social.heard.remove_at(index)
							break
	return {"ok":true,"snapshot":social}

static func _valid_day(value: Variant, today: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value)==floorf(float(value)) and value>=0 and value<=today
