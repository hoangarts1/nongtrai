extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/dog_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_live_follow_reaches_real_player_without_affecting_other_owners() -> void:
	var runtime: LifeDogRuntime = f.main.dog_runtime
	assert_eq(f.actors().size(), 1)
	assert_true(runtime.navigation.is_walkable(f.main.dog_state.get_cell()))
	f.main.world.player.move_to_cell(Vector2i(-12,-10))
	var owners: Dictionary = f.owners()
	f.play()
	owners.clock = GameClock.serialize()
	for _i: int in range(180):
		f.ticks(1)
		if DogFollowRules.distance(f.main.dog_state.get_cell(),f.main.world.player.get_cell())<=runtime.CONFIG.follow_stop_distance: break
	assert_lte(DogFollowRules.distance(f.main.dog_state.get_cell(),f.main.world.player.get_cell()), runtime.CONFIG.follow_stop_distance)
	assert_eq(f.owners(), owners)
	assert_eq(runtime.actor.global_position, f.main.world.grid.cell_to_global(f.main.dog_state.get_cell()))
	var count: int = runtime.navigation.get_rebuild_count()
	f.ticks(100)
	assert_eq(runtime.navigation.get_rebuild_count(), count)
func test_modal_pause_sleep_and_title_freeze_pose_and_cell() -> void:
	f.play()
	f.main.world.player.move_to_cell(Vector2i(-12,-10))
	f.ticks(1)
	var actor: DogActor2D = f.main.dog_runtime.actor
	var before: Dictionary = f.main.dog_state.serialize()
	var point: Vector2 = actor.global_position
	var phase: float = actor.avatar.get_phase()
	f.main.debug_menu.show()
	f.ticks(30)
	assert_eq(f.main.dog_state.serialize(), before)
	assert_eq(actor.global_position, point)
	assert_eq(actor.avatar.get_phase(), phase)
	f.main.ui_coordinator.close_active()
	GameClock.paused = true
	f.ticks(30)
	assert_eq(actor.global_position, point)
	assert_true(f.main.call("_return_to_start_menu"))
	assert_false(actor.visible)
	f.ticks(30)
	assert_false(actor.visible)
