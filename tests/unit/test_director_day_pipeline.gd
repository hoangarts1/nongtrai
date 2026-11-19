extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")

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

func test_reservation_spans_farm_weather_callbacks_and_seals_outgoing_receipts_before_autosave() -> void:
	f.use(&"hoe", Vector2i(1, 1))
	var spy: FarmSpy = FarmSpy.new()
	main.day_simulator = spy
	var attempts: Array[bool] = []
	spy.during = func() -> void:
		attempts.append(main.director_activity.is_busy())
		attempts.append(main.director_state.is_busy())
		attempts.append(not main._save_game_to_slot(98))
		attempts.append(not main._load_game_from_slot(98))
		attempts.append(not main._return_to_start_menu())
		attempts.append(not main.day_end_flow.request())
		attempts.append(not main.director_runtime.set_enabled(true))
		var before: Dictionary = f.owners()
		main._on_day_started(GameClock.day_index)
		main._start_new_game("Blocked", "Blocked")
		attempts.append(f.owners() == before)
	var callback: Callable = func(_id: StringName) -> void:
		if main.director_daily_flow.busy:
			attempts.append(main.director_activity.is_busy())
			attempts.append(main.director_state.is_busy())
			attempts.append(main.ecology_state.get_day_index() == GameClock.day_index)
			attempts.append(int(main.chicken_coop.coop.serialize().current_day) == GameClock.day_index)
	main.weather_state.weather_changed.connect(callback)
	_watches.append({"source": main.weather_state.weather_changed, "callback": callback})
	await f.advance(self)
	spy.during = Callable()
	assert_eq(spy.calls, 1)
	assert_eq(attempts.size(), 12)
	for allowed: bool in attempts:
		assert_true(allowed)
	var observation: Dictionary = main.director_activity.serialize()
	assert_eq(int(observation.current_day), 1)
	assert_eq(int(observation.completed_days[0].day_index), 0)
	assert_true(observation.completed_days[0].complete)
	assert_eq(int(observation.completed_days[0].counts.plot_tilled), 1)
	assert_eq(int(observation.current_counts.plot_tilled), 0)
	var saved: Dictionary = SaveService.load_game(0)
	assert_eq(saved.director_activity, observation)
	assert_eq(saved.director, main.director_state.serialize())
	assert_eq(int(saved.weather.day_index), 1)
	assert_eq(int(saved.ecology.day_index), 1)
	assert_false(main.director_runtime.is_busy())

func test_duplicate_skipped_stale_or_preclock_days_do_not_change_any_owner_or_save() -> void:
	var before: Dictionary = f.owners()
	assert_false(main.director_daily_flow.begin(1).ok)
	for day: int in [-1, 0, 1, 2, 99]:
		main._on_day_started(day)
	assert_eq(f.owners(), before)
	await f.advance(self)
	var after: Dictionary = f.owners()
	var saved: String = FileAccess.get_file_as_string("user://saves/slot_0.json")
	for day: int in [-1, 0, 1, 2, 99]:
		main._on_day_started(day)
	GameClock.day_started.emit(GameClock.day_index)
	assert_eq(f.owners(), after)
	assert_eq(FileAccess.get_file_as_string("user://saves/slot_0.json"), saved)
	assert_eq(main.director_state.serialize().history.size(), 1)

func test_manual_and_cutoff_review_hold_same_day_then_confirm_exactly_one_committed_morning() -> void:
	f.use(&"hoe", Vector2i(1, 1))
	for forced: bool in [false, true]:
		var day: int = GameClock.day_index
		if forced:
			GameClock.minute = GameClock.DAY_END_MINUTE - 1
			GameClock.paused = false
			GameClock._process(1.0)
			GameClock.paused = true
		else:
			GameClock.set_time(20, 0)
			assert_true(main.day_end_flow.request())
		assert_true(main.day_end_flow.panel.visible)
		assert_eq(GameClock.day_index, day)
		assert_eq(int(main.director_activity.serialize().current_day), day)
		assert_eq(main.director_state.serialize().history.size(), day)
		if not forced:
			assert_true(main.day_end_flow.cancel())
			assert_eq(GameClock.day_index, day)
			assert_true(main.day_end_flow.request())
		main.day_end_flow.confirm()
		main.day_end_flow.confirm()
		assert_eq(GameClock.day_index, day + 1)
		assert_eq(main.director_state.serialize().history.size(), day + 1)
		assert_eq(main.director_activity.serialize().completed_days.size(), day + 1)
		var saved: Dictionary = SaveService.load_game(0)
		assert_eq(saved.director, main.director_state.serialize())
		assert_eq(saved.director_activity, main.director_activity.serialize())
		await f.settle(self)
		main.morning_flow.reset()
		main.ui_coordinator.close_active()

func test_choice_uses_completed_current_owners_and_saved_forecast_with_two_day_telegraph() -> void:
	await f.prepare_dust(self)
	var pending: Dictionary = main.director_state.serialize().pending[0]
	assert_eq(int(pending.decision_day), 8)
	assert_eq(int(pending.start_day), 10)
	assert_eq(int(pending.end_day), 11)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	await f.advance(self, 1, 100.0, 0.0)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
	await f.advance(self, 1, 100.0, 0.0)
	assert_eq(main.watering_runtime.get_charge_cost(), 2)
	var source: Dictionary = main.director_runtime.capture_observation()
	assert_true(source.ok)
	assert_true(source.ready)
	assert_eq(int(source.source.activity.current_day), GameClock.day_index)
	assert_eq(int(source.source.ecology.state.day_index), GameClock.day_index)
	assert_eq(int(source.source.weather.day_index), GameClock.day_index)
	assert_eq(int(source.source.activity.completed_days.back().day_index), GameClock.day_index - 1)
	var before: Dictionary = f.owners()
	for _index: int in range(10):
		main.director_runtime.capture_observation()
		main.director_runtime.get_projection(true)
	assert_eq(f.owners(), before)

func test_existing_direct_clock_contract_at_title_keeps_unknown_coverage_partial_without_fake_activity() -> void:
	assert_true(main._return_to_start_menu())
	var spy: FarmSpy = FarmSpy.new()
	main.day_simulator = spy
	for _day: int in range(8):
		GameClock.sleep_to_morning()
	assert_eq(spy.calls, 8, "Existing explicit clock calls keep the core simulator contract")
	assert_true(main.start_menu.visible)
	assert_false(main.director_runtime.set_enabled(true))
	var window: Dictionary = main.director_activity.get_window_snapshot()
	assert_eq(window.observed_days, 7)
	assert_eq(window.complete_days, 0)
	assert_false(window.available)
	assert_false(main.director_activity.serialize().current_complete)
	for quantity: Variant in f.current_counts().values():
		assert_eq(int(quantity), 0)
	for record: Dictionary in main.director_state.serialize().history:
		assert_eq(record.event_id, "")
		assert_null(record.seed_used)
