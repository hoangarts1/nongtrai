extends GutTest
const SLOT: int = 97
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.set_process(false)
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
	main.ui_coordinator.close_active()
	main.inventory_panel.toggle_inventory()
	main.watering_upgrade_flow.open()
	assert_true(main.watering_upgrade_flow.panel.visible)

func test_actual_purchase_preserves_empty_partial_full_water_and_debits_once() -> void:
	for water: int in [0,7,20]:
		main.wallet.deserialize({"coins":500})
		main.watering_can.deserialize({"capacity":20,"charges":water})
		main.watering_runtime.refresh()
		_open()
		var owners: Dictionary = _owners()
		main.day_end_flow.ledger.reset(GameClock.day_index)
		main.watering_upgrade_flow.purchase(20)
		assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":water})
		assert_eq(main.wallet.get_coins(),300)
		assert_eq(_owners(),owners)
		assert_eq(main.day_end_flow.ledger.totals(),{"income":0,"expense":200,"profit":-200})
		assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text,tr("WATER_CAN_COUNT") % [water,40])
		assert_true(main.get("_save_dirty"))
		main.watering_upgrade_flow.purchase(20)
		main.watering_upgrade_flow.purchase(40)
		assert_eq(main.watering_upgrade_flow.result.reason,&"already_upgraded")
		assert_eq(main.wallet.get_coins(),300)
		main.ui_coordinator.close_active()
		main.world.player.move_to_cell(Vector2i(7,9))
		main.hotbar_panel.toolbar.request(2)
		assert_true(main.watering_runtime.refill().ok)
		assert_eq(main.watering_can.get_charges(),40)

func test_actual_v10_roundtrip_keeps_items_owned_land_crops_jobs_and_new_game_resets() -> void:
	main.wallet.add_coins(1900,&"test")
	main.machine_shop_panel.open()
	main.land_runtime.open()
	main.land_runtime.purchase(&"farm_east_1")
	main.farm_state.till_cell(Vector2i(6,2))
	main.farm_state.plant_crop(Vector2i(6,2),&"turnip")
	main.machine_inventory.add_machine(&"stove",1)
	assert_true(main.machine_build.place(&"stove",Vector2i(2,3),0).ok)
	main.inventory.add_item(&"carrot",2)
	assert_true(main.machine_operations.start(Vector2i(2,3),&"stove_carrot_meal",1).ok)
	main.watering_can.deserialize({"capacity":20,"charges":7})
	_open()
	var before: Dictionary = _owners()
	main.watering_upgrade_flow.purchase(20)
	assert_true(main.call("_save_game_to_slot",SLOT))
	var saved: Dictionary = SaveService.load_game(SLOT)
	assert_eq(int(saved.meta.save_version),15)
	assert_eq(saved.watering_can,{"capacity":40,"charges":7})
	assert_false(saved.has("watering_upgrade"))
	main.call("_start_new_game","Other","Other")
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":20})
	assert_false(main.watering_upgrade_flow.panel.visible)
	main.call("_load_payload",saved)
	assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":7})
	assert_eq(_owners(),before)
	assert_eq(main.wallet.get_coins(),1300)
	_open()
	main.watering_upgrade_flow.purchase(40)
	assert_eq(main.wallet.get_coins(),1300)
	assert_true(main.call("_return_to_start_menu"))
	assert_false(main.watering_upgrade_flow.panel.visible)
	assert_false(main.inventory_panel.visible)

func test_callbacks_block_lifecycle_refill_reentry_and_cross_purchases() -> void:
	main.wallet.add_coins(900,&"test")
	main.watering_can.deserialize({"capacity":20,"charges":7})
	_open()
	var blocked: Array[bool] = []
	var callback: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason!=&"buy_watering_upgrade":
			return
		blocked.append(bool(main.call("_purchase_in_progress")))
		blocked.append(not bool(main.call("_save_game_to_slot",SLOT)))
		blocked.append(not bool(main.call("_load_game_from_slot",1)))
		blocked.append(not bool(main.call("_return_to_start_menu")))
		main.call("_load_payload",{})
		main.call("_start_new_game","Other","Other")
		main.call("_continue_game")
		blocked.append(main.profile.player_name=="Mai")
		blocked.append(not bool(main.watering_runtime.refill().ok))
		main.watering_upgrade_flow.purchase(20)
		main.bag_upgrade_flow.panel.ensure_built()
		main.bag_upgrade_flow.model = LifeBagUpgradeSnapshot.capture(main)
		main.bag_upgrade_flow.panel.show()
		main.bag_upgrade_flow.purchase(40)
		main.land_runtime.model = LifeLandSnapshot.capture(main)
		main.land_runtime.panel.show()
		main.land_runtime.purchase(&"farm_east_1")
	main.wallet.coins_changed.connect(callback)
	main.watering_upgrade_flow.purchase(20)
	main.wallet.coins_changed.disconnect(callback)
	assert_eq(blocked,[true,true,true,true,true,true])
	assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":7})
	assert_false(main.watering_upgrade_flow.panel.visible,"Coordinator can replace a panel even during callbacks")
	assert_eq(main.wallet.get_coins(),800)
	assert_eq(main.inventory.capacity,40)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),36)
	assert_false(SaveService.has_save(SLOT))

func test_insufficient_stale_hidden_canceled_and_discard_requests_never_pay() -> void:
	_open()
	assert_eq(main.watering_upgrade_flow.model.target,40)
	assert_eq(main.watering_upgrade_flow.model.price,200)
	main.watering_upgrade_flow.purchase(20)
	assert_eq(main.watering_upgrade_flow.result.reason,&"insufficient_coins")
	assert_eq(main.wallet.get_coins(),100)
	main.watering_upgrade_flow.back_to_bag()
	main.watering_upgrade_flow.purchase(20)
	assert_true(main.inventory_panel.visible)
	main.inventory_panel.controller.select(0)
	main.inventory_panel.controller.request_discard()
	main.watering_upgrade_flow.open()
	assert_false(main.watering_upgrade_flow.panel.visible)
	main.inventory_panel.controller.cancel_discard()
	main.wallet.add_coins(400,&"test")
	_open()
	main.watering_can.try_upgrade(20,40)
	main.watering_upgrade_flow.purchase(20)
	assert_eq(main.watering_upgrade_flow.result.reason,&"stale_capacity")
	assert_eq(main.wallet.get_coins(),500)
	var config: WateringCanConfig = main.watering_upgrade_config.duplicate() as WateringCanConfig
	main.watering_upgrade_config = config
	main.watering_can.configure(config)
	main.watering_upgrade.configure(config,main.watering_can,main.wallet)
	main.watering_upgrade_flow.refresh()
	config.upgrade_price += 1
	main.watering_upgrade_flow.purchase(20)
	assert_eq(main.watering_upgrade_flow.result.reason,&"stale_capacity")
	assert_eq(main.watering_can.get_capacity(),20)
	assert_eq(main.wallet.get_coins(),500)

func test_reverse_cross_purchase_guard_and_rejected_grant_refresh_preserve_independent_changes() -> void:
	main.wallet.add_coins(900,&"test")
	main.inventory_panel.toggle_inventory()
	main.bag_upgrade_flow.open()
	var attempt: Callable = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_bag_upgrade":
			main.watering_upgrade_flow.panel.ensure_built()
			main.watering_upgrade_flow.model = LifeWateringUpgradeSnapshot.capture(main)
			main.watering_upgrade_flow.panel.show()
			main.watering_upgrade_flow.purchase(20)
	main.wallet.coins_changed.connect(attempt)
	main.bag_upgrade_flow.purchase(40)
	main.wallet.coins_changed.disconnect(attempt)
	assert_eq(main.inventory.capacity,52)
	assert_eq(main.watering_can.get_capacity(),20)
	assert_eq(main.wallet.get_coins(),700)
	var config: WateringCanConfig = main.watering_upgrade_config.duplicate() as WateringCanConfig
	main.watering_upgrade_config = config
	main.watering_can.configure(config)
	main.watering_can.deserialize({"capacity":20,"charges":7})
	main.watering_upgrade.configure(config,main.watering_can,main.wallet)
	_open()
	main.day_end_flow.ledger.reset(GameClock.day_index)
	attempt = func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_watering_upgrade":
			config.upgrade_price += 1
			main.watering_can.try_consume_one(7)
			main.wallet.add_coins(11,&"sell_produce")
	main.wallet.coins_changed.connect(attempt)
	main.watering_upgrade_flow.purchase(20)
	main.wallet.coins_changed.disconnect(attempt)
	assert_eq(main.watering_upgrade_flow.result.reason,&"grant_rejected")
	assert_eq(main.wallet.get_coins(),711)
	assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":6})
	assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text,tr("WATER_CAN_COUNT") % [6,20])
	assert_eq(main.day_end_flow.ledger.totals(),{"income":11,"expense":0,"profit":11})

func _owners() -> Dictionary:
	return {"bag":main.inventory.serialize(),"farm":main.farm_state.serialize(),"land":main.land_ownership.serialize(),"placements":main.machine_placements.serialize(),"jobs":main.machine_operations.serialize()}
