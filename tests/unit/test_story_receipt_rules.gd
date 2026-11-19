extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_committed_actual_tool_sale_sources_map_only_supported_first_occurrences() -> void:
	assert_eq(StoryReceiptRules.from_command(CONFIG,&"tool",{"crop_planted":1,"crop_harvested":2},true).objective_ids,PackedStringArray(["first_sowing","first_harvest"]))
	for source: StringName in [&"shipping_bin",&"minh"]:
		assert_eq(StoryReceiptRules.from_command(CONFIG,source,{"item_sold":3},true).objective_ids,PackedStringArray(["first_sale"]))
	assert_eq(StoryReceiptRules.from_command(CONFIG,&"seed_shop",{"item_purchased":1},true).objective_ids,PackedStringArray())
	assert_eq(StoryReceiptRules.from_command(CONFIG,&"tool",{},true).objective_ids,PackedStringArray())
func test_unproven_failed_wrong_source_and_invalid_counts_are_rejected() -> void:
	assert_false(StoryReceiptRules.from_command(CONFIG,&"tool",{"crop_planted":1},false).ok)
	assert_false(StoryReceiptRules.from_command(CONFIG,&"missing",{"crop_planted":1},true).ok)
	assert_false(StoryReceiptRules.from_command(CONFIG,&"tool",{"item_sold":1},true).ok)
	assert_false(StoryReceiptRules.from_command(CONFIG,&"tool",{"m2_4_station":1},true).ok)
	for quantity: Variant in [-1,0,true,1.0,"1"]:
		assert_false(StoryReceiptRules.from_command(CONFIG,&"tool",{"crop_planted":quantity},true).ok)
func test_delivery_requires_committed_registered_completion_and_parcel_requires_prefix() -> void:
	var quests: Dictionary = {"completed":["turnip_delivery"]}
	assert_false(StoryReceiptRules.delivery(CONFIG,&"turnip_delivery",quests,false).ok)
	assert_false(StoryReceiptRules.delivery(CONFIG,&"turnip_delivery",{"active":["turnip_delivery"]},true).ok)
	assert_false(StoryReceiptRules.delivery(CONFIG,&"missing",quests,true).ok)
	assert_eq(StoryReceiptRules.delivery(CONFIG,&"turnip_delivery",quests,true).objective_ids,PackedStringArray(["first_delivery"]))
	var land: Dictionary = {"owned_parcels":["farm_east_1"]}
	assert_false(StoryReceiptRules.parcel(CONFIG,&"farm_east_1",land,false).ok)
	assert_false(StoryReceiptRules.parcel(CONFIG,&"missing",land,true).ok)
	assert_false(StoryReceiptRules.parcel(CONFIG,&"farm_east_1",{"owned_parcels":["missing"]},true).ok)
	assert_eq(StoryReceiptRules.parcel(CONFIG,&"farm_east_1",land,true).objective_ids,PackedStringArray(["first_expansion"]))
func test_projection_is_detached_and_never_mutates_counts_or_game_owners() -> void:
	var counts: Dictionary = {"crop_planted":1}
	var result: Dictionary = StoryReceiptRules.from_command(CONFIG,&"tool",counts,true)
	result.objective_ids.append("m2_4_station")
	assert_eq(counts,{"crop_planted":1})
	assert_eq(StoryReceiptRules.from_command(CONFIG,&"tool",counts,true).objective_ids,PackedStringArray(["first_sowing"]))
	assert_true(StoryCatalogValidator.validate(CONFIG).is_empty())
