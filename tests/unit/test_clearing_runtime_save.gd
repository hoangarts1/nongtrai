extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/clearing_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_current17_slot_continue_newgame_keep_one_owner_and_never_regrow_cleared_art() -> void:
	var owner: ClearingState = f.main.clearing_state
	for cell: Vector2i in f.TARGETS: assert_true(f.clear_at(cell).ok)
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_eq(int(payload.meta.save_version),17)
	var before: Dictionary = f.owners()
	assert_eq(payload.clearing,before.clearing)
	assert_true(f.main.call("_load_game_from_slot",98))
	assert_eq(f.owners(),before)
	assert_eq(f.main.clearing_state,owner)
	for cell: Vector2i in f.TARGETS: assert_null(f.debris(cell))
	assert_true(f.main.call("_return_to_start_menu"))
	f.main.call("_continue_game")
	assert_eq(f.owners(),before)
	for cell: Vector2i in f.TARGETS: assert_null(f.debris(cell))
	f.main.call("_start_new_game","Mai","Garden")
	assert_eq(f.main.clearing_state,owner)
	assert_eq(f.main.clearing_state.serialize(),ClearingSaveCodec.empty())
	assert_false(f.main.story_state.serialize().completed_objectives.has("clear_land"))
	for cell: Vector2i in f.TARGETS: assert_not_null(f.debris(cell))

func test_all16_historical_goldens_cannot_import_injected_cleanup_and_new17_is_actual_migration() -> void:
	for cell: Vector2i in f.TARGETS: assert_true(f.clear_at(cell).ok)
	var injected: Dictionary = f.main.clearing_state.serialize()
	for version: int in range(1,17):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var hash_before: String = FileAccess.get_sha256(path)
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		raw.clearing = injected
		raw.story = {"completed_objectives":["clear_land"],"read_pages":["intro"]}
		var migrated: Dictionary = SaveService._migrate(raw,version)
		assert_eq(int(migrated.meta.save_version),17)
		assert_eq(migrated.clearing,ClearingSaveCodec.empty())
		assert_false(migrated.story.completed_objectives.has("clear_land"))
		assert_eq(FileAccess.get_sha256(path),hash_before)
	var original16: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v16.json"))
	var expected: Dictionary = JSON.parse_string(JSON.stringify(SaveService._migrate(original16,16),"",true,true))
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v17.json"))
	assert_eq(int(golden.meta.save_version),17)
	assert_eq(golden,expected)
	assert_true(f.main.call("_load_payload",golden))
	assert_eq(f.main.clearing_state.serialize(),ClearingSaveCodec.empty())

func test_corrupt_component_only_falls_back_without_rewards_or_other_owner_mutation() -> void:
	for cell: Vector2i in f.TARGETS: assert_true(f.clear_at(cell).ok)
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	var before: Dictionary = f.owners()
	payload.clearing = {"cleared":[{"x":0,"y":0,"asset_id":"tree_fruit"}]}
	assert_true(f.main.call("_load_payload",payload))
	var after: Dictionary = f.owners()
	after.erase("clearing")
	before.erase("clearing")
	assert_eq(after,before)
	assert_eq(f.main.clearing_state.serialize(),ClearingSaveCodec.empty())
	for cell: Vector2i in f.TARGETS: assert_not_null(f.debris(cell))

func test_invalid_cleanup_cannot_trap_restored_player_or_fabricate_progress() -> void:
	var cell: Vector2i = Vector2i(3,-4)
	assert_true(f.clear_at(cell).ok)
	f.main.world.player.move_to_cell(cell)
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	payload.clearing = null
	assert_true(f.main.call("_load_payload",payload))
	assert_eq(f.main.world.get_player_cell(),cell,"No actor teleport during component fallback")
	assert_eq(f.main.clearing_state.get_count(),0)
	assert_null(f.debris(cell),"Original blocking art waits until the restored Player leaves")
	f.main.world.player.move_to_cell(cell+Vector2i.DOWN)
	f.main.clearing_runtime.call("_process",0.0)
	assert_not_null(f.debris(cell))
	assert_eq(f.main.clearing_state.get_count(),0)
	assert_false(f.main.story_state.serialize().completed_objectives.has("clear_land"))
