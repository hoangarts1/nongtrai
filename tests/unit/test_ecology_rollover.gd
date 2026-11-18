extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var _fixture: RefCounted
var _main: Node
var _goal: int
var _sampling: EcologySamplingConfig

class FarmSpy extends RefCounted:
	var calls: int = 0
	var during: Callable
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		if during.is_valid():
			during.call()
		DaySimulator.new().simulate_day(farm)

func before_each() -> void:
	_sampling = LifeEcologyRuntime.SAMPLING
	_goal = _sampling.mature_tree_goal
	_fixture = FIXTURE.new()
	_fixture.setup(self)
	_main = _fixture.main

func after_each() -> void:
	_sampling.mature_tree_goal = _goal
	await get_tree().process_frame
	_fixture.cleanup()

func _row(id: String, growth: int, target: int) -> Dictionary:
	return {"cell_x": 0, "cell_y": 0, "crop_id": id, "tilled": true, "growth_days": growth, "growth_target": target, "regrowing": false, "watered": true, "consecutive_dry_days": 0, "withered": false, "withered_days": 0}

func _maturing_tree() -> void:
	var crop: CropData = DataRegistry.get_crop(&"orange") as CropData
	_main.farm_state.deserialize({"plots": [_row("orange", crop.growth_days - 1, crop.growth_days)]})
	_main.weather_state.force_weather(&"sunny")

func _owners() -> Dictionary:
	var snapshot: Dictionary = _fixture.owners()
	snapshot.ecology = _main.ecology_state.serialize()
	snapshot.weather = _main.weather_state.serialize()
	return snapshot

func test_manual_cutoff_and_direct_mornings_ease_once_before_autosave() -> void:
	for mode: int in range(3):
		_main.call("_start_new_game", "Mai", "Garden")
		_main.tutorial_panel.close_help()
		_main.ui_coordinator.close_active()
		GameClock.paused = false
		_maturing_tree()
		if mode == 0:
			GameClock.set_time(20, 0)
			assert_true(_main.day_end_flow.request())
			_main.day_end_flow.confirm()
		elif mode == 1:
			GameClock.set_time(25, 59)
			GameClock.advance_minutes(1)
			_main.day_end_flow.confirm()
		else:
			GameClock.sleep_to_morning()
		await _fixture.settle(self)
		assert_eq(_main.ecology_state.get_day_index(), 1)
		assert_eq(_main.ecology_state.get_metrics().tree_cover, 1.25)
		assert_eq(_main.ecology_state.get_metrics().biodiversity, 1.25)
		assert_eq(SaveService.load_game(0).ecology, _main.ecology_state.serialize())
		assert_true(_main.morning_flow.panel.visible)
		assert_false(_main.call("_purchase_in_progress"))
		_main.morning_flow.dismiss()

func test_duplicate_stale_skipped_signals_change_no_owner_or_save() -> void:
	var before: Dictionary = _owners()
	for day: int in [-1, 0, 1, 2, 99]:
		_main.call("_on_day_started", day)
	assert_eq(_owners(), before)
	GameClock.sleep_to_morning()
	var after: Dictionary = _owners()
	var saved: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_0.json")
	for day: int in [0, 1, 2, 99]:
		_main.call("_on_day_started", day)
	assert_eq(_owners(), after)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_0.json"), saved)

func test_farm_and_ecology_callbacks_cannot_mutate_reserved_owner_or_reenter_main() -> void:
	_maturing_tree()
	var spy: FarmSpy = FarmSpy.new()
	_main.day_simulator = spy
	var calls: Array[int] = [0]
	spy.during = func() -> void:
		calls[0] += 1
		assert_true(_main.ecology_state.is_busy())
		assert_false(_main.ecology_state.configure(LifeEcologyRuntime.PROFILE))
		assert_false(_main.ecology_state.deserialize(_main.ecology_state.serialize()))
		assert_false(_main.ecology_state.advance_day(GameClock.day_index, {"tree_cover": 100, "water_clarity": 100, "biodiversity": 100}).ok)
		assert_false(_main.call("_save_game_to_slot", 98))
		assert_false(_main.call("_load_payload", {}))
		assert_false(_main.call("_return_to_start_menu"))
		assert_false(_main.day_end_flow.request())
		_main.call("_on_day_started", GameClock.day_index)
		_main.call("_start_new_game", "Wrong", "Wrong")
	var publication: Callable = func(_metrics: Dictionary) -> void:
		assert_eq(_main.ecology_state.get_day_index(), GameClock.day_index)
		assert_false(_main.call("_save_game_to_slot", 98))
		assert_false(_main.ecology_state.configure(LifeEcologyRuntime.PROFILE))
	_main.ecology_state.ecology_changed.connect(publication)
	GameClock.sleep_to_morning()
	_main.ecology_state.ecology_changed.disconnect(publication)
	assert_eq(calls[0], 1)
	assert_eq(spy.calls, 1)
	assert_eq(_main.profile.player_name, "Mai")
	assert_eq(_main.ecology_state.get_metrics().tree_cover, 1.25)
	assert_eq(SaveService.load_game(0).ecology, _main.ecology_state.serialize())

func test_new_season_withering_is_sampled_before_ecology_and_morning_sun() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v13.json"))
	raw.clock = {"day_index": 27, "minute": 1200, "season": "spring", "year": 1}
	raw.chicken_coop.coop.current_day = 27
	var crop: CropData = DataRegistry.get_crop(&"spring_carrot") as CropData
	raw.farm = {"plots": [_row("spring_carrot", 1, crop.growth_days)]}
	raw.weather = {"day_index": 27, "world_seed": 0, "today": "sunny", "forecast": ["sunny", "sunny", "sunny"]}
	raw.ecology = {"day_index": 27, "metrics": {"tree_cover": 0, "water_clarity": 42.5, "biodiversity": 100}, "triggered": []}
	assert_true(_main.call("_load_payload", raw))
	GameClock.sleep_to_morning()
	assert_eq(GameClock.season, &"summer")
	assert_true(_main.farm_state.get_plot(Vector2i.ZERO).withered)
	assert_eq(_main.ecology_state.get_metrics().biodiversity, 90.0)
	assert_eq(_main.ecology_state.get_metrics().water_clarity, 42.5)
	assert_eq(_main.ecology_state.get_day_index(), 28)
	assert_eq(SaveService.load_game(0).ecology, _main.ecology_state.serialize())

func test_sampler_configuration_is_frozen_before_farm_callbacks() -> void:
	_maturing_tree()
	var spy: FarmSpy = FarmSpy.new()
	_main.day_simulator = spy
	spy.during = func() -> void: _sampling.mature_tree_goal = 1
	GameClock.sleep_to_morning()
	_sampling.mature_tree_goal = _goal
	assert_eq(_main.ecology_state.get_metrics().tree_cover, 1.25)
	assert_false(_main.ecology_state.is_busy())
	assert_false(_main.ecology_runtime.busy)

func test_invalid_preflight_does_not_simulate_save_or_open_a_bulletin() -> void:
	var spy: FarmSpy = FarmSpy.new()
	_main.day_simulator = spy
	var before: Dictionary = _owners()
	before.erase("clock")
	var saved: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	_sampling.mature_tree_goal = 0
	# Existing clock-first adapter has already emitted the next morning index.
	GameClock.day_index = 1
	_main.call("_on_day_started", 1)
	_sampling.mature_tree_goal = _goal
	var after: Dictionary = _owners()
	after.erase("clock")
	assert_eq(after, before)
	assert_eq(spy.calls, 0)
	assert_false(_main.morning_flow.panel.visible)
	assert_false(_main.weather_state.is_busy())
	assert_false(_main.ecology_runtime.busy)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"), saved)
