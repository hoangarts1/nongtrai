## Independent verification fixtures: 1000 commands, never observed gameplay/days.
extends SceneTree
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
const STEPS: int = 1000
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	if not OS.get_cmdline_user_args().is_empty():
		print("[sim_story] rejected invalid verification fixture/argument")
		quit(1)
		return
	var started: int = Time.get_ticks_msec()
	var single: Dictionary = simulate(1,false)
	var grouped: Dictionary = simulate(13,false)
	var resumed: Dictionary = simulate(17,true)
	if not single.ok or not grouped.ok or not resumed.ok or single.trace!=grouped.trace or single.trace!=resumed.trace or single.state!=resumed.state:
		push_error("sim_story: fixture continuation divergence")
		quit(1)
		return
	print(JSON.stringify({"status":"PASS","fixture_commands":STEPS,"grouped_match":true,"json_match":true,"rejected":single.rejected,"planned_complete":false,"elapsed_ms":Time.get_ticks_msec()-started}))
	quit(0)
static func simulate(group: int, checkpoint: bool) -> Dictionary:
	if group<=0: return {"ok":false}
	var owner: StoryState = StoryState.new()
	if not owner.configure(CONFIG): return {"ok":false}
	var trace: Array[Dictionary] = []
	var rejected: int = 0
	var index: int = 0
	while index<STEPS:
		for _part: int in range(mini(group,STEPS-index)):
			var result: Dictionary = {}
			var receipt: Dictionary = {}
			match index%13:
				0: receipt = StoryReceiptRules.from_command(CONFIG,&"tool",{"crop_planted":1},true)
				1: receipt = StoryReceiptRules.from_command(CONFIG,&"tool",{"crop_harvested":1},true)
				2: receipt = StoryReceiptRules.from_command(CONFIG,&"shipping_bin",{"item_sold":1},true)
				3: receipt = StoryReceiptRules.delivery(CONFIG,CONFIG.delivery.quest_id,{"completed":[String(CONFIG.delivery.quest_id)]},true)
				4: receipt = StoryReceiptRules.parcel(CONFIG,CONFIG.land.parcels[0].parcel_id,{"owned_parcels":[String(CONFIG.land.parcels[0].parcel_id)]},true)
				5: result = owner.acknowledge_page(&"intro",owner.get_revision())
				6: result = owner.acknowledge_page(&"page_sowing",owner.get_revision())
				7: result = owner.observe(PackedStringArray(["first_sowing"]),owner.get_revision()+1)
				8: result = owner.observe(PackedStringArray(["m2_4_station"]))
				9: result = owner.acknowledge_page(&"missing_page")
				10: result = {"ok":owner.configure(CONFIG)}
				11: result = {"ok":owner.deserialize(JSON.parse_string(JSON.stringify(owner.serialize())))}
				12: result = owner.observe(PackedStringArray(["first_sowing"]))
			if not receipt.is_empty():
				if not receipt.ok: return {"ok":false}
				result = owner.observe(receipt.objective_ids)
			if result.is_empty(): return {"ok":false}
			if index%13 in [7,8,9]:
				if result.ok: return {"ok":false}
				rejected += 1
			elif not result.ok: return {"ok":false}
			if owner.is_complete() or owner.is_busy(): return {"ok":false}
			trace.append({"ok":result.ok,"wire":owner.serialize()})
			index += 1
			if checkpoint and index==STEPS/2:
				var wire: Dictionary = JSON.parse_string(JSON.stringify(owner.serialize()))
				owner = StoryState.new()
				if not owner.configure(CONFIG) or not owner.deserialize(wire): return {"ok":false}
	return {"ok":trace.size()==STEPS,"trace":trace,"state":owner.serialize(),"rejected":rejected}
