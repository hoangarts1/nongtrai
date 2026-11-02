extends GutTest

const MAIN: PackedScene = preload("res://scenes/main/main.tscn")
const CONFIG: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
var _clock: Dictionary
var _paused: bool
var _viewport: SubViewport

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(_viewport)

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused

func _game() -> Node:
	var main: Node = MAIN.instantiate()
	_viewport.add_child(main)
	main.world.player.movement_enabled = false
	return main

func test_active_tree_is_2d_with_shared_isometric_grid_and_sort_origins() -> void:
	var main: Node = _game()
	await get_tree().process_frame
	assert_eq(_count_3d(main),0,"Archived 3D art cannot enter active gameplay")
	assert_true(main.world.player is CharacterBody2D)
	assert_eq(main.world.camera.get_parent(),main.world.player)
	assert_eq(main.world.ground.tile_set.tile_size,Vector2i(64,32))
	assert_eq(main.world.ground.tile_set.tile_shape,TileSet.TILE_SHAPE_ISOMETRIC)
	assert_eq(main.world.ground.tile_set.tile_layout,TileSet.TILE_LAYOUT_DIAMOND_DOWN)
	assert_eq(main.world.farmland.tile_set,main.world.ground.tile_set)
	assert_true(main.world.objects.y_sort_enabled)
	assert_true(main.world.ground.y_sort_enabled)
	assert_true(main.world.farmland.y_sort_enabled)
	for index: int in range(1,9):
		assert_false(String(ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % index,"")).is_empty())
	# Engine defaults still expose 3D settings; the project must remove its override.
	assert_false(FileAccess.get_file_as_string("res://project.godot").contains("3d/physics_engine="))

func test_negative_cell_round_trips_survive_camera_zoom_pan_and_layer_transform() -> void:
	var main: Node = _game()
	var cells: Array[Vector2i] = [Vector2i(-7,-3),Vector2i(-1,0),Vector2i.ZERO,Vector2i(5,5),Vector2i(11,10)]
	main.world.camera_rig.set_process(false)
	for zoom: float in [0.85,1.0,1.25]:
		main.world.camera.zoom = Vector2.ONE * zoom
		main.world.camera.global_position = Vector2(41,-27)
		main.world.ground.position = Vector2(17,9)
		main.world.ground.scale = Vector2(1.2,1.2)
		main.world.camera.force_update_scroll()
		await get_tree().process_frame
		for cell: Vector2i in cells:
			var global_point: Vector2 = main.world.grid.cell_to_global(cell)
			var screen_point: Vector2 = main.world.grid.cell_to_screen(cell)
			assert_eq(main.world.grid.global_to_cell(global_point),cell)
			assert_eq(main.world.pick_cell(screen_point),cell)
			var event: InputEventMouseMotion = InputEventMouseMotion.new()
			event.position = screen_point
			_viewport.push_input(event,true)
			assert_eq(main.world.grid.mouse_cell(),cell)

func test_ui_stays_fixed_while_camera_moves_the_world() -> void:
	var main: Node = _game()
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.inventory_panel.toggle_inventory()
	# Wait for the existing 0.16 s panel-open bounce before measuring camera isolation.
	await get_tree().create_timer(0.25).timeout
	var ui_transform: Transform2D = main.inventory_panel.get_global_transform_with_canvas()
	var initial_cell_screen: Vector2 = main.world.grid.cell_to_screen(Vector2i.ZERO)
	main.world.camera_rig.set_process(false)
	main.world.camera.global_position += Vector2(100,50)
	main.world.camera.zoom = Vector2(1.25,1.25)
	main.world.camera.force_update_scroll()
	await get_tree().process_frame
	assert_eq(main.inventory_panel.get_global_transform_with_canvas(),ui_transform)
	assert_ne(main.world.grid.cell_to_screen(Vector2i.ZERO),initial_cell_screen)
	assert_true(main.inventory_panel.visible)

func test_player_swept_collision_cannot_cross_a_house_footprint() -> void:
	var main: Node = _game()
	main.world.player.move_to_cell(Vector2i(10,7))
	await get_tree().physics_frame
	var destination: Vector2 = main.world.cell_to_global(Vector2i(10,10))
	var collision: KinematicCollision2D = main.world.player.move_and_collide(destination-main.world.player.global_position)
	assert_not_null(collision,"2D building blockers stop even a large physics motion")
	assert_gt(main.world.player.global_position.distance_to(destination),8.0)
	assert_true(main.world.player.get_collision_layer_value(2))
	assert_true(main.world.player.get_collision_mask_value(1))

func test_old_v4_positions_load_to_cells_and_resave_without_pixels_or_schema_change() -> void:
	var main: Node = _game()
	var payload: Dictionary = {
		"player":{"position":{"x":-2.25,"y":0.0,"z":4.75}},
		"inventory":{"capacity":12,"slots":[]},
		"wallet":{"coins":137},
		"profile":{"player_name":"Mai","farm_name":"Mùa"}
	}
	main.call("_load_payload",payload)
	assert_eq(main.world.get_player_cell(),Vector2i(-3,4))
	assert_eq(main.wallet.get_coins(),137)
	await get_tree().process_frame
	var encoded: Dictionary = main.call("_legacy_player_position")
	assert_eq(encoded,{"x":-2.5,"y":0.0,"z":4.5})
	main.call("_load_payload",{"player":{"position":encoded},"wallet":{"coins":137}})
	assert_eq(main.world.get_player_cell(),Vector2i(-3,4))
	assert_eq(main.call("_legacy_player_position"),encoded)
	assert_eq(main.wallet.get_coins(),137)
	main.call("_load_payload", {"player":{"position":{"x":"invalid","z":NAN}}})
	assert_eq(main.world.get_player_cell(), CONFIG.spawn_cell, "Malformed position values use data-owned spawn defaults")
	main.call("_load_payload", {"player":{"position":{"x":9999,"z":-9999}}})
	assert_eq(main.world.get_player_cell(), Vector2i(CONFIG.player_region.end.x - 1, CONFIG.player_region.position.y), "Legacy position is clamped to playable cells")
	await get_tree().process_frame

func test_movement_is_screen_relative_and_diagonal_has_no_uncompressed_speed_bonus() -> void:
	for direction: Vector2 in [Vector2.RIGHT,Vector2.DOWN,Vector2.ONE,Vector2(-1,1),Vector2(-1,-1),Vector2(1,-1)]:
		var motion: Vector2 = Player.screen_direction(direction)
		assert_almost_eq(Vector2(motion.x,motion.y*2).length(),1.0,0.00001)
	assert_eq(Player.screen_direction(Vector2.ZERO),Vector2.ZERO)
	assert_gt(main_speed(true),main_speed(false))

func main_speed(sprint: bool) -> float:
	var config: PlayerConfig = preload("res://data/player_2d_config.tres")
	return config.sprint_speed if sprint else config.walk_speed

func test_isometric_config_gate_rejects_invalid_tiles_zoom_and_locations() -> void:
	var invalid: IsometricWorldConfig = CONFIG.duplicate() as IsometricWorldConfig
	invalid.tile_size = Vector2i(0,32)
	invalid.zoom_levels = PackedFloat32Array([0])
	invalid.spawn_cell = Vector2i(999,999)
	assert_false(DataValidator.validate_isometric_world_config(invalid).is_empty())
	assert_true(DataValidator.validate_isometric_world_config(CONFIG).is_empty())

func _count_3d(root: Node) -> int:
	var count: int = 1 if root is Node3D else 0
	for child: Node in root.get_children():
		count += _count_3d(child)
	return count
