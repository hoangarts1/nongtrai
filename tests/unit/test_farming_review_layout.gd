extends GutTest

const LINEUP_SCENE: PackedScene = preload("res://tools/farming_art_lineup.tscn")
const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")

func test_c2_lineup_groups_all_farming_assets_for_four_angle_review() -> void:
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	add_child_autofree(lineup)
	await get_tree().process_frame
	assert_eq(String(lineup.get("last_error")), "")
	var group_ids: PackedStringArray = lineup.call("get_review_group_ids") as PackedStringArray
	assert_eq(group_ids.size(), 14)
	assert_true(group_ids.has("lineup"))
	assert_true(group_ids.has("crop_summer_tomato"))
	assert_true(group_ids.has("items_2"))
	assert_true(group_ids.has("tools"))
	lineup.call("set_focus_group", &"crop_summer_tomato")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 5, "A crop group shows four stages plus wilt")
	assert_eq((lineup.get_node("ModelLabels") as Node).get_child_count(), 0, "Focused review leaves silhouettes unobscured")
	lineup.call("set_focus_group", &"items_1")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 6, "Item groups cover all eighteen assets in readable sets")
	lineup.call("set_focus_group", &"tools")
	assert_eq((lineup.get_node("GeneratedModels") as Node).get_child_count(), 4)
	lineup.call("set_review_view", 3, true)
	assert_eq(REVIEW_LAYOUT.sheet_size(384), Vector2i(1536, 768))
	assert_eq(REVIEW_LAYOUT.tile_origin(3, true, 384), Vector2i(1152, 384))
