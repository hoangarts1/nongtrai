extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_native_json_and_catalogue_order_preserve_only_actual_supported_progress() -> void:
	var raw: Dictionary = {"completed_objectives":["first_sale","first_sowing"],"read_pages":["page_sale","intro"]}
	var result: Dictionary = StorySnapshotCodec.decode(CONFIG,JSON.parse_string(JSON.stringify(raw)))
	assert_true(result.ok)
	assert_eq(result.snapshot.completed_objectives,["first_sowing","first_sale"])
	assert_eq(result.snapshot.read_pages,["intro","page_sale"])
	assert_eq(StorySnapshotCodec.decode(CONFIG,result.snapshot).snapshot,result.snapshot)
	assert_eq(result.snapshot.size(),2)
func test_malformed_types_unknown_keys_duplicates_and_planned_unlocks_are_rejected() -> void:
	for raw: Variant in [null,[],{}, {"completed_objectives":[],"read_pages":[],"station":true}, {"completed_objectives":true,"read_pages":[]}, {"completed_objectives":[true],"read_pages":[]}, {"completed_objectives":[1.0],"read_pages":[]}, {"completed_objectives":[&"first_sowing"],"read_pages":[]}, {"completed_objectives":["first_sowing","first_sowing"],"read_pages":[]}, {"completed_objectives":["repair_house"],"read_pages":[]}, {"completed_objectives":["m2_4_station"],"read_pages":[]}, {"completed_objectives":[],"read_pages":["missing"]}, {"completed_objectives":[],"read_pages":["intro","intro"]}, {"completed_objectives":[],"read_pages":["page_sale"]}]:
		assert_false(StorySnapshotCodec.decode(CONFIG,raw).ok,str(raw))
func test_prerequisites_and_invalid_data_reject_atomically() -> void:
	var config: StoryConfig = CONFIG.frozen_copy()
	config.pages[1].requires_pages = PackedStringArray(["intro"])
	var raw: Dictionary = {"completed_objectives":["first_sowing"],"read_pages":["page_sowing"]}
	var original: Dictionary = raw.duplicate(true)
	assert_false(StorySnapshotCodec.decode(config,raw).ok)
	assert_eq(raw,original)
	raw.read_pages.append("intro")
	assert_true(StorySnapshotCodec.decode(config,raw).ok)
	config.objectives[0].requires = PackedStringArray(["first_harvest"])
	assert_false(StorySnapshotCodec.decode(config,raw).ok)
	assert_false(StorySnapshotCodec.decode(null,raw).ok)
func test_empty_and_decoded_values_are_detached() -> void:
	var raw: Dictionary = StorySnapshotCodec.empty()
	assert_true(StorySnapshotCodec.decode(CONFIG,raw).ok)
	var decoded: Dictionary = StorySnapshotCodec.decode(CONFIG,raw).snapshot
	decoded.completed_objectives.append("first_sowing")
	assert_eq(raw,StorySnapshotCodec.empty())
	assert_true(CONFIG.supported_ids().has("first_sowing"))
