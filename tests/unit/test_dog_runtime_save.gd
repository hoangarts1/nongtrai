extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame
func test_current_save_exact_dog_continue_and_new_without_other_progress_loss() -> void:
	f.main.dog_state.try_set_name("Mây")
	f.main.dog_state.try_set_cell(Vector2i(-12,-10))
	f.main.dog_runtime.actor.reset_position()
	var before: Dictionary = f.owners()
	var dog: Dictionary = f.main.dog_state.serialize()
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_eq(payload.meta.save_version,18)
	assert_eq(payload.dog,dog)
	assert_true(f.main.call("_load_payload",payload))
	assert_eq(f.main.dog_state.serialize(),dog)
	assert_eq(f.owners(),before)
	assert_eq(f.actors().size(),1)
	assert_true(f.main.call("_return_to_start_menu"))
	f.main.call("_continue_game")
	assert_eq(f.main.dog_state.serialize(),dog)
	f.main.call("_start_new_game","Mai","Garden")
	assert_eq(f.main.dog_state.get_name(),"")
func test_all_historical_goldens_and_bad_dog_only_fallback() -> void:
	for version: int in range(1,15):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		assert_true(FileAccess.file_exists(path))
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var migrated: Dictionary = SaveService._migrate(raw,version)
		assert_eq(migrated.meta.save_version,18)
		assert_eq(migrated.dog.name,"")
		assert_true(DogSnapshotCodec.decode(f.main.dog_runtime.CONFIG,migrated.dog).ok)
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	payload.dog = {"name":"Mây","cell_x":999,"cell_y":999}
	var before: Dictionary = f.owners()
	assert_true(f.main.call("_load_payload",payload))
	assert_eq(f.main.dog_state.get_name(),"Mây")
	assert_true(f.main.dog_runtime.navigation.is_walkable(f.main.dog_state.get_cell()))
	assert_eq(f.owners(),before)
