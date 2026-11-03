extends GutTest

var _season: StringName

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"summer"

func after_each() -> void:
	GameClock.season = _season

func _plant(id: StringName = &"summer_tomato") -> FarmGridState:
	var farm: FarmGridState = FarmGridState.new()
	assert_true(farm.till_cell(Vector2i.ZERO))
	assert_true(farm.plant_crop(Vector2i.ZERO,id))
	return farm

func _care(farm: FarmGridState, days: int) -> void:
	for day: int in range(days):
		farm.water_cell(Vector2i.ZERO)
		DaySimulator.new().simulate_day(farm)

func test_tomato_first_five_days_then_repeat_two_days_never_reharvests_early() -> void:
	var farm: FarmGridState = _plant()
	assert_eq(farm.get_growth_target(Vector2i.ZERO),5)
	_care(farm,4)
	assert_false(farm.can_harvest(Vector2i.ZERO))
	assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])
	_care(farm,1)
	for cycle: int in range(3):
		assert_true(farm.can_harvest(Vector2i.ZERO))
		var harvest: Dictionary = farm.harvest_cell(Vector2i.ZERO)
		assert_eq(harvest["quantity"],2)
		assert_eq(harvest["product_item"],&"summer_tomato")
		var plot: Dictionary = farm.get_plot(Vector2i.ZERO)
		assert_eq(plot["crop_id"],&"summer_tomato")
		assert_true(plot["regrowing"])
		assert_eq(plot["growth_target"],2)
		assert_eq(plot["growth_days"],0)
		assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])
		_care(farm,1)
		assert_false(farm.can_harvest(Vector2i.ZERO))
		assert_eq(farm.get_growth_remaining(Vector2i.ZERO),1)
		_care(farm,1)

func test_harvest_retains_care_state_and_does_not_save_a_dry_repeat_crop() -> void:
	var farm: FarmGridState = _plant()
	_care(farm,5)
	farm.advance_day()
	assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],1)
	assert_true(farm.harvest_cell(Vector2i.ZERO)["success"])
	assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],1)
	assert_false(farm.get_plot(Vector2i.ZERO)["watered"])
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	assert_false(farm.water_cell(Vector2i.ZERO))
	assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])
	var snapshot: Dictionary = farm.serialize()
	farm.advance_day()
	assert_eq(farm.serialize(),snapshot)

func test_repeat_preserves_prior_watering_and_season_wither_is_terminal() -> void:
	var farm: FarmGridState = _plant()
	_care(farm,5)
	assert_true(farm.water_cell(Vector2i.ZERO))
	assert_true(farm.harvest_cell(Vector2i.ZERO)["success"])
	assert_true(farm.get_plot(Vector2i.ZERO)["watered"])
	farm.advance_day()
	assert_eq(farm.get_growth_remaining(Vector2i.ZERO),1)
	assert_false(farm.get_plot(Vector2i.ZERO)["watered"])
	GameClock.season = &"autumn"
	farm.mark_out_of_season()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	farm.water_all_crops()
	assert_false(farm.can_harvest(Vector2i.ZERO))
	assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])

func test_single_harvest_still_removes_plant_and_targets_are_frozen_at_sowing() -> void:
	var farm: FarmGridState = _plant(&"turnip")
	assert_eq(farm.get_growth_target(Vector2i.ZERO),4)
	_care(farm,3)
	assert_false(farm.can_harvest(Vector2i.ZERO))
	_care(farm,1)
	assert_true(farm.harvest_cell(Vector2i.ZERO)["success"])
	assert_true(farm.get_plot(Vector2i.ZERO).is_empty())
	assert_eq(farm.get_growth_target(Vector2i.ZERO),0)

func test_twenty_eight_watered_days_give_twelve_picks_from_one_seed() -> void:
	var farm: FarmGridState = _plant()
	var picks: Array[int] = []
	var products: int = 0
	for day: int in range(1,29):
		_care(farm,1)
		if farm.can_harvest(Vector2i.ZERO):
			picks.append(day)
			products += int(farm.harvest_cell(Vector2i.ZERO)["quantity"])
	assert_eq(picks,[5,7,9,11,13,15,17,19,21,23,25,27])
	assert_eq(products,24)
	var seed: ItemData = DataRegistry.get_item(&"summer_tomato_seed") as ItemData
	var product: ItemData = DataRegistry.get_item(&"summer_tomato") as ItemData
	assert_eq(products*product.sell_price-seed.buy_price,1693)
