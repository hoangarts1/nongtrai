extends GutTest
const POINT: Vector2 = Vector2(550,350)
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	SaveService.delete_save(1)

func test_native_map_shift_toolbar_wheel_are_exclusive_and_respect_all_zoom_limits() -> void:
	await _settle()
	var before: Dictionary = _owners()
	var bar: LifeHudToolbar = main.hotbar_panel.toolbar
	assert_eq(main.world.camera.zoom,Vector2(0.5,0.5))
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP)
	assert_eq(main.world.camera.zoom,Vector2(0.75,0.75))
	assert_eq(bar.active_index,0)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.world.camera.zoom,Vector2(0.75,0.75))
	assert_eq(bar.active_index,1)
	await _wheel(bar.buttons[0].get_global_rect().get_center(),MOUSE_BUTTON_WHEEL_DOWN)
	assert_eq(main.world.camera.zoom,Vector2(0.75,0.75))
	assert_eq(bar.active_index,2)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP,true)
	assert_eq(bar.active_index,1)
	assert_eq(main.world.camera.zoom,Vector2(0.75,0.75))
	for tool: StringName in [&"watering_can",&"harvest",&"",&"hoe"]:
		await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
		assert_eq(main.hotbar_panel.active_tool(),tool)
		if tool.is_empty():
			assert_eq(main.hotbar_panel.selected_index(),0)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP,true)
	assert_eq(main.hotbar_panel.active_tool(),&"","Reverse cycling skips empty item buttons")
	assert_eq(main.hotbar_panel.selected_index(),0)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.hotbar_panel.active_tool(),&"hoe","Cycling leaves the first seed and wraps")
	await _key(KEY_2)
	for step: int in range(5):
		await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP)
	assert_eq(main.world.camera.zoom,Vector2(1.25,1.25))
	for step: int in range(6):
		await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN)
	assert_almost_eq(main.world.camera.zoom.x,0.35,0.0001)
	await _key(KEY_EQUAL)
	assert_eq(main.world.camera.zoom,Vector2(0.5,0.5))
	await _key(KEY_MINUS)
	assert_almost_eq(main.world.camera.zoom.x,0.35,0.0001)
	assert_eq(bar.active_index,1,"Unmodified map wheel never cycles the tool")
	assert_eq(_owners(),before)
	main.inventory.clear()
	for item: Resource in DataRegistry.get_seed_items():
		main.inventory.add_item(item.get("item_id"),3)
	before = _owners()
	main.hotbar_panel.select_slot(0)
	for index: int in range(1,4):
		await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
		assert_eq(main.hotbar_panel.selected_index(),index,"Each visible item advances once")
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.hotbar_panel.active_tool(),&"hoe")
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP,true)
	assert_eq(main.hotbar_panel.selected_index(),3)
	assert_eq(main.hotbar_panel.active_tool(),&"")
	main.hotbar_panel.select_slot(4)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.hotbar_panel.active_tool(),&"","Selecting item four brings its actual four-item page into view")
	assert_eq(main.hotbar_panel.selected_index(),5,"Wheel advances within the visible second page")
	assert_eq(bar.active_index,5)
	assert_eq(main.world.camera.zoom,Vector2(0.35,0.35))
	assert_eq(_owners(),before)

func test_native_pan_release_reset_walking_bounds_and_cell_picking() -> void:
	await _settle()
	var rig: CameraRig = main.world.camera_rig
	var before: Dictionary = _owners()
	for button: MouseButton in [MOUSE_BUTTON_RIGHT,MOUSE_BUTTON_MIDDLE]:
		await _mouse(POINT,button,true)
		assert_true(rig.is_panning())
		await _motion(POINT+Vector2(-80,30),Vector2(-80,30))
		assert_gt(rig.get_pan_offset().length(),100.0)
		await _mouse(main.hotbar_panel.toolbar.buttons[0].get_global_rect().get_center(),button,false)
		assert_false(rig.is_panning())
		rig.reset_pan()
		assert_eq(rig.get_pan_offset(),Vector2.ZERO)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,true)
	await _motion(POINT,Vector2(-100000,100000))
	assert_eq(rig.get_pan_offset(),Vector2(main.world.CONFIG.camera_pan_max.x,main.world.CONFIG.camera_pan_min.y))
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,false)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,true,true)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,false)
	assert_eq(rig.get_pan_offset(),Vector2.ZERO)
	await _mouse(POINT,MOUSE_BUTTON_MIDDLE,true)
	await _motion(POINT,Vector2(-80,0))
	await _mouse(POINT,MOUSE_BUTTON_MIDDLE,false)
	var distance: float = rig.get_pan_offset().length()
	main.world.player.velocity = Vector2(16,0)
	rig.call("_process",1.0)
	main.world.player.velocity = Vector2.ZERO
	assert_lt(rig.get_pan_offset().length(),distance*0.01)
	rig.reset_pan()
	for index: int in range(main.world.CONFIG.zoom_levels.size()):
		rig.set("_zoom_index",index)
		rig.call("_process",0.0)
		await _settle()
		var cell: Vector2i = Vector2i(2,3)
		assert_eq(main.world.pick_cell(main.world.grid.cell_to_screen(cell)),cell)
	assert_eq(_owners(),before)
	assert_true(DataValidator.validate_isometric_world_config(main.world.CONFIG).is_empty())
	for minimum: Vector2 in [Vector2(INF,0),Vector2(10,10),Vector2(2000,2000)]:
		var invalid: IsometricWorldConfig = main.world.CONFIG.duplicate() as IsometricWorldConfig
		invalid.camera_pan_min = minimum
		assert_false(DataValidator.validate_isometric_world_config(invalid).is_empty())

func test_inventory_scroll_placement_cancel_and_left_click_keep_world_input_ownership() -> void:
	await _settle()
	var rig: CameraRig = main.world.camera_rig
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,true)
	main.inventory_panel.toggle_inventory()
	await _settle()
	assert_false(rig.is_panning())
	var zoom: Vector2 = main.world.camera.zoom
	await _wheel(main.inventory_panel.screen.items.get_global_rect().get_center(),MOUSE_BUTTON_WHEEL_DOWN)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,false)
	assert_eq(main.world.camera.zoom,zoom)
	assert_false(main.world.player.movement_enabled)
	await _key(KEY_ESCAPE)
	main.machine_inventory.add_machine(&"stove",1)
	main.machine_shop_panel.open()
	await _settle()
	main.machine_placement_flow.begin(&"stove")
	await _settle()
	assert_true(main.machine_placement_flow.active)
	await _wheel(POINT,MOUSE_BUTTON_WHEEL_UP)
	assert_eq(main.world.camera.zoom,zoom)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,true)
	await _mouse(POINT,MOUSE_BUTTON_RIGHT,false)
	assert_false(main.machine_placement_flow.active)
	assert_false(rig.is_panning())
	assert_true(main.machine_placements.get_all_placements().is_empty())
	assert_eq(main.machine_inventory.get_quantity(&"stove"),1)
	assert_true(main.world.player.movement_enabled)
	var target: Vector2i = Vector2i(2,3)
	var point: Vector2 = main.world.grid.cell_to_screen(target)
	await _mouse(point,MOUSE_BUTTON_LEFT,true)
	await _mouse(point,MOUSE_BUTTON_LEFT,false)
	assert_true(main.farm_state.get_plot(target).get("tilled",false),"Left click still farms after pan and placement cancel")

func _owners() -> Dictionary:
	return {"farm":main.farm_state.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"jobs":main.machine_operations.serialize(),"clock":GameClock.serialize()}

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _motion(point: Vector2, relative: Vector2 = Vector2.ZERO) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.relative = relative
	viewport.push_input(event,true)
	await _settle()

func _mouse(point: Vector2, button: MouseButton, pressed: bool, double: bool = false) -> void:
	var pointer: InputEventMouseMotion = InputEventMouseMotion.new()
	pointer.position = point
	viewport.push_input(pointer,true)
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = button
	event.pressed = pressed
	event.double_click = double
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if button==MOUSE_BUTTON_LEFT and pressed else 0
	viewport.push_input(event,true)
	await _settle()

func _wheel(point: Vector2, button: MouseButton, shift: bool = false) -> void:
	var pointer: InputEventMouseMotion = InputEventMouseMotion.new()
	pointer.position = point
	viewport.push_input(pointer,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = button
		event.pressed = pressed
		event.shift_pressed = shift
		viewport.push_input(event,true)
	# push_input dispatches wheel synchronously; one frame also flushes hover/layout work.
	await get_tree().process_frame

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
	await get_tree().process_frame
