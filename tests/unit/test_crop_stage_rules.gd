extends GutTest

var _season: StringName

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"spring"

func after_each() -> void:
	GameClock.season = _season

func test_config_contract_and_validator_reject_unsupported_images_and_repeat_stage() -> void:
	assert_true(DataValidator.validate_crop_stage_config(CropStageRules.CONFIG).is_empty())
	assert_false(DataValidator.validate_crop_stage_config(null).is_empty())
	var config: CropStageConfig = CropStageConfig.new()
	for count: int in [0, 3, 5]:
		config.stage_count = count
		assert_false(config.validation_errors().is_empty())
	config.stage_count = 4
	for repeat: int in [0, 4, 5]:
		config.repeat_stage = repeat
		assert_false(config.validation_errors().is_empty())
	config.repeat_stage = 3
	assert_true(config.validation_errors().is_empty())

func test_quarter_boundaries_and_invalid_visual_progress() -> void:
	var ratios: Array[float] = [-0.1, 0.0, 0.2499, 0.25, 0.4999, 0.5, 0.7499, 0.75, 0.999, 1.0, 1.1]
	var expected: Array[int] = [0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3]
	for index: int in range(ratios.size()):
		assert_eq(CropStageRules.ratio_stage_index(ratios[index]), expected[index])
	assert_eq(CropStageRules.ratio_stage_index(NAN), -1)
	assert_eq(CropStageRules.ratio_stage_index(INF), -1)
	assert_eq(CropStageRules.stage_index(-1, 5), -1)
	assert_eq(CropStageRules.stage_index(0, 0), -1)
	assert_false(CropStageRules.crosses_stage(-1, 1, 5))
	assert_false(CropStageRules.crosses_stage(3, 2, 5))

func test_integer_days_and_view_ratios_agree_for_short_and_indivisible_targets() -> void:
	var cases: Dictionary = {
		3: [0, 1, 2, 3], 4: [0, 1, 2, 3, 3], 5: [0, 0, 1, 2, 3, 3],
		7: [0, 0, 1, 1, 2, 2, 3, 3], 12: [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3]
	}
	for target: int in cases:
		var stages: Array = cases[target]
		for day: int in range(stages.size()):
			assert_eq(CropStageRules.stage_index(day, target), int(stages[day]))
			assert_eq(CropStageRules.ratio_stage_index(float(day) / target), int(stages[day]))
	# Validating a boundary must not overflow by multiplying a full-sized day.
	var largest: int = 9223372036854775807
	@warning_ignore("integer_division")
	var quarter: int = largest / 4
	assert_eq(CropStageRules.stage_index(quarter, largest), 0)
	assert_eq(CropStageRules.stage_index(quarter + 1, largest), 1)
	assert_eq(CropStageRules.stage_index(largest, largest), 3)

func test_repeat_stays_at_stage_three_until_maturity_and_maturity_remains_a_boundary() -> void:
	for target: int in [2, 3, 4, 7, 12]:
		for day: int in range(target):
			assert_eq(CropStageRules.stage_index(day, target, true), 2)
			assert_eq(CropStageRules.ratio_stage_index(float(day) / target, true), 2)
			if day + 1 < target:
				assert_false(CropStageRules.crosses_stage(day, day + 1, target, true))
		assert_eq(CropStageRules.stage_index(target, target, true), 3)
		assert_true(CropStageRules.crosses_stage(target - 1, target, target, true))
	assert_true(CropStageRules.crosses_stage(3, 4, 4), "Ripeness is a boundary even though fruit art was already visible")
	assert_false(CropStageRules.crosses_stage(4, 4, 4))

func test_five_day_care_withers_at_the_actual_quarter_without_advancing_the_plot() -> void:
	var farm: FarmGridState = _plant(&"tomato")
	for day: int in range(2):
		assert_true(farm.water_cell(Vector2i.ZERO))
		farm.advance_day()
	assert_eq(farm.get_plot(Vector2i.ZERO).growth_days, 2)
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO).withered)
	assert_eq(farm.get_plot(Vector2i.ZERO).growth_days, 2)
	assert_false(farm.can_harvest(Vector2i.ZERO))
	assert_true(farm.water_cell(Vector2i.ZERO))
	farm.advance_day()
	assert_eq(farm.get_plot(Vector2i.ZERO).growth_days, 3)
	assert_false(farm.get_plot(Vector2i.ZERO).withered)

func test_seed_grace_and_repeat_dry_limit_are_preserved() -> void:
	var farm: FarmGridState = _plant(&"turnip")
	farm.advance_day()
	assert_false(farm.get_plot(Vector2i.ZERO).withered)
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO).withered)
	farm = _plant(&"coffee")
	var data: CropData = DataRegistry.get_crop(&"coffee") as CropData
	for day: int in range(data.growth_days):
		farm.water_all_crops()
		farm.advance_day()
	assert_true(farm.harvest_cell(Vector2i.ZERO).success)
	farm.advance_day()
	assert_false(farm.get_plot(Vector2i.ZERO).withered)
	assert_eq(farm.get_plot(Vector2i.ZERO).growth_days, 0)
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO).withered)
	assert_eq(CropStageRules.stage_index(0, data.regrow_days, true), 2)

func _plant(id: StringName) -> FarmGridState:
	var crop: CropData = DataRegistry.get_crop(id) as CropData
	GameClock.season = StringName(crop.seasons[0])
	var farm: FarmGridState = FarmGridState.new()
	assert_true(farm.till_cell(Vector2i.ZERO))
	assert_true(farm.plant_crop(Vector2i.ZERO, id))
	return farm
