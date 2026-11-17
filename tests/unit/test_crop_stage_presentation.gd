extends GutTest

func test_all_sixteen_normal_and_wilted_stages_follow_the_manifest_and_quarters() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/crops/crops_manifest.json"))
	for id: String in manifest.crops:
		var entry: Dictionary = manifest.crops[id]
		var sprite: Sprite2D = Sprite2D.new()
		add_child_autofree(sprite)
		for index: int in range(5):
			var progress: float = float(index) / 4.0
			var stage: int = mini(index + 1, 4)
			for wilted: bool in [false, true]:
				CropPresentation.render(sprite, StringName(id), progress, Color.WHITE, wilted, false, Vector2i.ZERO)
				var expected: String = "%s_stage%d%s.png" % [id, stage, "_wilted" if wilted else ""]
				assert_true(String(sprite.get_meta("visual_asset")).ends_with(expected))
				assert_eq(sprite.get_meta("visual_stage"), stage)
				assert_eq(sprite.get_meta("mature"), index == 4 and not wilted)
				assert_eq(sprite.offset, Vector2(0, float(entry.canvas[1]) * 0.5 - float(entry.pivot[1])))
				assert_not_null(sprite.texture)

func test_seven_repeating_crop_ids_keep_normal_or_wilted_mature_plant_art_after_picking() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	add_child_autofree(sprite)
	for id: StringName in [&"coffee", &"pepper", &"orange", &"apple", &"banana", &"tomato", &"summer_tomato"]:
		for progress: float in [0.0, 0.25, 0.5, 0.75, 0.999, 1.0]:
			for wilted: bool in [false, true]:
				CropPresentation.render(sprite, id, progress, Color.WHITE, wilted, false, Vector2i.ZERO, true)
				var stage: int = 4 if progress >= 1.0 else 3
				assert_eq(sprite.get_meta("visual_stage"), stage)
				assert_true(String(sprite.get_meta("visual_asset")).ends_with("_stage%d%s.png" % [stage, "_wilted" if wilted else ""]))
				assert_eq(sprite.get_meta("mature"), progress >= 1.0 and not wilted)

func test_last_quarter_and_near_one_never_publish_early_maturity() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	add_child_autofree(sprite)
	for progress: float in [0.75, 0.9, 0.999, 0.99999]:
		CropPresentation.render(sprite, &"tomato", progress, Color.WHITE, false, false, Vector2i.ZERO)
		assert_eq(sprite.get_meta("visual_stage"), 4)
		assert_eq(CropPresentation.get_stage_id(progress), &"3")
		assert_false(sprite.get_meta("mature"))
	CropPresentation.render(sprite, &"tomato", 1.0, Color.WHITE, false, false, Vector2i.ZERO)
	assert_true(sprite.get_meta("mature"))
	CropPresentation.render(sprite, &"tomato", 1.0, Color.WHITE, true, false, Vector2i.ZERO)
	assert_false(sprite.get_meta("mature"))
	assert_eq(CropPresentation.get_stage_id(1.0, true), &"withered")
