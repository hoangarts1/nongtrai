extends GutTest

const CONFIG: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
var _state: DirectorActivityState

func before_each() -> void:
	_state = DirectorActivityState.new()

func test_unconfigured_and_rejected_configuration_never_replace_existing_observations() -> void:
	assert_eq(_state.serialize(), {})
	assert_false(_state.record(0, &"plot_tilled", 1).ok)
	assert_false(_state.advance_day(1).ok)
	assert_false(_state.deserialize({}))
	assert_false(_state.get_window_snapshot().ok)
	assert_true(_state.configure(CONFIG, 100))
	var before: Dictionary = _state.serialize()
	for config: DirectorActivityConfig in [null, DirectorActivityConfig.new()]:
		assert_false(_state.configure(config, 0, true))
		assert_eq(_state.serialize(), before)
	assert_false(_state.configure(CONFIG, -1))
	assert_eq(_state.serialize(), before)

func test_partial_first_day_and_missing_history_are_unavailable_until_seven_complete_days() -> void:
	assert_true(_state.configure(CONFIG, 100))
	assert_eq(_state.serialize().completed_days, [])
	assert_false(_state.serialize().current_complete)
	assert_true(_state.record(100, &"crop_planted", 99).ok)
	assert_true(_state.advance_day(101).ok)
	for day: int in range(101, 107):
		assert_true(_state.record(day, &"crop_planted", 1).ok)
		assert_true(_state.advance_day(day + 1).ok)
	var window: Dictionary = _state.get_window_snapshot()
	assert_eq(window.observed_days, 7)
	assert_eq(window.complete_days, 6)
	assert_false(window.available)
	assert_eq(window.totals, {}, "Partial coverage must not look like measured zeros")
	assert_true(_state.record(107, &"crop_planted", 1).ok)
	assert_true(_state.advance_day(108).ok)
	window = _state.get_window_snapshot()
	assert_true(window.available)
	assert_eq(window.totals.crop_planted, 7, "Partial day99 is evicted rather than counted")
	assert_eq(_state.serialize().completed_days[0].day_index, 101)
	assert_eq(_state.serialize().started_day, 100)

func test_fully_observed_zero_days_are_valid_and_open_day_never_enters_window_early() -> void:
	assert_true(_state.configure(CONFIG, 0, true))
	for day: int in range(7):
		assert_true(_state.advance_day(day + 1).ok)
	assert_true(_state.record(7, &"crop_harvested", 123).ok)
	var window: Dictionary = _state.get_window_snapshot()
	assert_true(window.available)
	assert_eq(window.totals.crop_harvested, 0)
	assert_true(_state.advance_day(8).ok)
	assert_eq(_state.get_window_snapshot().totals.crop_harvested, 123)

func test_wrong_days_ids_quantities_and_overflow_are_atomic_and_eviction_releases_capacity() -> void:
	assert_true(_state.configure(CONFIG, 0, true))
	var before: Dictionary = _state.serialize()
	for day: int in [-1, 1, 99]:
		assert_false(_state.record(day, &"plot_tilled", 1).ok)
		assert_eq(_state.serialize(), before)
	for day: int in [-1, 0, 2, 99]:
		assert_false(_state.advance_day(day).ok)
		assert_eq(_state.serialize(), before)
	assert_false(_state.record(0, &"wood_chopped", 1).ok)
	for quantity: int in [-1, 0, DirectorActivityCodec.MAX_JSON_INTEGER + 1]:
		assert_false(_state.record(0, &"plot_tilled", quantity).ok)
		assert_eq(_state.serialize(), before)
	assert_true(_state.record(0, &"crop_harvested", DirectorActivityCodec.MAX_JSON_INTEGER - 1).ok)
	assert_true(_state.advance_day(1).ok)
	assert_true(_state.record(1, &"crop_harvested", 1).ok)
	before = _state.serialize()
	assert_false(_state.record(1, &"crop_harvested", 1).ok)
	assert_eq(_state.serialize(), before)
	for day: int in range(2, 9):
		assert_true(_state.advance_day(day).ok)
	assert_true(_state.record(8, &"crop_harvested", DirectorActivityCodec.MAX_JSON_INTEGER - 1).ok)

func test_frozen_config_and_all_returned_dictionaries_cannot_mutate_owner() -> void:
	var config: DirectorActivityConfig = CONFIG.duplicate(true) as DirectorActivityConfig
	assert_true(_state.configure(config, 0, true))
	config.window_days = 14
	config.activity_ids.clear()
	for day: int in range(7):
		assert_true(_state.record(day, &"item_sold", 2).ok)
		assert_true(_state.advance_day(day + 1).ok)
	var before: Dictionary = _state.serialize()
	var wire: Dictionary = _state.serialize()
	wire.current_counts.item_sold = 999
	wire.completed_days[0].counts.item_sold = 999
	var window: Dictionary = _state.get_window_snapshot()
	assert_eq(window.window_days, 7)
	assert_eq(window.totals.item_sold, 14)
	window.totals.item_sold = 999
	assert_eq(_state.serialize(), before)

func test_notification_reentry_is_locked_but_reads_are_atomic_and_load_is_silent() -> void:
	assert_true(_state.configure(CONFIG, 0, true))
	var calls: Array[int] = [0]
	var observer: Callable = func(day: int) -> void:
		calls[0] += 1
		assert_true(_state.is_busy())
		assert_eq(_state.serialize().current_day, day)
		var before: Dictionary = _state.serialize()
		assert_false(_state.record(day, &"plot_tilled", 1).ok)
		assert_false(_state.advance_day(day + 1).ok)
		assert_false(_state.configure(CONFIG, day))
		assert_false(_state.deserialize(before))
		assert_eq(_state.serialize(), before)
	_state.activity_changed.connect(observer)
	assert_true(_state.record(0, &"plot_tilled", 1).ok)
	assert_true(_state.advance_day(1).ok)
	assert_eq(calls[0], 2)
	var saved: Dictionary = _state.serialize()
	assert_true(_state.deserialize(saved))
	assert_false(_state.deserialize({}))
	assert_eq(calls[0], 2)
	assert_eq(_state.serialize(), saved)
	_state.activity_changed.disconnect(observer)
	assert_false(_state.is_busy())

func test_thousand_day_sliding_counts_native_restore_and_duplicate_rejections() -> void:
	assert_true(_state.configure(CONFIG, 0, true))
	var expected: Array[int] = []
	for day: int in range(1000):
		assert_true(_state.record(day, &"crop_harvested", day + 1).ok)
		expected.append(day + 1)
		if expected.size() > CONFIG.window_days:
			expected.pop_front()
		assert_true(_state.advance_day(day + 1).ok)
		var window: Dictionary = _state.get_window_snapshot()
		assert_eq(window.observed_days, expected.size())
		if window.available:
			var total: int = 0
			for quantity: int in expected:
				total += quantity
			assert_eq(window.totals.crop_harvested, total)
		else:
			assert_lt(expected.size(), CONFIG.window_days)
		var before: Dictionary = _state.serialize()
		assert_false(_state.advance_day(day + 1).ok)
		assert_eq(_state.serialize(), before)
		if day % 37 == 0:
			var decoded: Dictionary = DirectorActivityCodec.decode(CONFIG, JSON.parse_string(JSON.stringify(before, "", true, true)))
			assert_true(decoded.ok)
			assert_true(_state.deserialize(decoded.snapshot))
			assert_eq(_state.serialize(), before)
