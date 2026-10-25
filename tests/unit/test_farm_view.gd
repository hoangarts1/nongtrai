extends GutTest

func test_farm_view_builds_visible_cells_and_updates_crop_visual() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var farm_view: Node3D = main.get_node("GrayBoxWorld/FarmView")
	var cell_view: MeshInstance3D = farm_view.call("get_cell_view", Vector2i(0, 0)) as MeshInstance3D
	var crop_view: MeshInstance3D = farm_view.call("get_crop_view", Vector2i(0, 0)) as MeshInstance3D
	assert_not_null(cell_view)
	assert_true(cell_view.visible)
	assert_not_null(cell_view.mesh)
	assert_not_null(crop_view)
	assert_false(crop_view.visible)
	assert_true(main.farm_state.till_cell(Vector2i(0, 0)))
	assert_true(main.farm_state.plant_crop(Vector2i(0, 0), &"turnip"))
	await get_tree().process_frame
	assert_true(crop_view.visible)
	main.queue_free()
