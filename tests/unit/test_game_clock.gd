extends GutTest

func before_each() -> void:
	GameClock.paused = true
	GameClock.day_index = 0
	GameClock.minute = GameClock.MORNING_MINUTE
	GameClock.day_real_seconds = GameClock.DEFAULT_DAY_REAL_SECONDS
	GameClock.time_speed = 1.0
	GameClock._sleeping = false

func test_sleep_starts_next_day_at_six() -> void:
	GameClock.minute = 1200
	GameClock.sleep_to_morning()
	assert_eq(GameClock.day_index, 1)
	assert_eq(GameClock.minute, 360)
	assert_eq(GameClock.get_hour(), 6)
	assert_eq(GameClock.get_minute_in_hour(), 0)

func test_advance_real_seconds_converts_to_game_minutes() -> void:
	GameClock.advance_real_seconds(60.0)
	assert_eq(GameClock.minute, 480)

func test_clock_serializes_and_deserializes() -> void:
	GameClock.day_index = 4
	GameClock.minute = 825
	var saved: Dictionary = GameClock.serialize()
	GameClock.day_index = 0
	GameClock.minute = 360
	GameClock.deserialize(saved)
	assert_eq(GameClock.day_index, 4)
	assert_eq(GameClock.minute, 825)

func test_sleep_is_allowed_from_twenty_until_two() -> void:
	GameClock.minute = 1199
	assert_false(GameClock.can_sleep())
	GameClock.minute = 1200
	assert_true(GameClock.can_sleep())
	GameClock.minute = 1439
	assert_true(GameClock.can_sleep())
	GameClock.minute = 1560
	assert_false(GameClock.can_sleep())

func test_clock_display_wraps_hours_after_midnight() -> void:
	assert_eq(GameClock.format_time(1440), "00:00")
	assert_eq(GameClock.format_time(1558), "01:58")
	assert_eq(GameClock.format_time(1799), "05:59")

func test_try_sleep_does_not_advance_during_day() -> void:
	GameClock.minute = 720
	assert_false(GameClock.try_sleep())
	assert_eq(GameClock.day_index, 0)
	assert_eq(GameClock.minute, 720)

func test_try_sleep_starts_sleep_at_night_without_changing_day() -> void:
	GameClock.minute = 1200
	GameClock.set_speed(5.0)
	assert_true(GameClock.try_sleep())
	assert_true(GameClock.is_sleeping())
	assert_eq(GameClock.day_index, 0)
	assert_eq(GameClock.minute, 1200)
	assert_eq(GameClock.time_speed, 20.0)

func test_sleep_finishes_once_at_six_and_restores_speed() -> void:
	GameClock.minute = 1200
	GameClock.set_speed(5.0)
	assert_true(GameClock.try_sleep())
	GameClock.advance_minutes(600)
	assert_false(GameClock.is_sleeping())
	assert_eq(GameClock.day_index, 1)
	assert_eq(GameClock.minute, GameClock.MORNING_MINUTE)
	assert_eq(GameClock.time_speed, 5.0)
	GameClock.advance_minutes(1)
	assert_eq(GameClock.day_index, 1)

func test_sleep_at_2330_crosses_midnight_and_finishes_at_six() -> void:
	GameClock.set_time(23, 30)
	GameClock.try_sleep()
	GameClock.advance_minutes(30)
	assert_true(GameClock.is_sleeping())
	assert_eq(GameClock.format_time(GameClock.minute), "00:00")
	GameClock.advance_minutes(120)
	assert_true(GameClock.is_sleeping())
	assert_eq(GameClock.format_time(GameClock.minute), "02:00")
	GameClock.advance_minutes(240)
	assert_false(GameClock.is_sleeping())
	assert_eq(GameClock.day_index, 1)
	assert_eq(GameClock.minute, GameClock.MORNING_MINUTE)
	assert_eq(GameClock.format_time(GameClock.minute), "06:00")

func test_debug_time_and_speed_changes_are_ignored_while_sleeping() -> void:
	GameClock.minute = 1200
	GameClock.set_speed(5.0)
	GameClock.try_sleep()
	GameClock.set_time(12, 0)
	GameClock.set_speed(1.0)
	assert_eq(GameClock.minute, 1200)
	assert_eq(GameClock.time_speed, 20.0)

func test_set_time_changes_clock_to_requested_hour() -> void:
	GameClock.set_time(23, 30)
	assert_eq(GameClock.get_hour(), 23)
	assert_eq(GameClock.get_minute_in_hour(), 30)

func test_set_time_clamps_before_morning() -> void:
	GameClock.set_time(2, 0)
	assert_eq(GameClock.minute, GameClock.MORNING_MINUTE)

func test_time_speed_changes_real_time_rate() -> void:
	GameClock.set_time(6, 0)
	GameClock.paused = false
	GameClock.set_speed(5.0)
	GameClock._process(12.0)
	assert_eq(GameClock.minute, 480)
	GameClock.set_speed(1.0)
