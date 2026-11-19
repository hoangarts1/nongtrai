extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/story_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_story_publication_blocks_main_lifecycle_and_next_command_reentry() -> void:
	f.play()
	var attempts: Array[bool] = []
	var callback: Callable = func() -> void:
		attempts.append(f.main.call("_save_game_to_slot",98))
		attempts.append(f.main.call("_load_payload",{}))
		attempts.append(f.main.call("_return_to_start_menu"))
		attempts.append(f.main.director_activity_collector.begin_command(&"tool").ok)
		f.main.call("_start_new_game","Wrong","Wrong")
	f.main.story_state.changed.connect(callback)
	f.use(&"hoe",Vector2i(1,1))
	f.use(&"seed",Vector2i(1,1))
	f.main.story_state.changed.disconnect(callback)
	assert_eq(attempts,[false,false,false,false])
	assert_eq(f.main.profile.player_name,"Mai")
	assert_eq(f.main.story_state.serialize().completed_objectives,["first_sowing"])
func test_new_load_title_reuse_one_collector_and_story_owner_without_old_receipt_replay() -> void:
	var owner: StoryState = f.main.story_state
	var collector: LifeDirectorActivityCollector = f.main.director_activity_collector
	for _iteration: int in range(3):
		f.main.call("_start_new_game","Mai","Garden")
		f.main.tutorial_panel.close_help()
		f.main.ui_coordinator.close_active()
		assert_eq(f.main.story_state,owner)
		assert_eq(f.main.director_activity_collector,collector)
		assert_eq(f.main.story_state.serialize(),StorySnapshotCodec.empty())
		assert_true(f.main.call("_save_game_to_slot",98))
		assert_true(f.main.call("_load_game_from_slot",98))
		assert_eq(f.main.story_state,owner)
		var count: int = 0
		for child: Node in f.main.get_children():
			if child is LifeDirectorActivityCollector: count += 1
		assert_eq(count,1)
	assert_eq(f.actors().size(),1)
func test_inactive_backend_receipt_does_not_fabricate_live_story() -> void:
	assert_true(f.main.call("_return_to_start_menu"))
	var receipt: Dictionary = f.main.director_activity_collector.begin_command(&"tool")
	assert_true(receipt.ok)
	assert_false(f.main.director_activity_collector.finish_command(receipt.token,{"crop_planted":1}))
	assert_eq(f.main.story_state.serialize(),StorySnapshotCodec.empty())
