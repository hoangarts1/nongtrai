extends GutTest

const EAST: Vector2i = Vector2i(6,2)
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool

class RejectLand extends LandOwnershipState:
	func grant_next(_id: StringName) -> bool:
		return false

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	await get_tree().process_frame
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	SaveService.delete_save(1)
	SaveService.delete_save(94)

func _open() -> void:
	main.machine_shop_panel.open()
	main.land_runtime.open()
	assert_true(main.land_runtime.panel.visible)

func test_real_permissions_purchase_and_legacy_progress() -> void:
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),36)
	main.machine_inventory.add_machine(&"stove",2)
	var request: MachinePlacementRequest = main.machine_placement_request
	for tool: StringName in [&"hoe",&"seed"]:
		assert_eq(request.can_use_farm_tool(EAST,tool).reason,&"land_locked")
	assert_eq(request.preview(&"stove",EAST,0,Vector2i(5,2)).reason,&"land_locked")
	assert_true(main.farm_state.till_cell(Vector2i(8,4)))
	assert_true(request.can_use_farm_tool(Vector2i(8,4),&"seed").ok)
	assert_true(request.can_use_farm_tool(Vector2i(8,4),&"watering_can").ok)
	assert_true(main.machine_build.place(&"stove",Vector2i(9,3),0).ok)
	assert_true(request.can_return(Vector2i(9,3),Vector2i(8,3)).ok)
	assert_true(request.preview_move(request.can_begin_move(Vector2i(9,3),Vector2i(8,3)).source,Vector2i(9,3),90,Vector2i(8,3)).ok)
	main.wallet.add_coins(900,&"test")
	_open()
	var farm: Dictionary = main.farm_state.serialize()
	var placements: Dictionary = main.machine_placements.serialize()
	main.land_runtime.purchase(&"farm_east_1")
	assert_eq(main.wallet.get_coins(),500)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72)
	assert_true(request.can_use_farm_tool(EAST,&"hoe").ok)
	assert_true(request.preview(&"stove",EAST,0,Vector2i(5,2)).ok)
	assert_eq(main.farm_state.serialize(),farm)
	assert_eq(main.machine_placements.serialize(),placements)
	main.land_runtime.purchase(&"farm_east_1")
	assert_eq(main.wallet.get_coins(),500)
	assert_true(bool(main.get("_save_dirty")))
	assert_true(bool(main.call("_save_game_to_slot",94)))
	var saved: Dictionary = SaveService.load_game(94)
	assert_eq(saved.land_ownership,{"owned_parcels":["farm_east_1"]})
	main.call("_start_new_game","New","Garden")
	assert_false(main.land_ownership.can_use_cell(EAST))
	main.call("_load_payload",saved)
	assert_true(main.land_ownership.can_use_cell(EAST))
	assert_eq(main.farm_state.serialize(),farm)
	assert_eq(main.machine_placements.serialize(),placements)
	assert_eq(main.wallet.get_coins(),500)

func test_scenery_collision_reset_and_load_preserve_npc_source() -> void:
	var npc_source: String = FileAccess.get_sha256("res://data/npcs/phase8_world.tres")
	var before: Dictionary = _scenery()
	assert_gt(before.size(),0)
	var collider_count: int = main.presentation.get_world_art_root().find_children("*","StaticBody2D",true,false).size()
	main.wallet.add_coins(900,&"test")
	_open()
	main.land_runtime.purchase(&"farm_east_1")
	assert_eq(_scenery(),{})
	var bought: Dictionary = {"land_ownership":main.land_ownership.serialize(),"wallet":main.wallet.serialize()}
	var regions: Array[Rect2i] = main.land_ownership.get_owned_regions()
	regions.clear()
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72,"Region reads are detached")
	main.call("_start_new_game","New","Garden")
	assert_eq(_scenery(),before)
	assert_eq(main.presentation.get_world_art_root().find_children("*","StaticBody2D",true,false).size(),collider_count)
	main.call("_load_payload",bought)
	assert_eq(_scenery(),{})
	assert_eq(main.npc_system.state.scheduler.location_cell(&"linh_stream"),Vector2i(7,4))
	assert_eq(FileAccess.get_sha256("res://data/npcs/phase8_world.tres"),npc_source)
	assert_false(main.land_runtime.panel.visible)

func _scenery() -> Dictionary:
	var found: Dictionary = {}
	for node: Node in main.presentation.get_world_art_root().get_children():
		var cell: Vector2i = node.get_meta("cell",Vector2i(-99,-99))
		if Rect2i(6,0,6,6).has_point(cell):
			found[String(node.name)] = {"cell":cell,"bodies":node.find_children("*","StaticBody2D",true,false).size()}
	return found

func test_callback_safe_points_and_refund_ledger() -> void:
	main.wallet.add_coins(900,&"test")
	_open()
	var blocked: Array[bool] = []
	var callback: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason!=&"buy_land":
			return
		blocked.append(not bool(main.call("_save_game_to_slot",94)))
		blocked.append(not bool(main.call("_load_game_from_slot",1)))
		main.call("_load_payload",{})
		main.call("_start_new_game","Other","Other")
		main.land_runtime.restore({})
		main.land_runtime.purchase(&"farm_east_1")
		blocked.append(main.profile.player_name=="Mai")
	main.wallet.coins_changed.connect(callback)
	main.land_runtime.purchase(&"farm_east_1")
	main.wallet.coins_changed.disconnect(callback)
	assert_eq(blocked,[true,true,true])
	assert_eq(main.wallet.get_coins(),500)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72)
	assert_false(SaveService.has_save(94))
	main.land_runtime.close()
	main.land_runtime.restore({})
	var reject: RejectLand = RejectLand.new()
	reject.configure(preload("res://data/land_expansion_config.tres"))
	main.land_expansion.configure(preload("res://data/land_expansion_config.tres"),reject,main.wallet)
	main.day_end_flow.ledger.reset(GameClock.day_index)
	_open()
	main.land_runtime.purchase(&"farm_east_1")
	assert_eq(main.land_runtime.result.reason,&"grant_rejected")
	assert_eq(main.wallet.get_coins(),500)
	assert_false(main.land_ownership.can_use_cell(EAST))
	assert_eq(main.day_end_flow.ledger.totals(),{"income":0,"expense":0,"profit":0})
	assert_eq(main.day_end_flow.ledger.rows().size(),2)
