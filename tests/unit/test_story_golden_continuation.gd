extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_all16tracked_goldens_continue_exactly_without_old_page_replay() -> void:
	var owner: StoryState = f.main.story_state
	var observer: LifeDirectorActivityCollector = f.main.director_activity_collector
	for version: int in range(1,17):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var hash_before: String = FileAccess.get_sha256(path)
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var migrated: Dictionary = SaveService._migrate(raw,version)
		assert_eq(int(migrated.meta.save_version),16)
		assert_true(f.main.call("_load_payload",migrated))
		f.main.morning_flow.reset()
		f.main.ui_coordinator.close_active()
		var owners: Dictionary = f.owners()
		assert_true(f.main.call("_save_game_to_slot",98))
		assert_true(f.main.call("_load_game_from_slot",98))
		assert_eq(f.owners(),owners)
		assert_eq(f.main.story_state,owner)
		assert_eq(f.main.director_activity_collector,observer)
		assert_false(f.main.story_moment_flow.panel.visible)
		assert_eq(f.actors().size(),1)
		assert_false(f.main.story_state.is_complete())
		if version<16: assert_eq(f.main.story_state.serialize().read_pages,[])
		assert_eq(FileAccess.get_sha256(path),hash_before)
