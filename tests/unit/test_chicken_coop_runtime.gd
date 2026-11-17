extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main

func after_each() -> void:
	await get_tree().process_frame
	f.cleanup()

func test_actual_buy_feed_day_collect_and_full_bag_buffer() -> void:
	f.open()
	var flow: ChickenCoopFlow = main.chicken_coop_flow
	flow.command(&"buy_coop",4)
	flow.command(&"buy_feed",4)
	flow.command(&"feed",2)
	assert_eq(main.wallet.get_coins(),220)
	assert_eq(main.inventory.get_quantity(&"chicken_feed"),2)
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),0)
	assert_eq(int(main.chicken_coop.coop.serialize().fed_hens),2)
	flow.close()
	GameClock.set_time(21,0)
	assert_true(main.day_end_flow.request())
	main.day_end_flow.confirm()
	assert_eq(GameClock.day_index,1)
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),2)
	assert_eq(int(main.chicken_coop.coop.serialize().fed_hens),0)
	main.morning_flow.dismiss()
	main.ui_coordinator.close_active()
	main.world.player.move_to_cell(main.chicken_coop_runtime.CONFIG.entrance)
	main.chicken_coop_flow.open()
	main.inventory.deserialize({"capacity":1,"slots":[{"item_id":"egg","quantity":99}]})
	flow.command(&"collect",2)
	assert_eq(flow.result.reason,&"inventory_full")
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),2)
	main.inventory.clear()
	flow.command(&"collect",2)
	assert_eq(main.inventory.get_quantity(&"egg"),2)
	flow.command(&"collect",2)
	assert_eq(main.inventory.get_quantity(&"egg"),2)

func test_remote_and_hidden_commands_cannot_spend_or_grant() -> void:
	f.open()
	main.world.player.move_to_cell(Vector2i.ZERO)
	var before: Dictionary = f.owners()
	main.chicken_coop_flow.command(&"buy_coop",4)
	assert_eq(f.owners(),before)
	main.chicken_coop_flow.close()
	assert_false(main.chicken_coop_runtime.execute(&"buy_coop",4).ok)
	assert_eq(f.owners(),before)

func test_owned_collision_and_dynamic_same_target_route_preserve_npc_state() -> void:
	f.open()
	var runtime: ChickenCoopRuntime = main.chicken_coop_runtime
	assert_null(runtime.site.body)
	# A previously valid route may contain the soon-to-be blocked site; target identity stays fixed.
	main.npc_system.state.targets[&"linh"] = &"linh_home"
	main.npc_system.state.paths[&"linh"] = [runtime.CONFIG.footprint.position]
	var social: Dictionary = main.npc_system.state.serialize()
	main.chicken_coop_flow.command(&"buy_coop",4)
	assert_not_null(runtime.site.body)
	assert_eq(runtime.site.body.collision_layer,1)
	assert_eq(main.npc_system.state.serialize(),social)
	assert_false(main.npc_system.state.paths[&"linh"].has(runtime.CONFIG.footprint.position))
	assert_eq(main.npc_system.state.targets[&"linh"],&"linh_home")
	var blocked: Vector2i = runtime.CONFIG.footprint.position
	assert_true(main.npc_system.state.scheduler.route(blocked,Vector2i(7,13)).is_empty())
	var route: Array[Vector2i] = main.npc_system.state.scheduler.route(Vector2i(9,14),Vector2i(12,14))
	assert_false(route.is_empty())
	for cell: Vector2i in route:
		assert_false(runtime.CONFIG.footprint.has_point(cell))
	var empty: Array[Rect2i] = []
	main.npc_system.set_dynamic_obstacles(empty)
	assert_false(main.npc_system.state.scheduler.route(blocked,Vector2i(7,13)).is_empty())

func test_duplicate_completed_day_does_not_advance_farm_or_machine() -> void:
	f.open()
	main.chicken_coop_flow.command(&"buy_coop",4)
	main.chicken_coop_flow.command(&"buy_feed",4)
	main.chicken_coop_flow.command(&"feed",4)
	main.chicken_coop_flow.close()
	GameClock.sleep_to_morning()
	var before: Dictionary = f.owners()
	main.day_simulator.simulate_day(main.farm_state,main.chicken_coop.coop,main.machine_operations,0)
	assert_eq(f.owners(),before)
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),4)
	GameClock.sleep_to_morning()
	assert_eq(int(main.chicken_coop.coop.serialize().pending_eggs),4,"Unfed day retains eggs and hens")

func test_live_site_occupancy_denies_without_erasing_any_actor_plot_or_machine() -> void:
	f.open()
	var cell: Vector2i = main.chicken_coop_runtime.CONFIG.footprint.position
	var npc_cell: Vector2i = main.npc_system.state.cells[&"linh"]
	for kind: String in ["player","npc","plot","machine"]:
		if kind=="player":
			main.world.player.move_to_cell(cell)
		elif kind=="npc":
			main.npc_system.state.cells[&"linh"] = cell
		elif kind=="plot":
			assert_true(main.farm_state.till_cell(cell))
		else:
			main.machine_inventory.add_machine(&"stove")
			assert_true(main.machine_placements.place(&"stove",cell,0).ok)
		var before: Dictionary = f.owners()
		var placements: Dictionary = main.machine_placements.serialize()
		main.chicken_coop_flow.command(&"buy_coop",4)
		assert_false(main.chicken_coop.is_owned(),kind)
		assert_eq(f.owners(),before,kind)
		assert_eq(main.machine_placements.serialize(),placements)
		main.world.player.move_to_cell(main.chicken_coop_runtime.CONFIG.entrance)
		main.npc_system.state.cells[&"linh"] = npc_cell
		if kind=="plot":
			main.farm_state.reset()
		if kind=="machine":
			main.machine_placements.remove(cell)
