extends GutTest

const LINEUP_SCENE: PackedScene = preload("res://tools/chibi_world_lineup.tscn")

func test_c3_lineup_covers_world_assets_for_four_season_day_night_review() -> void:
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	add_child_autofree(lineup)
	await get_tree().process_frame
	assert_eq(String(lineup.get("last_error")), "")
	var group_ids: PackedStringArray = lineup.call("get_review_group_ids") as PackedStringArray
	assert_eq(group_ids.size(), 5)
	assert_true(group_ids.has("buildings"))
	assert_true(group_ids.has("trees_boundary"))
	assert_true(group_ids.has("terrain_water"))
	assert_true(group_ids.has("village_props"))
	assert_true(group_ids.has("critters"))
	lineup.call("set_focus_group", &"buildings")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 5)
	lineup.call("set_focus_group", &"village_props")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 8)
	lineup.call("set_focus_group", &"critters")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 3)
	lineup.call("set_review_view", 3, true, &"winter")
	assert_eq(String(lineup.get("last_error")), "")
