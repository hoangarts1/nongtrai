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

func test_crop_label_shows_growth_water_and_ready_states() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var farm_view: FarmView = main.get_node("GrayBoxWorld/FarmView") as FarmView
	var cell: Vector2i = Vector2i(0, 0)
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell, &"turnip"))
	await get_tree().process_frame
	var label: Label3D = farm_view.get_crop_label(cell)
	assert_not_null(label)
	assert_false(label.visible, "Tiny world text is replaced by click inspection")
	assert_true(label.text.contains("Còn 2 ngày"))
	assert_true(label.text.contains("Cần tưới"))
	assert_true(main.farm_state.water_cell(cell))
	await get_tree().process_frame
	assert_false(label.text.contains("Cần tưới"))
	main.farm_state.advance_day()
	assert_true(label.text.contains("Còn 1 ngày"))
	assert_true(main.farm_state.water_cell(cell))
	main.farm_state.advance_day()
	assert_eq(label.text, "Chín! Thu hoạch được")
	assert_false(label.visible)
	assert_true(main.farm_state.harvest_cell(cell).get("success", false))
	assert_false(label.visible)
	main.queue_free()
