extends GutTest

func test_simulator_grows_only_watered_crops_and_drains_water() -> void:
	var farm: FarmGridState = preload("res://scripts/domain/farm_grid_state.gd").new()
	var simulator: Object = preload("res://scripts/domain/day_simulator.gd").new()
	var cell: Vector2i = Vector2i(0, 0)
	farm.till_cell(cell)
	farm.plant_crop(cell, &"turnip")
	farm.water_cell(cell)
	simulator.call("simulate_day", farm)
	assert_false(farm.can_harvest(cell))
	assert_false(bool(farm.get_plot(cell).get("watered", false)))
	farm.water_cell(cell)
	simulator.call("simulate_day", farm)
	assert_true(farm.can_harvest(cell))

func test_main_connects_day_started_to_day_simulator() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var cell: Vector2i = Vector2i(0, 0)
	main.farm_state.till_cell(cell)
	main.farm_state.plant_crop(cell, &"turnip")
	main.farm_state.water_cell(cell)
	GameClock.day_started.emit(GameClock.day_index + 1)
	assert_false(bool(main.farm_state.get_plot(cell).get("watered", false)))
	main.queue_free()
