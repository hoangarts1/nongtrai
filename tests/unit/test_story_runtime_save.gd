extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_current16_exact_story_other_owners_and_stable_owner_across_slot_continue() -> void:
	f.play()
	f.use(&"hoe",Vector2i(1,1))
	f.use(&"seed",Vector2i(1,1))
	f.main.dog_state.try_set_name("Mây")
	assert_true(f.main.story_state.acknowledge_page(&"intro").ok)
	var owner: StoryState = f.main.story_state
	var before: Dictionary = f.owners()
	assert_true(f.main.call("_save_game_to_slot",98))
	assert_eq(int(SaveService.load_game(98).meta.save_version),16)
	assert_eq(SaveService.load_game(98).story,before.story)
	assert_true(f.main.call("_load_game_from_slot",98))
	assert_eq(f.owners(),before)
	assert_eq(f.main.story_state,owner)
	assert_true(f.main.call("_return_to_start_menu"))
	f.main.call("_continue_game")
	assert_eq(f.owners(),before)
	assert_eq(f.main.story_state,owner)
func test_corrupt_story_fallback_preserves_other_owners_and_does_not_replay_read_flags() -> void:
	f.play()
	f.use(&"hoe",Vector2i(1,1))
	f.use(&"seed",Vector2i(1,1))
	f.main.story_state.acknowledge_page(&"intro")
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	var before: Dictionary = f.core_owners()
	payload.story = {"completed_objectives":["m2_4_station"],"read_pages":["intro"]}
	assert_true(f.main.call("_load_payload",payload))
	assert_eq(f.core_owners(),before)
	assert_eq(f.main.story_state.serialize(),{"completed_objectives":["first_sowing"],"read_pages":[]})
	assert_false(f.main.story_state.is_complete())
func test_all15goldens_migrate_without_injected_story_and_golden16_is_actual_migration() -> void:
	for version: int in range(1,16):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var hash_before: String = FileAccess.get_sha256(path)
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var original: Dictionary = raw.duplicate(true)
		raw.story = {"completed_objectives":[],"read_pages":["intro"]}
		var migrated: Dictionary = SaveService._migrate(raw,version)
		assert_eq(int(migrated.meta.save_version),16)
		assert_eq(migrated.story.read_pages,[])
		assert_eq(migrated.clock,original.clock)
		if original.has("wallet"): assert_eq(migrated.wallet,original.wallet)
		assert_eq(FileAccess.get_sha256(path),hash_before)
	var raw15: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v15.json"))
	var expected: Dictionary = JSON.parse_string(JSON.stringify(SaveService._migrate(raw15,15),"",true,true))
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v16.json"))
	assert_eq(golden,expected)
