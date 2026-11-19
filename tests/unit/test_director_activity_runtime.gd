extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
var f: RefCounted
var main: Node
var _watches: Array[Dictionary] = []

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	await f.settle(self)

func after_each() -> void:
	for row: Dictionary in _watches:
		var source: Signal = row.source
		if source.is_connected(row.callback):
			source.disconnect(row.callback)
	_watches.clear()
	f.cleanup()
	await get_tree().process_frame

func _watch(source: Signal, callback: Callable) -> void:
	source.connect(callback)
	_watches.append({"source": source, "callback": callback})

func test_native_mouse_space_and_inspector_record_only_completed_manual_farm_actions() -> void:
	var cell: Vector2i = Vector2i(1, 1)
	main.world.player.move_to_cell(cell + Vector2i(0, 1))
	main.tool_controller.select_tool(&"hoe")
	await f.settle(self)
	await f.mouse(self, main.world.grid.cell_to_screen(cell))
	assert_eq(f.current_counts().plot_tilled, 1)
	f.use(&"hoe", cell)
	assert_eq(f.current_counts().plot_tilled, 1)
	main.tool_controller.select_seed()
	main.tool_controller._hovered_cell = cell
	main.tool_controller._hovered_valid = true
	await f.key(self, KEY_SPACE)
	assert_eq(f.current_counts().crop_planted, 1)
	assert_false(StringName(main.farm_state.get_plot(cell).crop_id).is_empty())
	main.crop_inspector.show_cell(cell)
	assert_false(main.crop_inspector.action_button.disabled)
	main.crop_inspector.action_button.pressed.emit()
	assert_eq(f.current_counts().plot_watered, 1)
	assert_eq(main.watering_can.get_charges(), 19)
	main.crop_inspector.action_button.pressed.emit()
	assert_eq(f.current_counts().plot_watered, 1)
	var raw: Dictionary = main.farm_state.serialize()
	for row: Dictionary in raw.plots:
		if Vector2i(int(row.cell_x), int(row.cell_y)) == cell:
			row.growth_days = int(row.growth_target)
	main.farm_state.deserialize(raw)
	var quantity: int = int(main.farm_state.get_harvest_payload(cell).quantity)
	main.tool_controller.perform_crop_action(cell, &"harvest")
	assert_eq(f.current_counts().crop_harvested, quantity)
	assert_gt(quantity, 0)
	main.tool_controller.perform_crop_action(cell, &"harvest")
	assert_eq(f.current_counts().crop_harvested, quantity)

func test_actual_seed_shipping_minh_and_feed_item_routes_record_actual_quantity_once() -> void:
	main.wallet.deserialize({"coins": 10000})
	var guarded: Array[bool] = []
	_watch(main.seed_shop_panel.item_purchased, func(_id: StringName, _qty: int, _coins: int) -> void:
		guarded.append(main.director_activity_collector.busy)
		guarded.append(not main._save_game_to_slot(98))
		main._start_new_game("Blocked", "Blocked")
	)
	var seed: StringName = DataRegistry.get_starter_seed_for_season(GameClock.season)
	assert_true(main.seed_shop_panel.try_buy_item(seed, 3))
	assert_eq(guarded, [true, true])
	assert_eq(main.profile.farm_name, "Garden")
	assert_eq(f.current_counts().item_purchased, 3)
	var crop: CropData = DataRegistry.get_crop_for_seed(seed) as CropData
	assert_eq(main.inventory.add_item(crop.product_item, 3), 3)
	main.shipping_bin_panel._selected_item_id = crop.product_item
	main.shipping_bin_panel._selected_quantity = 2
	main.shipping_bin_panel._confirm_sale()
	assert_eq(f.current_counts().item_sold, 2)
	f.open_coop(10000)
	await f.settle(self)
	main.chicken_coop_flow.command(&"buy_coop", ChickenCoopRuntime.CONFIG.initial_hens)
	assert_true(main.chicken_coop.is_owned())
	main.chicken_coop_flow.command(&"buy_feed", 2)
	assert_true(main.chicken_coop_flow.result.ok)
	assert_eq(f.current_counts().item_purchased, 5)
	main.ui_coordinator.close_active()
	var offer: MerchantOfferData = main.npc_system.state.merchant.get_offer(GameClock.day_index, GameClock.season)
	if offer.kind == "request":
		assert_eq(main.inventory.add_item(offer.item_id, offer.quantity), offer.quantity)
	var market: Vector2i = main.npc_system.state.scheduler.location_cell(&"minh_market")
	main.npc_system.state.targets[&"minh"] = &"minh_market"
	main.npc_system.state.cells[&"minh"] = market
	main.npc_system.actors[&"minh"].reset_position()
	main.world.player.move_to_cell(market + Vector2i(0, 1))
	var before: Dictionary = f.current_counts()
	main.npc_system._trade()
	assert_true(main.npc_system.state.merchant.is_consumed(GameClock.day_index))
	var id: String = "item_purchased" if offer.kind == "discount" else "item_sold"
	assert_eq(int(f.current_counts()[id]), int(before[id]) + offer.quantity)
	var completed: Dictionary = f.current_counts()
	main.npc_system._trade()
	assert_eq(f.current_counts(), completed)

func test_raw_debug_bulk_rain_and_forged_producer_signals_never_become_human_receipts() -> void:
	var before: Dictionary = f.current_counts()
	assert_true(main.farm_state.till_cell(Vector2i(2, 2)))
	assert_true(main.farm_state.plant_crop(Vector2i(2, 2), &"turnip"))
	main.farm_state.water_all_crops()
	Events.item_purchased.emit(&"turnip_seed", 77, 1)
	Events.item_sold.emit(&"turnip", 88, 1)
	Events.plot_watered.emit(Vector2i(2, 2))
	main.inventory.add_item(&"turnip_seed", 4)
	main.wallet.add_coins(123, &"debug")
	assert_eq(f.current_counts(), before)
	assert_true(main.director_activity.serialize().current_complete)

func test_atomic_receipt_batch_partial_coverage_and_day_reservations_preserve_five_field_wire() -> void:
	var owner: DirectorActivityState = main.director_activity
	var before: Dictionary = owner.serialize()
	assert_false(owner.record_many(0, {"plot_tilled": 1, "unknown_source": 1}).ok)
	assert_eq(owner.serialize(), before)
	assert_true(owner.record_many(0, {"plot_tilled": 2, "item_sold": 3}).ok)
	assert_eq(owner.serialize().current_counts.plot_tilled, 2)
	assert_eq(owner.serialize().current_counts.item_sold, 3)
	var receipt: Dictionary = main.director_activity_collector.begin_command(&"tool")
	assert_true(receipt.ok)
	assert_false(main.director_activity_collector.finish_command(receipt.token, {"unknown_source": 1}))
	assert_false(owner.serialize().current_complete)
	assert_eq(owner.serialize().current_counts.plot_tilled, 2)
	var token: RefCounted = owner.begin_day(1).token
	assert_true(owner.is_busy())
	assert_false(owner.record_many(0, {"plot_tilled": 1}).ok)
	assert_false(owner.mark_partial(0).ok)
	assert_false(main._save_game_to_slot(98))
	assert_false(owner.deserialize(before))
	assert_false(owner.abort_day(RefCounted.new()))
	assert_eq(owner.serialize().size(), 5)
	assert_true(owner.finish_day(token).ok)
	assert_false(owner.finish_day(token).ok)
	assert_false(owner.serialize().completed_days[0].complete)
	assert_eq(int(owner.serialize().current_day), 1)

func test_existing_inactive_backend_tool_contract_keeps_fx_but_never_claims_human_activity() -> void:
	assert_true(main._return_to_start_menu())
	main._game_started = false
	main.inventory.clear()
	main.tool_controller.select_seed()
	main.tool_controller._hovered_cell = Vector2i(1, 1)
	main.tool_controller._use_selected_tool()
	var effects: FarmEffects = main.world.get_node("WorldCanvas/FarmEffects") as FarmEffects
	assert_eq(effects.get_child_count(), 0)
	assert_true(main.farm_state.till_cell(Vector2i(1, 1)))
	assert_eq(main.inventory.add_item(&"turnip_seed", 1), 1)
	main.tool_controller._use_selected_tool()
	assert_gt(effects.get_child_count(), 0)
	assert_eq(main.director_activity_collector.last_reason, &"inactive_command")
	assert_false(main.director_activity.serialize().current_complete)
	for quantity: Variant in f.current_counts().values():
		assert_eq(int(quantity), 0)
