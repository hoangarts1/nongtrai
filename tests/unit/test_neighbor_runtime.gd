extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/neighbor_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_only_two_real_nearby_native_conversations_complete_the_seventh_goal() -> void:
	f.near(&"an")
	var before: Dictionary = f.non_social_owners()
	assert_true(f.main.npc_system.state.get_introduced_ids().is_empty())
	f.main.npc_system.state.talk(&"bac_lam",GameClock.day_index,GameClock.season)
	f.main.npc_system.conversation_started.emit(&"bac_lam")
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	await f.key(self,KEY_E)
	assert_true(f.main.npc_system.dialogue.visible)
	assert_eq(f.main.npc_system.state.get_introduced_ids(),PackedStringArray(["an"]))
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	f.main.npc_system.close_panels()
	await f.converse(self,&"an")
	assert_eq(int(f.main.npc_system.state.friendship.an),2)
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	f.main.npc_system.close_panels()
	await f.converse(self,&"bac_lam")
	assert_true(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	assert_false(f.main.story_state.is_complete())
	assert_eq(f.main.npc_system.state.get_introduced_ids(),PackedStringArray(["an","bac_lam"]))
	assert_eq(f.non_social_owners(),before)

func test_hidden_far_indoors_modal_and_unproven_notices_never_add_a_marker() -> void:
	f.play()
	var before: Dictionary = f.owners()
	f.main.npc_system.open_dialogue(&"an")
	f.main.npc_system.conversation_started.emit(&"an")
	assert_eq(f.owners(),before)
	f.near(&"bac_lam")
	var before_modal: Dictionary = f.owners()
	f.main.pause_menu.open()
	f.main.npc_system.open_dialogue(&"bac_lam")
	assert_eq(f.owners(),before_modal)
	f.main.ui_coordinator.close_active()
	f.main.world.player.move_to_cell(Vector2i(15,15))
	f.main.npc_system.open_dialogue(&"bac_lam")
	assert_true(f.main.npc_system.state.get_introduced_ids().is_empty())
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))

func test_conversation_publication_blocks_root_lifecycle_and_duplicate_commands() -> void:
	f.near(&"an")
	var attempts: Array[bool] = []
	var observer: Callable = func(_id: StringName) -> void:
		attempts.append(f.main.call("_save_game_to_slot",98))
		attempts.append(f.main.call("_load_payload",{}))
		attempts.append(f.main.call("_return_to_start_menu"))
		f.main.call("_start_new_game","Wrong","Wrong")
		f.main.npc_system.close_panels()
		attempts.append(f.main.npc_system.dialogue.visible)
		f.main.npc_system.open_dialogue(&"bac_lam")
	f.main.npc_system.conversation_started.connect(observer)
	await f.key(self,KEY_E)
	f.main.npc_system.conversation_started.disconnect(observer)
	assert_eq(attempts,[false,false,false,true])
	assert_eq(f.main.profile.player_name,"Mai")
	assert_eq(f.main.npc_system.state.get_introduced_ids(),PackedStringArray(["an"]))
	assert_false(f.main.call("_purchase_in_progress"))
	assert_eq(f.main.npc_system.workplaces.size(),2)
	assert_eq(f.main.npc_system.actors.size(),4)
