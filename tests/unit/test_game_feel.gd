extends GutTest

func test_audio_service_ignores_missing_optional_file() -> void:
	var audio: Node = preload("res://scripts/core/audio_service.gd").new()
	get_tree().root.add_child(audio)
	audio.call("play_sound", &"missing_placeholder_sound")
	assert_eq(audio.get_child_count(), 0)
	audio.queue_free()

func test_crop_visual_has_distinct_mature_stage() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var farm: FarmGridState = main.farm_state
	var view: FarmView = main.farm_view
	farm.till_cell(Vector2i(0, 0))
	farm.plant_crop(Vector2i(0, 0), &"turnip")
	var crop: MeshInstance3D = view.get_crop_view(Vector2i(0, 0))
	assert_true(crop.mesh is BoxMesh, "C2 keeps a stable invisible click bound under generated art")
	assert_eq(crop.get_meta("stage_id"), &"0")
	assert_not_null(crop.get_node_or_null("CropVisual/Leaf_0"), "Young crop loads its generated sprout stage")
	for _day: int in range(2):
		assert_true(farm.water_cell(Vector2i(0, 0)))
		farm.advance_day()
	assert_true(crop.visible)
	assert_eq(crop.get_meta("stage_id"), &"3")
	assert_not_null(crop.get_node_or_null("CropVisual/RootBody"), "Mature root has a generated harvest body")
	assert_not_null(crop.get_node_or_null("CropVisual/MatureSparkles"), "Mature crops add only view-local sparkle")
	main.queue_free()
