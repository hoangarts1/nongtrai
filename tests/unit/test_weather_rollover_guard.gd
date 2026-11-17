extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")

class FarmSpy extends RefCounted:
	var calls: int = 0
	var during: Callable
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		if during.is_valid():
			during.call()
		DaySimulator.new().simulate_day(farm)

var f: RefCounted
var main: Node
var spy: FarmSpy

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	spy = FarmSpy.new()
	main.day_simulator = spy

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_duplicate_skipped_stale_or_wrong_clock_signals_change_no_owner_or_save() -> void:
	var before: Dictionary = _owners()
	for day: int in [-1,0,1,2,99]:
		main.call("_on_day_started",day)
	assert_eq(_owners(),before)
	assert_eq(spy.calls,0)
	GameClock.sleep_to_morning()
	var after: Dictionary = _owners()
	var save: String = FileAccess.get_file_as_string("user://saves/slot_0.json")
	GameClock.day_started.emit(1)
	main.call("_on_day_started",0)
	main.call("_on_day_started",2)
	assert_eq(_owners(),after)
	assert_eq(spy.calls,1)
	assert_eq(FileAccess.get_file_as_string("user://saves/slot_0.json"),save)

func test_outgoing_farm_callback_cannot_reenter_replace_or_save_reserved_weather() -> void:
	var attempts: Array[bool] = []
	var original: Dictionary = main.weather_state.serialize()
	spy.during = func() -> void:
		attempts.append(main.weather_state.is_busy())
		attempts.append(bool(main.call("_save_game_to_slot",98)))
		attempts.append(bool(main.call("_load_game_from_slot",1)))
		attempts.append(bool(main.call("_return_to_start_menu")))
		attempts.append(main.day_end_flow.request())
		main.call("_on_day_started",GameClock.day_index)
		main.call("_start_new_game","Other","Other")
		main.call("_load_payload",{})
		main.weather_state.force_weather(&"storm")
		main.weather_state.deserialize({})
		main.weather_state.advance_day(GameClock.day_index+1)
	GameClock.sleep_to_morning()
	assert_eq(attempts,[true,false,false,false,false])
	assert_eq(spy.calls,1)
	assert_eq(main.profile.player_name,"Mai")
	assert_eq(main.weather_state.today,StringName(original.forecast[0]))
	assert_eq(main.weather_state.get_day_index(),1)
	assert_false(main.weather_state.is_busy())
	assert_false(main.call("_purchase_in_progress"))
	assert_eq(SaveService.load_game(0).weather,main.weather_state.serialize())

func test_local_and_global_weather_callbacks_block_lifecycle_until_completed_save() -> void:
	var seen: Array[bool] = []
	var callback: Callable = func(_id: StringName) -> void:
		seen.append(main.weather_state.is_busy())
		seen.append(bool(main.call("_save_game_to_slot",98)))
		seen.append(bool(main.call("_return_to_start_menu")))
		main.call("_on_day_started",GameClock.day_index)
		main.call("_start_new_game","Other","Other")
		main.call("_continue_game")
	main.weather_state.weather_changed.connect(callback)
	Events.weather_changed.connect(callback)
	GameClock.sleep_to_morning()
	Events.weather_changed.disconnect(callback)
	assert_eq(seen,[true,false,false,true,false,false])
	assert_eq(spy.calls,1)
	assert_eq(main.profile.player_name,"Mai")
	assert_eq(main.weather_state.get_day_index(),GameClock.day_index)
	assert_eq(SaveService.load_game(0).weather,main.weather_state.serialize())
	assert_false(main.weather_state.is_busy())

func test_outgoing_rain_and_new_sun_care_order_uses_the_saved_forecast() -> void:
	main.farm_state.till_cell(Vector2i.ZERO)
	main.farm_state.plant_crop(Vector2i.ZERO,&"turnip")
	main.weather_state.deserialize({"world_seed":0,"today":"rain","forecast":["sunny","rain","cloudy"],"day_index":0})
	GameClock.sleep_to_morning()
	assert_eq(spy.calls,1)
	assert_eq(main.weather_state.today,&"sunny")
	assert_eq(int(main.farm_state.get_plot(Vector2i.ZERO).growth_days),1)
	assert_eq(int(main.farm_state.get_plot(Vector2i.ZERO).consecutive_dry_days),0)
	assert_false(bool(main.farm_state.get_plot(Vector2i.ZERO).watered))
	main.morning_flow.dismiss()
	var dry_before_rain: Array[int] = []
	var on_plot: Callable = func(cell: Vector2i) -> void:
		if not bool(main.farm_state.get_plot(cell).watered):
			dry_before_rain.append(int(main.farm_state.get_plot(cell).consecutive_dry_days))
	main.farm_state.plot_changed.connect(on_plot)
	GameClock.sleep_to_morning()
	main.farm_state.plot_changed.disconnect(on_plot)
	assert_eq(main.weather_state.today,&"rain")
	assert_true(bool(main.farm_state.get_plot(Vector2i.ZERO).watered))
	assert_has(dry_before_rain,1,"Finished-day care runs before the new rain resets its counter")
	assert_eq(int(main.farm_state.get_plot(Vector2i.ZERO).consecutive_dry_days),0)
	assert_eq(spy.calls,2)

func test_manual_forced_and_direct_mornings_commit_once_and_bulletin_reads_saved_weather() -> void:
	for mode: int in range(3):
		main.call("_start_new_game","Mai","Garden")
		main.tutorial_panel.close_help()
		main.ui_coordinator.close_active()
		GameClock.paused = false
		var expected: StringName = main.weather_state.forecast[0]
		if mode==0:
			GameClock.set_time(20,0)
			assert_true(main.day_end_flow.request())
			main.day_end_flow.confirm()
		elif mode==1:
			GameClock.set_time(25,59)
			GameClock.advance_minutes(1)
			main.day_end_flow.confirm()
		else:
			GameClock.sleep_to_morning()
		await f.settle(self)
		assert_eq(spy.calls,mode+1)
		assert_eq(main.weather_state.get_day_index(),1)
		assert_eq(main.weather_state.today,expected)
		assert_eq(MorningSnapshot.capture(main).weather,expected)
		assert_eq(SaveService.load_game(0).weather,main.weather_state.serialize())
		assert_true(main.morning_flow.panel.visible)
		main.day_end_flow.confirm()
		main.morning_flow.dismiss()
		assert_eq(spy.calls,mode+1)

func _owners() -> Dictionary:
	var result: Dictionary = f.owners()
	result.weather = main.weather_state.serialize()
	result.ledger = main.day_end_flow.ledger.serialize()
	return result
