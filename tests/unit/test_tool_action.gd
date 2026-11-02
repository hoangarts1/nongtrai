extends GutTest

func test_tool_action_tills_waters_and_seeds_only_in_reach() -> void:
	var farm: FarmGridState = preload("res://scripts/domain/farm_grid_state.gd").new()
	var cell: Vector2i = Vector2i(1, 0)
	assert_true(ToolAction.is_in_reach(Vector2i.ZERO, cell, 1))
	assert_false(ToolAction.is_in_reach(Vector2i.ZERO, Vector2i(3, 0), 1))
	assert_true(ToolAction.apply(&"hoe", farm, cell, &""))
	assert_true(ToolAction.apply(&"seed", farm, cell, &"turnip"))
	assert_true(ToolAction.apply(&"water", farm, cell, &""))

func test_target_highlight_is_visible_and_uses_reach_state() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var farm_view: Node = main.get_node("GrayBoxWorld/WorldCanvas/FarmView")
	farm_view.call("set_hovered_cell", Vector2i(1, 0), true, true)
	assert_true(bool(farm_view.call("is_target_highlight_visible")))
	assert_true(bool(farm_view.call("is_target_in_reach")))
	farm_view.call("set_hovered_cell", Vector2i(4, 0), true, false)
	assert_true(bool(farm_view.call("is_target_highlight_visible")))
	assert_false(bool(farm_view.call("is_target_in_reach")))
	main.queue_free()
