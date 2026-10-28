extends GutTest

const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")
const LINEUP_SCENE: PackedScene = preload("res://tools/character_lineup.tscn")

func test_character_lineup_loads_six_stable_generated_models() -> void:
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	add_child_autofree(lineup)
	await get_tree().process_frame
	assert_eq(String(lineup.get("last_error")), "")
	var expected: PackedStringArray = PackedStringArray(["player", "an", "lam", "linh", "minh", "dog"])
	assert_eq(lineup.call("get_review_model_names") as PackedStringArray, expected)
	for model_id: StringName in expected:
		assert_true(ResourceLoader.exists(String(lineup.call("get_model_path", model_id))), "Generated scene exists: %s" % model_id)
		assert_not_null(lineup.get_node_or_null(String(model_id).capitalize()))
	assert_not_null(lineup.get_node_or_null("OneMeterGrid"))
	assert_not_null(lineup.get_node_or_null("ReviewCamera"))

func test_character_lineup_focus_and_review_layout_are_stable() -> void:
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	add_child_autofree(lineup)
	await get_tree().process_frame
	assert_eq(String(lineup.get("last_error")), "")
	lineup.call("set_focus_model", &"minh")
	assert_true((lineup.get_node("Minh") as Node3D).visible)
	assert_false((lineup.get_node("Player") as Node3D).visible)
	lineup.call("set_review_view", 3, true)
	var environment: Environment = (lineup.get_node("WorldEnvironment") as WorldEnvironment).environment
	assert_eq(environment.background_color, Color("34415d"))
	lineup.call("set_focus_model", &"")
	assert_true((lineup.get_node("Player") as Node3D).visible)
	var tile_size: int = 512
	assert_eq(REVIEW_LAYOUT.sheet_size(tile_size), Vector2i(2048, 1024))
	assert_eq(REVIEW_LAYOUT.tile_origin(0, false, tile_size), Vector2i.ZERO)
	assert_eq(REVIEW_LAYOUT.tile_origin(3, true, tile_size), Vector2i(1536, 512))
