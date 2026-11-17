extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_purchase_callbacks_block_all_normal_lifecycle_paths_and_second_facade() -> void:
	f.open()
	GameClock.set_time(21,0)
	var ran: Array[bool] = []
	main.wallet.coins_changed.connect(func(_t: int,delta: int,reason: StringName) -> void:
		if delta>=0 or reason!=&"buy_chicken_coop":
			return
		ran.append(true)
		assert_true(main.call("_purchase_in_progress"))
		assert_false(main.call("_save_game_to_slot",98))
		assert_false(main.call("_load_game_from_slot",1))
		assert_false(main.call("_return_to_start_menu"))
		assert_false(main.day_end_flow.request())
		main.call("_start_new_game","Other","Other")
		main.call("_load_payload",{})
		assert_eq(main.profile.player_name,"Mai")
		var second: ChickenCoopShopService = ChickenCoopShopService.new()
		second.configure(main.chicken_coop_runtime.CONFIG,main.chicken_coop,main.inventory,main.wallet)
		assert_false(second.purchase(&"buy_coop",4,main.chicken_coop_runtime.occupied_cells).ok)
		main.chicken_coop_flow.close()
		assert_true(main.chicken_coop_flow.panel.visible)
	)
	main.chicken_coop_flow.command(&"buy_coop",4)
	assert_eq(ran.size(),1)
	assert_true(main.chicken_coop.is_owned())
	assert_eq(main.wallet.get_coins(),300)
	assert_false(main.call("_purchase_in_progress"))

func test_food_callbacks_block_collection_and_feeding_preserving_independent_inventory() -> void:
	f.open()
	main.chicken_coop_flow.command(&"buy_coop",4)
	var ran: Array[bool] = []
	main.inventory.inventory_changed.connect(func(_s: Array[Dictionary]) -> void:
		if not ran.is_empty():
			return
		ran.append(true)
		assert_eq(main.inventory.get_quantity(&"chicken_feed"),4)
		assert_false(main.chicken_coop_runtime.feeding.feed(0,1).ok)
		assert_false(main.chicken_coop_runtime.collection.collect(1).ok)
		assert_false(main.chicken_coop.coop.advance_day(0).ok)
		assert_false(main.call("_save_game_to_slot",98))
		main.inventory.add_item(&"egg",1)
	)
	main.chicken_coop_flow.command(&"buy_feed",4)
	assert_eq(ran.size(),1)
	assert_eq(main.inventory.get_quantity(&"egg"),1)
	assert_eq(main.inventory.get_quantity(&"chicken_feed"),4)
	assert_eq(int(main.chicken_coop.coop.serialize().fed_hens),0)
	assert_false(main.chicken_coop.coop.is_busy())

func test_daily_farm_callback_cannot_reenter_simulation_or_mutate_reserved_coop() -> void:
	f.open()
	main.chicken_coop_flow.command(&"buy_coop",4)
	main.chicken_coop_flow.command(&"buy_feed",4)
	main.chicken_coop_flow.command(&"feed",4)
	main.chicken_coop_flow.close()
	main.farm_state.till_cell(Vector2i.ZERO)
	main.farm_state.plant_crop(Vector2i.ZERO,&"turnip")
	main.farm_state.water_cell(Vector2i.ZERO)
	var callbacks: Array[bool] = []
	main.farm_state.plot_changed.connect(func(_cell: Vector2i) -> void:
		callbacks.append(true)
		assert_true(main.chicken_coop.coop.is_busy())
		assert_false(main.chicken_coop.coop.advance_day(0).ok)
		main.day_simulator.simulate_day(main.farm_state,main.chicken_coop.coop,main.machine_operations,0)
	)
	GameClock.sleep_to_morning()
	assert_false(callbacks.is_empty())
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),4)
	assert_eq(int(main.chicken_coop.coop.serialize().current_day),1)
	assert_false(main.chicken_coop.coop.is_busy())

func test_rain_and_weather_callbacks_cannot_replace_owners_mid_rollover() -> void:
	f.open()
	main.chicken_coop_flow.command(&"buy_coop",4)
	main.chicken_coop_flow.close()
	main.farm_state.till_cell(Vector2i.ZERO)
	main.farm_state.plant_crop(Vector2i.ZERO,&"turnip")
	main.weather_state.force_weather(&"rain")
	var callbacks: Array[bool] = []
	main.farm_state.plot_changed.connect(func(_cell: Vector2i) -> void:
		callbacks.append(true)
		assert_true(main.call("_purchase_in_progress"))
		assert_false(main.call("_save_game_to_slot",98))
		main.call("_start_new_game","Other","Other")
		assert_eq(main.profile.player_name,"Mai")
	)
	GameClock.sleep_to_morning()
	assert_false(callbacks.is_empty())
	assert_false(main.call("_purchase_in_progress"))
	assert_true(main.chicken_coop.is_owned())
	assert_eq(int(main.chicken_coop.coop.serialize().current_day),GameClock.day_index)
