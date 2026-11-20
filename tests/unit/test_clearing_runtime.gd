extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/clearing_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_real_shovel_clears_three_once_and_only_then_records_the_sixth_story_source() -> void:
	var before: Dictionary = f.core_owners()
	for index: int in range(f.TARGETS.size()):
		var cell: Vector2i = f.TARGETS[index]
		assert_not_null(f.debris(cell))
		f.play()
		f.use(&"shovel",cell)
		assert_eq(f.main.clearing_state.get_count(),index+1)
		assert_null(f.debris(cell))
		assert_eq(f.main.story_state.serialize().completed_objectives.has("clear_land"),index+1>=f.main.clearing_state.get_goal())
		assert_false(f.main.clearing_runtime.clear(cell).ok)
	assert_eq(f.core_owners(),before,"No coins, items, growth, water, day, NPC/dog or machine mutation")
	assert_false(f.main.story_state.is_complete())
	assert_eq(f.main.story_state.serialize().completed_objectives,["clear_land"])
	assert_false(f.main.clearing_state.is_busy())
	assert_false(f.main.clearing_runtime.busy)

func test_wrong_tool_far_locked_occupied_modal_and_forged_notices_do_not_clear() -> void:
	f.play()
	var cell: Vector2i = f.TARGETS[0]
	var before: Dictionary = f.owners()
	f.main.tool_controller.select_tool(&"hoe")
	assert_false(f.main.clearing_runtime.clear(cell).ok)
	f.main.tool_controller.select_tool(&"shovel")
	f.main.world.player.move_to_cell(Vector2i(15,15))
	assert_false(f.main.clearing_runtime.clear(cell).ok)
	f.main.world.player.move_to_cell(cell)
	assert_false(f.main.clearing_runtime.clear(cell).ok)
	f.main.world.player.move_to_cell(cell+Vector2i.DOWN)
	f.main.pause_menu.open()
	assert_false(f.main.clearing_runtime.clear(cell).ok)
	f.main.ui_coordinator.close_active()
	# This DATA hash places no debris in the first parcel. An explicit negative
	# display fixture proves even a visible supplied sprite cannot grant clearing.
	var locked: Vector2i = ClearingRuntime.CONFIG.land.parcels[0].region.position
	var fixture: SuppliedSceneryView = SuppliedSceneryView.new()
	assert_true(fixture.configure(ClearingRuntime.CONFIG.scenery.get_entry(&"rock_small_1")))
	fixture.set_meta("cell",locked)
	f.main.presentation.get_world_art_root().add_child(fixture)
	fixture.global_position = f.main.world.cell_to_global(locked)
	f.main.world.player.move_to_cell(locked+Vector2i.DOWN)
	assert_false(f.main.clearing_runtime.clear(locked).ok)
	assert_eq(fixture.get_parent(),f.main.presentation.get_world_art_root())
	assert_false(f.main.clearing_runtime.clear(Vector2i.ZERO).ok)
	f.main.clearing_runtime.cleared.emit(cell,&"grass_clump_large_3",3)
	assert_eq(f.owners(),before)
	assert_not_null(f.debris(cell))

func test_root_and_domain_publication_reentry_cannot_persist_reset_or_repeat_the_action() -> void:
	f.play()
	var cell: Vector2i = f.TARGETS[0]
	f.main.world.player.move_to_cell(cell+Vector2i.DOWN)
	f.main.tool_controller.select_tool(&"shovel")
	var attempts: Array[bool] = []
	var before: Dictionary = f.owners()
	var observer: Callable = func() -> void:
		attempts.append(f.main.call("_save_game_to_slot",98))
		attempts.append(f.main.call("_load_payload",{}))
		attempts.append(f.main.call("_return_to_start_menu"))
		attempts.append(f.main.clearing_runtime.clear(cell).ok)
		attempts.append(f.main.clearing_state.deserialize(ClearingSaveCodec.empty()))
		f.main.call("_start_new_game","Wrong","Wrong")
	f.main.clearing_state.changed.connect(observer)
	assert_true(f.main.clearing_runtime.clear(cell).ok)
	f.main.clearing_state.changed.disconnect(observer)
	assert_eq(attempts,[false,false,false,false,false])
	attempts.clear()
	var completed: Callable = func(_cell: Vector2i, _id: StringName, _count: int) -> void: observer.call()
	f.main.clearing_runtime.cleared.connect(completed)
	assert_true(f.clear_at(f.TARGETS[1]).ok)
	f.main.clearing_runtime.cleared.disconnect(completed)
	assert_eq(attempts,[false,false,false,false,false])
	assert_eq(f.main.profile.player_name,"Mai")
	assert_eq(f.main.clearing_state.get_count(),2)
	assert_eq(f.main.wallet.serialize(),before.wallet)
	assert_eq(f.main.inventory.serialize(),before.bag)
	assert_false(f.main.call("_purchase_in_progress"))

func test_large_rock_body_detaches_immediately_and_unrelated_roots_remain() -> void:
	var cell: Vector2i = Vector2i(3,-4)
	var rock: Node2D = f.debris(cell)
	assert_not_null(rock)
	assert_true(rock.has_node("WorldStaticCollision"))
	var other: Node2D = f.debris(f.TARGETS[0])
	assert_true(f.clear_at(cell).ok)
	assert_false(is_instance_valid(rock),"No deferred live collider/node after command success")
	assert_null(f.debris(cell))
	assert_eq(f.debris(f.TARGETS[0]),other)
	assert_eq(f.main.clearing_state.get_count(),1)

func test_synchronous_main_teardown_reclaims_detached_scenery_without_waiting_a_frame() -> void:
	var other: RefCounted = FIXTURE.new()
	other.setup(self)
	var roots: Array[Node] = other.main.presentation.get_world_art_root().get_children()
	assert_gt(roots.size(),0)
	other.main.call("_start_new_game","Mai","Garden")
	for root: Variant in roots:
		assert_false(is_instance_valid(root),"Passive retired roots are already freed before Main teardown")
	other.cleanup()
	for root: Variant in roots: assert_false(is_instance_valid(root))
