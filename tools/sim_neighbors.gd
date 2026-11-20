## Pure DATA/domain verification fixtures, not observed conversations or extra days.
extends SceneTree
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	await process_frame
	if not OS.get_cmdline_user_args().is_empty(): quit(1); return
	# Defer loading the existing social owner until Events/DataRegistry exist.
	var script: Script = load("res://scripts/domain/quests/npc_social_state.gd") as Script
	var owner: RefCounted = script.new()
	owner.call("configure",CONFIG.land.npc_world)
	var checked: int = 0
	for season: StringName in [&"spring",&"summer",&"autumn",&"winter"]:
		for day: int in range(CONFIG.land.npc_world.days_per_week):
			for resource: Resource in CONFIG.land.npc_world.npcs:
				var npc: NpcData = resource as NpcData
				var scheduler: NpcSchedule = owner.get("scheduler") as NpcSchedule
				var target: StringName = scheduler.destination(npc,day,720,season,false)
				if scheduler.route(scheduler.location_cell(npc.home_location),scheduler.location_cell(target)).is_empty(): quit(1); return
				if scheduler.destination(npc,day,720,season,true)!=npc.home_location: quit(1); return
				checked += 1
	for id: StringName in CONFIG.neighbor_introductions:
		var line: DialogueData = owner.call("talk",id,0,&"spring") as DialogueData
		if line==null or not owner.call("record_introduction",id,line.dialogue_id,0): quit(1); return
	var saved: Dictionary = owner.call("serialize")
	var restored: RefCounted = script.new()
	restored.call("configure",CONFIG.land.npc_world)
	restored.call("deserialize",JSON.parse_string(JSON.stringify(saved)))
	var matches: bool = restored.call("serialize")==saved
	print(JSON.stringify({"ok":matches,"kind":"verification_fixture_not_observed_gameplay","schedule_cases":checked,"registered_npcs":CONFIG.land.npc_world.npcs.size(),"fixture_introductions":NeighborRules.observed(CONFIG,saved,0).size(),"json_match":matches,"extra_simulated_days":0}))
	quit(0 if matches else 1)
