extends GutTest

const FARM_STATE_SCRIPT: Script = preload("res://scripts/domain/farm_grid_state.gd")

func test_turnip_grows_after_watering_and_harvests() -> void:
	var farm: FarmGridState = FARM_STATE_SCRIPT.new()
	var cell: Vector2i = Vector2i(2, 3)

	assert_true(farm.till_cell(cell))
	assert_true(farm.plant_crop(cell, &"turnip"))
	assert_false(farm.can_harvest(cell))
	assert_true(farm.water_cell(cell))

	farm.advance_day()
	assert_false(farm.can_harvest(cell))
	assert_true(farm.water_cell(cell))

	farm.advance_day()
	assert_true(farm.can_harvest(cell))

	var result: Dictionary = farm.harvest_cell(cell)
	assert_true(result.get("success", false))
	assert_eq(result.get("crop_id"), &"turnip")
	assert_eq(int(result.get("quantity", 0)), 2)
	assert_false(farm.can_harvest(cell))

func test_crop_repairs_after_missing_water() -> void:
	var farm: FarmGridState = FARM_STATE_SCRIPT.new()
	var cell: Vector2i = Vector2i(4, 5)

	assert_true(farm.till_cell(cell))
	assert_true(farm.plant_crop(cell, &"turnip"))
	farm.advance_day()
	assert_false(farm.can_harvest(cell))
	assert_true(farm.water_cell(cell))
	farm.advance_day()
	assert_false(farm.can_harvest(cell))
	assert_true(farm.water_cell(cell))
	farm.advance_day()
	assert_true(farm.can_harvest(cell))
