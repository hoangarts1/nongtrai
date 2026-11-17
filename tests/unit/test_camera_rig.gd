extends GutTest

var _viewport: SubViewport
var _world: GrayBoxWorld

func before_each() -> void:
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	add_child(_viewport)
	_world = preload("res://scenes/world/gray_box_world.tscn").instantiate() as GrayBoxWorld
	_viewport.add_child(_world)

func after_each() -> void:
	_viewport.free()

func test_camera_follows_restored_player_with_data_bounds_and_offset() -> void:
	assert_eq(_world.camera,_world.player.camera)
	assert_eq(_world.camera.get_parent(),_world.player)
	_world.player.position = Vector2(40,24)
	_world.camera_rig.call("_process",1.0)
	var expected: Vector2 = _world.player.global_position.clamp(_world.CONFIG.camera_center_min,_world.CONFIG.camera_center_max)+_world.CONFIG.camera_offset
	assert_lt(_world.camera.global_position.distance_to(expected),1.0)
	_world.player.position = Vector2(10000,10000)
	# Expanded bounds require a second follow interval with unchanged speed/tolerance.
	for _step: int in range(2):
		_world.camera_rig.call("_process",1.0)
	assert_lt(_world.camera.global_position.distance_to(_world.CONFIG.camera_center_max+_world.CONFIG.camera_offset),1.0)

func test_zoom_uses_documented_actions_and_stops_when_player_is_locked() -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = &"camera_zoom_in"
	event.pressed = true
	_world.player.movement_enabled = true
	_world.camera_rig.call("_unhandled_input",event)
	assert_eq(_world.camera.zoom,Vector2.ONE*_world.CONFIG.zoom_levels[mini(_world.CONFIG.zoom_index+1,_world.CONFIG.zoom_levels.size()-1)])
	var before: Vector2 = _world.camera.zoom
	_world.player.movement_enabled = false
	event.action = &"camera_zoom_out"
	_world.camera_rig.call("_unhandled_input",event)
	assert_eq(_world.camera.zoom,before,"An overlay/sleep movement lock also blocks zoom")

func test_mouse_wheel_zooms_in_and_out_and_rmb_drag_pans_map() -> void:
	_world.player.movement_enabled = true
	var wheel_out: InputEventMouseButton = InputEventMouseButton.new()
	wheel_out.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel_out.pressed = true
	_world.camera_rig.call("_unhandled_input",wheel_out)
	assert_eq(_world.camera.zoom,Vector2.ONE*_world.CONFIG.zoom_levels[maxi(_world.CONFIG.zoom_index-1,0)])
	var wheel_in: InputEventMouseButton = InputEventMouseButton.new()
	wheel_in.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel_in.pressed = true
	_world.camera_rig.call("_unhandled_input",wheel_in)
	assert_eq(_world.camera.zoom,Vector2.ONE*_world.CONFIG.zoom_levels[_world.CONFIG.zoom_index])
	var start_pos: Vector2 = _world.camera.global_position
	var press: InputEventMouseButton = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_RIGHT
	press.pressed = true
	_world.camera_rig.call("_unhandled_input",press)
	assert_true(_world.camera_rig.is_panning())
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(-120.0,60.0)
	_world.camera_rig.call("_unhandled_input",motion)
	assert_gt(_world.camera.global_position.distance_to(start_pos),100.0)
	var release: InputEventMouseButton = InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_RIGHT
	release.pressed = false
	_world.camera_rig.call("_unhandled_input",release)
	assert_false(_world.camera_rig.is_panning())
	_world.camera_rig.reset_pan()
	assert_eq(_world.camera_rig.get_pan_offset(),Vector2.ZERO)

func test_follow_moves_world_canvas_transform() -> void:
	var marker: Node2D = Node2D.new()
	_world.objects.add_child(marker)
	await get_tree().process_frame
	var before: Vector2 = marker.get_global_transform_with_canvas().origin
	_world.player.position = Vector2(-80,32)
	_world.camera_rig.call("_process",1.0)
	await get_tree().process_frame
	assert_ne(marker.get_global_transform_with_canvas().origin,before)
