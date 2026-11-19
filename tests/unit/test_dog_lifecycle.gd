extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_reset_new_load_title_reuses_owner_actor() -> void:
	var owner: DogState = f.main.dog_state
	var actor: DogActor2D = f.main.dog_runtime.actor
	assert_true(owner.try_set_name("Milo").ok)
	assert_true(f.main.call("_save_game_to_slot", 98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_true(f.main.call("_load_payload", payload))
	assert_eq(f.main.dog_state, owner)
	assert_eq(f.main.dog_runtime.actor, actor)
	f.main.call("_start_new_game", "Mai", "Garden")
	assert_eq(f.actors().size(), 1)
	assert_eq(f.main.dog_state, owner)
	assert_true(f.main.dog_runtime.navigation.is_walkable(owner.get_cell()))
func test_owner_publication_blocks_new_load_save_title_callback_reentry() -> void:
	var results: Array[bool] = []
	var callback: Callable = func(_cell: Vector2i, _name: String) -> void:
		results.append(f.main.call("_save_game_to_slot",98))
		results.append(f.main.call("_load_payload",{}))
		results.append(f.main.call("_return_to_start_menu"))
		f.main.call("_start_new_game","Wrong","Wrong")
	f.main.dog_state.changed.connect(callback)
	assert_true(f.main.dog_state.try_set_name("Milo").ok)
	f.main.dog_state.changed.disconnect(callback)
	assert_eq(results, [false,false,false])
	assert_eq(f.main.profile.player_name, "Mai")
	assert_eq(f.main.dog_state.get_name(), "Milo")
