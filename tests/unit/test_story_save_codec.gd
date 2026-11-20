extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func test_current_component_preserves_progress_and_read_pages_exactly() -> void:
	var story: Dictionary = {"completed_objectives":["first_sale"],"read_pages":["intro","page_sale"]}
	var payload: Dictionary = {"story":story,"wallet":{"coins":42}}
	var before: Dictionary = payload.duplicate(true)
	var result: Dictionary = StorySaveCodec.normalize(CONFIG,story,payload)
	assert_true(result.ok)
	assert_false(result.fallback)
	assert_eq(result.snapshot,story)
	assert_eq(payload,before)
	result.snapshot.read_pages.clear()
	assert_eq(payload,before)
func test_corrupt_or_legacy_story_uses_only_verified_flags_without_read_replay() -> void:
	var payload: Dictionary = {"wallet":{"coins":42},"dog":{"name":"Mây","cell_x":-4,"cell_y":2},"quests":{"completed":[false,true,false,false,true,true,false]},"social":{"quests":{"completed":["turnip_delivery"]}},"land_ownership":{"owned_parcels":["farm_east_1"]}}
	var before: Dictionary = payload.duplicate(true)
	for raw: Variant in [null,[],{}, {"completed_objectives":["m2_4_station"],"read_pages":[]}, {"completed_objectives":[],"read_pages":["page_sale"]}]:
		var result: Dictionary = StorySaveCodec.normalize(CONFIG,raw,payload)
		assert_true(result.ok)
		assert_true(result.fallback)
		assert_eq(result.snapshot.completed_objectives,["first_sowing","first_harvest","first_sale","first_delivery","first_expansion"])
		assert_eq(result.snapshot.read_pages,[])
		assert_eq(payload,before)
	var forged: Dictionary = {"completed_objectives":[],"read_pages":["intro"]}
	assert_eq(StorySaveCodec.normalize(CONFIG,forged,payload,true).snapshot.read_pages,[])
	assert_false(StorySaveCodec.normalize(null,{},payload).ok)
func test_all_fifteen_tracked_goldens_are_immutable_legacy_inputs() -> void:
	for version: int in range(1,16):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var hash_before: String = FileAccess.get_sha256(path)
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var before: Dictionary = raw.duplicate(true)
		var result: Dictionary = StorySaveCodec.normalize(CONFIG,{"completed_objectives":[],"read_pages":["intro"]},raw,true)
		assert_true(result.ok,"v%d" % version)
		assert_true(StorySnapshotCodec.decode(CONFIG,result.snapshot).ok)
		assert_eq(result.snapshot.read_pages,[])
		for id: String in result.snapshot.completed_objectives: assert_true(CONFIG.supported_ids().has(id))
		assert_eq(raw,before)
		assert_eq(FileAccess.get_sha256(path),hash_before)
