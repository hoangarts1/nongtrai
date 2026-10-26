extends GutTest

func test_calendar_rolls_every_28_days_and_emits_season() -> void:
	GameClock.day_index = 27
	GameClock.season = &"spring"
	GameClock.sleep_to_morning()
	assert_eq(GameClock.day_index, 28)
	assert_eq(GameClock.season, &"summer")
	assert_eq(GameClock.get_day_in_season(), 1)
	GameClock.day_index = 0
	GameClock.season = &"spring"

func test_out_of_season_planting_is_refused_and_crop_can_wither() -> void:
	GameClock.season = &"winter"
	var farm: FarmGridState = preload("res://scripts/domain/farm_grid_state.gd").new()
	assert_eq((DataRegistry.get_crop(&"turnip").get("seasons") as PackedStringArray).size(), 3)
	assert_true(farm.till_cell(Vector2i(0, 0)))
	assert_false(farm.plant_crop(Vector2i(0, 0), &"turnip"), "season=%s" % GameClock.season)
	GameClock.season = &"spring"
	assert_true(farm.plant_crop(Vector2i(0, 0), &"turnip"), "season=%s" % GameClock.season)
	GameClock.season = &"winter"
	farm.mark_out_of_season()
	assert_true(bool(farm.get_plot(Vector2i(0, 0)).get("withered", false)))
	assert_true(farm.clear_withered(Vector2i(0, 0)))
	GameClock.season = &"spring"
