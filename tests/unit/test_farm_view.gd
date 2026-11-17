extends GutTest

func test_supplied_crop_visuals_use_manifest_pivots_and_wilted_stage_assets() -> void:
	var crop: Sprite2D = Sprite2D.new()
	add_child_autofree(crop)
	CropPresentation.render(crop,&"spring_carrot",0.0,Color.WHITE,false,false,Vector2i.ZERO)
	assert_true(crop.get_meta("visual_asset","").ends_with("carrot_stage1.png"))
	assert_eq(crop.get_meta("visual_stage"),1)
	assert_eq(crop.offset,Vector2(0,-36))
	CropPresentation.render(crop,&"spring_carrot",1.0,Color.WHITE,true,false,Vector2i.ZERO)
	assert_true(crop.get_meta("visual_asset","").ends_with("carrot_stage4_wilted.png"))
	assert_eq(crop.get_meta("visual_stage"),4)

func test_manifest_covers_all_supplied_crop_visual_sets_and_registered_crop_data() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/crops/crops_manifest.json"))
	assert_eq((manifest.get("crops", {}) as Dictionary).size(),16)
	for crop_name: String in (manifest.get("crops", {}) as Dictionary).keys():
		var crop: CropData = DataRegistry.get_crop(StringName(crop_name)) as CropData
		assert_not_null(crop)
		assert_not_null(DataRegistry.get_item(crop.seed_item))
		assert_not_null(DataRegistry.get_item(crop.product_item))
		for stage: int in range(1,5):
			assert_true(FileAccess.file_exists("res://assets/crops/%s/%s_stage%d.png" % [crop_name,crop_name,stage]))
			assert_true(FileAccess.file_exists("res://assets/crops/%s/%s_stage%d_wilted.png" % [crop_name,crop_name,stage]))
		assert_true(FileAccess.file_exists("res://assets/crops/%s/%s_seed.png" % [crop_name,crop_name]))

func test_farm_view_builds_visible_cells_and_updates_crop_visual() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var farm_view: Node2D = main.get_node("GrayBoxWorld/WorldCanvas/FarmView")
	var cell_view: Polygon2D = farm_view.call("get_cell_view", Vector2i(0, 0)) as Polygon2D
	var crop_view: Sprite2D = farm_view.call("get_crop_view", Vector2i(0, 0)) as Sprite2D
	assert_not_null(cell_view)
	assert_true(cell_view.visible)
	assert_eq(cell_view.polygon.size(), 4)
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
	var farm_view: FarmView = main.get_node("GrayBoxWorld/WorldCanvas/FarmView") as FarmView
	var cell: Vector2i = Vector2i(0, 0)
	assert_true(main.farm_state.till_cell(cell))
	assert_true(main.farm_state.plant_crop(cell, &"turnip"))
	await get_tree().process_frame
	var label: Label = farm_view.get_crop_label(cell)
	assert_not_null(label)
	assert_false(label.visible, "Tiny world text is replaced by click inspection")
	var required: int = (DataRegistry.get_crop(&"turnip") as CropData).growth_days
	assert_true(label.text.contains(tr("CROP_STATUS_REMAINING") % required))
	assert_true(label.text.contains(tr("CROP_STATUS_NEEDS_WATER")))
	assert_true(main.farm_state.water_cell(cell))
	await get_tree().process_frame
	assert_false(label.text.contains(tr("CROP_STATUS_NEEDS_WATER")))
	main.farm_state.advance_day()
	assert_true(label.text.contains(tr("CROP_STATUS_REMAINING") % (required-1)))
	for day: int in range(1,required):
		assert_true(main.farm_state.water_cell(cell))
		main.farm_state.advance_day()
	assert_eq(label.text, tr("CROP_STATUS_READY"))
	assert_false(label.visible)
	assert_true(main.farm_state.harvest_cell(cell).get("success", false))
	assert_false(label.visible)
	main.queue_free()
