extends GutTest

class CountingSimulator extends RefCounted:
	var calls: int = 0
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		DaySimulator.new().simulate_day(farm)

var _clock: Dictionary
var _paused: bool
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({})
	GameClock.paused = true

func after_each() -> void:
	await get_tree().process_frame
	if is_instance_valid(_viewport):
		_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func _game() -> void:
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	_main.set("_game_started",true)
	_main.day_end_flow.reset()
	GameClock.paused = true

func test_three_manual_forced_and_direct_nights_have_equivalent_simulation() -> void:
	var results: Array[Dictionary] = []
	for mode: String in ["manual","forced","direct"]:
		GameClock.deserialize({})
		_game()
		var spy: CountingSimulator = CountingSimulator.new()
		_main.day_simulator = spy
		_main.farm_state.till_cell(Vector2i.ZERO)
		_main.farm_state.plant_crop(Vector2i.ZERO,&"turnip")
		for night: int in range(3):
			_main.farm_state.water_all_crops()
			if mode=="direct":
				GameClock.sleep_to_morning()
			else:
				GameClock.set_time(20 if mode=="manual" else 25,0 if mode=="manual" else 59)
				if mode=="manual":
					assert_true(_main.day_end_flow.request())
				else:
					GameClock.advance_minutes(1)
				_main.day_end_flow.confirm()
			assert_eq(spy.calls,night+1)
			assert_eq(GameClock.day_index,night+1)
		results.append({"farm":_main.farm_state.serialize(),"weather":_main.weather_state.serialize(),"clock":GameClock.serialize(),"wallet":_main.wallet.serialize(),"inventory":_main.inventory.serialize()})
		await get_tree().process_frame
		_viewport.free()
	assert_eq(results[0],results[1],"Manual and forced review use identical simulation")
	assert_eq(results[0],results[2],"Existing direct clock API remains simulation-equivalent")

func test_forced_review_survives_restore_and_continue_chooses_completed_morning() -> void:
	_game()
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	var saved: Dictionary = SaveService.load_game(1)
	assert_true(saved["day_end"]["forced"])
	_main.call("_load_payload",saved)
	var flow: LifeDayEndFlow = _main.day_end_flow
	assert_true(flow.panel.visible)
	assert_true(GameClock.is_day_end_held())
	assert_false(flow.cancel())
	assert_false(flow.panel.stay_button.visible)
	flow.confirm()
	assert_eq(int(SaveService.load_latest()["clock"]["day_index"]),1)
	_main.call("_continue_game")
	assert_eq(GameClock.day_index,1)
	assert_false(flow.panel.visible)
	flow.confirm()
	assert_eq(GameClock.day_index,1)
