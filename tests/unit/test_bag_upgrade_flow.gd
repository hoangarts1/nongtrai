extends GutTest
const SLOT: int = 96
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool

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
	SaveService.delete_save(SLOT)

func _open() -> void:
	if not main.inventory_panel.visible:
		main.inventory_panel.toggle_inventory()
	main.bag_upgrade_flow.open()
	assert_true(main.bag_upgrade_flow.panel.visible)

func test_v9_real_roundtrip_preserves_land_crops_jobs_items_and_new_game_resets_base() -> void:
	main.wallet.add_coins(1900,&"test")
	main.machine_shop_panel.open()
	main.land_runtime.open()
	main.land_runtime.purchase(&"farm_east_1")
	assert_true(main.land_ownership.can_use_cell(Vector2i(6,2)))
	main.farm_state.till_cell(Vector2i(6,2))
	main.farm_state.plant_crop(Vector2i(6,2),&"turnip")
	main.machine_inventory.add_machine(&"stove",1)
	assert_true(main.machine_build.place(&"stove",Vector2i(2,3),0).ok)
	main.inventory.add_item(&"carrot",2)
	assert_true(main.machine_operations.start(Vector2i(2,3),&"stove_carrot_meal",1).ok)
	var stacks: Array[Dictionary] = main.inventory.get_slots()
	var farm: Dictionary = main.farm_state.serialize()
	var placements: Dictionary = main.machine_placements.serialize()
	var jobs: Dictionary = main.machine_operations.serialize()
	var owned: Dictionary = main.land_ownership.serialize()
	_open()
	main.day_end_flow.ledger.reset(GameClock.day_index)
	main.bag_upgrade_flow.purchase(40)
	assert_eq(main.inventory.capacity,52)
	assert_eq(main.wallet.get_coins(),1200)
	assert_eq(main.inventory.get_slots(),stacks)
	assert_eq(main.day_end_flow.ledger.totals(),{"income":0,"expense":300,"profit":-300})
	assert_true(main.get("_save_dirty"))
	assert_true(main.call("_save_game_to_slot",SLOT))
	var saved: Dictionary = SaveService.load_game(SLOT)
	assert_eq(int(saved.meta.save_version),16)
	assert_eq(int(saved.inventory.capacity),52)
	assert_false(saved.has("bag_upgrade"),"No new saved owner/flag")
	main.call("_start_new_game","Other","Other")
	assert_eq(main.inventory.capacity,40)
	assert_eq(main.inventory.get_slots().size(),1,"Only starter seeds in new game")
	assert_false(main.bag_upgrade_flow.panel.visible)
	main.call("_load_payload",saved)
	assert_eq(main.inventory.capacity,52)
	assert_eq(main.wallet.get_coins(),1200)
	assert_eq(main.inventory.get_slots(),stacks)
	assert_eq(main.farm_state.serialize(),farm)
	assert_eq(main.machine_placements.serialize(),placements)
	assert_eq(main.machine_operations.serialize(),jobs)
	assert_eq(main.land_ownership.serialize(),owned)
	_open()
	main.bag_upgrade_flow.purchase(52)
	assert_eq(main.bag_upgrade_flow.result.reason,&"already_upgraded")
	assert_eq(main.wallet.get_coins(),1200)
	main.call("_load_payload",{"inventory":{"capacity":60,"slots":[{"item_id":"turnip","quantity":2}]},"wallet":{"coins":500}})
	assert_eq(main.inventory.capacity,60)
	_open()
	main.bag_upgrade_flow.purchase(60)
	assert_eq(main.inventory.capacity,60)
	assert_eq(main.wallet.get_coins(),500)

func test_callbacks_block_main_safe_points_and_cross_land_bag_purchases() -> void:
	main.wallet.add_coins(900,&"test")
	_open()
	var blocked: Array[bool] = []
	var callback: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason!=&"buy_bag_upgrade":
			return
		blocked.append(not bool(main.call("_save_game_to_slot",SLOT)))
		blocked.append(not bool(main.call("_load_game_from_slot",1)))
		blocked.append(not bool(main.call("_return_to_start_menu")))
		main.call("_load_payload",{})
		main.call("_start_new_game","Other","Other")
		main.call("_continue_game")
		blocked.append(main.profile.player_name=="Mai")
		main.land_runtime.restore({})
		main.bag_upgrade_flow.purchase(40)
		# Make the other panel genuinely current: the shared transaction gate must win.
		main.land_runtime.model = LifeLandSnapshot.capture(main)
		main.land_runtime.panel.show()
		main.land_runtime.purchase(&"farm_east_1")
	main.wallet.coins_changed.connect(callback)
	main.bag_upgrade_flow.purchase(40)
	main.wallet.coins_changed.disconnect(callback)
	assert_eq(blocked,[true,true,true,true])
	assert_eq(main.inventory.capacity,52)
	assert_eq(main.wallet.get_coins(),700)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),36)
	assert_false(SaveService.has_save(SLOT))
	main.inventory.deserialize({"capacity":40,"slots":[]})
	main.wallet.deserialize({"coins":1000})
	main.machine_shop_panel.open()
	main.land_runtime.open()
	callback = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_land":
			main.bag_upgrade_flow.panel.ensure_built()
			main.bag_upgrade_flow.model = LifeBagUpgradeSnapshot.capture(main)
			main.bag_upgrade_flow.panel.show()
			main.bag_upgrade_flow.purchase(40)
	main.wallet.coins_changed.connect(callback)
	main.land_runtime.purchase(&"farm_east_1")
	main.wallet.coins_changed.disconnect(callback)
	assert_eq(main.inventory.capacity,40)
	assert_eq(main.wallet.get_coins(),500)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72)

func test_cancel_stale_quote_and_hidden_requests_do_not_mutate_owners() -> void:
	main.wallet.add_coins(900,&"test")
	_open()
	main.bag_upgrade_flow.back_to_bag()
	assert_true(main.inventory_panel.visible)
	assert_false(main.bag_upgrade_flow.panel.visible)
	main.bag_upgrade_flow.purchase(40)
	assert_eq(main.wallet.get_coins(),1000)
	_open()
	main.inventory.try_expand_capacity(40,45)
	main.bag_upgrade_flow.purchase(40)
	assert_eq(main.bag_upgrade_flow.result.reason,&"stale_capacity")
	assert_eq(main.wallet.get_coins(),1000)
	assert_eq(main.inventory.capacity,45)
	var config: BagUpgradeConfig = preload("res://data/bag_upgrade_config.tres").duplicate() as BagUpgradeConfig
	main.bag_upgrade.configure(config,main.inventory,main.wallet)
	main.bag_upgrade_flow.refresh()
	config.purchase_price += 1
	main.bag_upgrade_flow.purchase(45)
	assert_eq(main.bag_upgrade_flow.result.reason,&"stale_capacity")
	assert_eq(main.wallet.get_coins(),1000)
	main.call("_return_to_start_menu")
	assert_false(main.bag_upgrade_flow.panel.visible)
	assert_false(main.inventory_panel.visible)
	assert_true(main.start_menu.visible)
