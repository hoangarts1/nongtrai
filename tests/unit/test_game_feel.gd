extends GutTest

func test_audio_service_ignores_missing_optional_file() -> void:
	var audio: Node = preload("res://scripts/core/audio_service.gd").new()
	get_tree().root.add_child(audio)
	audio.call("play_sound", &"missing_placeholder_sound")
	assert_eq(audio.get_child_count(), 0)
	audio.queue_free()

func test_crop_visual_has_distinct_mature_stage() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var farm: FarmGridState = main.farm_state
	farm.till_cell(Vector2i(0,0))
	farm.plant_crop(Vector2i(0,0), &"turnip")
	var crop: Sprite2D = main.farm_view.get_crop_view(Vector2i.ZERO)
	assert_not_null(crop.texture)
	var sprout: PackedByteArray = crop.texture.get_image().get_data()
	assert_eq(crop.get_meta("stage_id"), &"0")
	for _day: int in range(2):
		assert_true(farm.water_cell(Vector2i.ZERO))
		farm.advance_day()
	assert_true(crop.visible)
	assert_eq(crop.get_meta("stage_id"), &"3")
	assert_true(bool(crop.get_meta("mature")))
	assert_ne(crop.texture.get_image().get_data(),sprout)
	assert_eq(crop.global_position,main.world.cell_to_global(Vector2i.ZERO))
