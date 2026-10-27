extends GutTest

var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({"day_index": 0, "minute": 720, "season": "spring", "year": 1})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(_viewport)

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func test_dragging_seeds_waters_and_harvests_each_crossed_cell_once() -> void:
	var main: Node = _game()
	await _settle()
	var cells: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2)]
	main.inventory.clear()
	assert_eq(main.inventory.add_item(&"turnip_seed", 2), 2)
	for cell: Vector2i in cells:
		assert_true(main.farm_state.till_cell(cell))
	main.tool_controller.select_seed()
	await _drag(main, [cells[0], cells[1], cells[0]])
	assert_eq(main.inventory.get_quantity(&"turnip_seed"), 0, "One seed is consumed for each planted cell, not every mouse motion")
	for cell: Vector2i in cells:
		assert_eq(main.farm_state.get_plot(cell).get("crop_id"), &"turnip")

	main.tool_controller.select_tool(&"watering_can")
	await _drag(main, [cells[0], cells[1], cells[0]])
	for cell: Vector2i in cells:
		assert_true(bool(main.farm_state.get_plot(cell).get("watered", false)), "Water drag uses the existing one-water-per-day rule")
	main.day_simulator.simulate_day(main.farm_state)
	for cell: Vector2i in cells:
		assert_true(main.farm_state.water_cell(cell))
	main.day_simulator.simulate_day(main.farm_state)

	main.tool_controller.select_tool(&"harvest")
	await _drag(main, [cells[0], cells[1], cells[0]])
	assert_eq(main.inventory.get_quantity(&"turnip"), 4, "Two mature plants each add their data-defined two-item yield")
	for cell: Vector2i in cells:
		assert_false(main.farm_state.can_harvest(cell))
	assert_false(main.crop_inspector.visible, "Harvest mode acts directly rather than opening the inspector")

func _game() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.world.player.position = GridMath.cell_to_world(Vector2i(2, 2))
	return main

func _drag(main: Node, cells: Array[Vector2i]) -> void:
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.position = _point(main, cells[0])
	press.button_index = MOUSE_BUTTON_LEFT
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	press.pressed = true
	_viewport.push_input(press, true)
	await get_tree().process_frame
	for index: int in range(1, cells.size()):
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = _point(main, cells[index])
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		_viewport.push_input(motion, true)
		await get_tree().process_frame
	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.position = _point(main, cells[cells.size() - 1])
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	_viewport.push_input(release, true)
	await _settle()

func _point(main: Node, cell: Vector2i) -> Vector2:
	return main.world.camera.unproject_position(GridMath.cell_to_world(cell) + Vector3(0.0, 0.06, 0.0))

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
