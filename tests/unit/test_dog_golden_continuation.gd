extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_actual_golden15_and_historical14_continue_preserve_progress_and_reset_routes() -> void:
	for version: int in [14,15]:
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		var payload: Dictionary = SaveService._migrate(raw,version)
		assert_true(f.main.call("_load_payload",payload))
		var owners: Dictionary = f.owners()
		var dog: Dictionary = f.main.dog_state.serialize()
		assert_true(f.main.call("_save_game_to_slot",98))
		assert_true(f.main.call("_load_game_from_slot",98))
		assert_eq(f.owners(),owners)
		assert_eq(f.main.dog_state.serialize(),dog)
		assert_eq(f.actors().size(),1)
		assert_false(f.main.dog_runtime.actor.is_moving())
