extends GutTest
const SOURCE: Vector2i = Vector2i(2,3)
const TARGET: Vector2i = Vector2i(3,2)
var _main: Node
var _viewport: SubViewport
var _flow: MachinePlacementFlow
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game","Mai","Vườn")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true
	_main.machine_inventory.add_machine(&"stove",1)
	assert_true(_main.machine_build.place(&"stove",SOURCE,0).ok)
	_main.machine_presentation.refresh()
	_flow = _main.machine_placement_flow

func after_each() -> void:
	Input.action_release("use_tool")
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(1)

func test_native_move_rotation_stale_busy_save_load_and_held_confirm_do_not_leak() -> void:
	assert_true(_main.call("_save_game_to_slot",1))
	var original: Dictionary = SaveService.load_game(1)
	var before: Dictionary = _owners()
	await _begin(SOURCE)
	assert_eq(_owners(),before,"Opening Move retains its source without reserving stock")
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),0)
	assert_false(_main.world.player.movement_enabled)
	await _point(TARGET)
	await _key(KEY_R)
	assert_eq(_flow.rotation,90)
	Input.action_press("use_tool")
	await _mouse(_flow.panel.status.confirm_button.get_global_rect().get_center())
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_true(_main.machine_placements.get_placement(SOURCE).is_empty())
	assert_eq(_main.machine_placements.get_placement(TARGET).rotation,90)
	assert_eq(_main.machine_inventory.serialize(),before.owned)
	assert_eq(_main.inventory.serialize(),before.bag)
	assert_eq(_main.wallet.serialize(),before.wallet)
	assert_eq(_main.farm_state.serialize(),before.farm)
	await _point(SOURCE)
	await _key(KEY_SPACE)
	assert_eq(_main.farm_state.serialize(),before.farm,"Held confirmation cannot till the newly freed source")
	Input.action_release("use_tool")
	assert_true(_main.call("_save_game_to_slot",1))
	var moved: Dictionary = SaveService.load_game(1)
	_main.call("_load_payload",original)
	await _settle()
	assert_false(_main.machine_placements.get_placement(SOURCE).is_empty())
	await _begin(SOURCE)
	_main.call("_load_payload",moved)
	await _settle()
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_eq(_main.machine_placements.get_placement(TARGET).rotation,90)
	await _begin(TARGET)
	assert_true(_main.machine_build.rotate(TARGET,180).ok)
	before = _owners()
	await _point(SOURCE)
	assert_eq(_flow.preview.reason,&"stale_source")
	_flow.confirm()
	assert_eq(_flow.panel.status.reason.text,tr("PLC_MOVE_STALE"))
	assert_eq(_owners(),before)
	await _key(KEY_ESCAPE)
	await _begin(TARGET)
	_main.inventory.add_item(&"carrot",2)
	assert_true(_main.machine_operations.start(TARGET,&"stove_carrot_meal",1).ok)
	before = _owners()
	await _point(SOURCE)
	_flow.confirm()
	assert_eq(_flow.preview.reason,&"machine_busy")
	assert_eq(_owners(),before)
	_main.machine_shop_panel.open_machine(TARGET)
	await _settle()
	assert_false(_flow.active)
	assert_true(_main.machine_shop_panel.screen.footer.buttons[&"move"].disabled)
	_main.machine_shop_panel.controller.request(&"move")
	assert_eq(_owners(),before)

func test_locales_sizes_zooms_footer_fit_native_cancel_and_in_place_rotation() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		var sizes: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
		for index: int in range(sizes.size()):
			_viewport.size = sizes[index]
			_main.world.camera_rig.set("_zoom_index",index)
			_main.machine_shop_panel.open_machine(SOURCE)
			await _settle()
			_check_bounds(_main.machine_shop_panel.screen.footer)
			assert_false(_main.machine_shop_panel.screen.footer.buttons[&"move"].disabled)
			if index==0:
				await _capture("%s_footer" % locale)
			await _mouse((_main.machine_shop_panel.screen.footer.buttons[&"move"] as Control).get_global_rect().get_center())
			assert_true(_flow.active)
			var before: Dictionary = _owners()
			await _point(TARGET)
			assert_true(_flow.preview.ok)
			assert_eq(_main.world.camera.zoom,Vector2.ONE*float(_main.world.CONFIG.zoom_levels[index]))
			assert_almost_eq(_flow.panel.ghost.position,_main.world.grid.cell_to_screen(TARGET),Vector2.ONE)
			_check_bounds(_flow.panel.status)
			assert_true(_flow.panel.status.info.text.contains(str(SOURCE)))
			assert_true(_flow.panel.status.info.text.contains(str(TARGET)))
			await _capture("%s_%d_move" % [locale,sizes[index].x])
			await _point(_main.world.player.get_cell())
			assert_false(_flow.preview.ok)
			assert_true(_flow.panel.status.confirm_button.disabled)
			if index==0:
				await _capture("%s_invalid" % locale)
			await _key(KEY_TAB)
			assert_false(_main.inventory_panel.visible)
			await _key(KEY_ESCAPE)
			assert_false(_flow.active)
			assert_true(_flow.source.is_empty())
			assert_eq(_owners(),before)
	await _begin(SOURCE)
	await _point(SOURCE)
	await _key(KEY_Q)
	await _key(KEY_SPACE)
	assert_false(_flow.active)
	assert_eq(_main.machine_placements.get_placement(SOURCE).rotation,270)
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),0)

func test_lifecycle_cancellation_retains_source_and_clears_move_context() -> void:
	await _begin(SOURCE)
	var before: Dictionary = _owners()
	await _right_cancel()
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_eq(_owners(),before)
	await _begin(SOURCE)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	_main.inventory_panel.close_inventory()
	await _begin(SOURCE)
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	await _settle()
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_true(_main.day_end_flow.cancel())
	await _begin(SOURCE)
	assert_true(_main.call("_return_to_start_menu"))
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	_main.call("_load_payload",SaveService.load_game(1))
	await _begin(SOURCE)
	assert_true(GameClock.try_sleep())
	await _settle()
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_false(_main.machine_placements.get_placement(SOURCE).is_empty())
	_main.call("_start_new_game","Mai","Vườn mới")
	assert_false(_flow.active)
	assert_true(_flow.source.is_empty())
	assert_true(_main.machine_placements.get_all_placements().is_empty())

func _owners() -> Dictionary:
	return {"owned":_main.machine_inventory.serialize(),"placed":_main.machine_placements.serialize(),"jobs":_main.machine_operations.serialize(),"farm":_main.farm_state.serialize(),"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"clock":GameClock.serialize()}

func _begin(cell: Vector2i) -> void:
	_main.machine_shop_panel.open_machine(cell)
	await _settle()
	await _mouse((_main.machine_shop_panel.screen.footer.buttons[&"move"] as Control).get_global_rect().get_center())
	assert_true(_flow.active)

func _settle() -> void:
	var stable: int = 0
	for frame: int in range(30):
		await get_tree().process_frame
		stable = stable+1 if not bool(_main.machine_shop_panel.controller.get("_queued")) and not bool(_main.ui_coordinator.get("_layout_queued")) else 0
		if stable>=2:
			return
	assert_true(false,"Machine move UI did not settle")

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
	await _settle()

func _point(cell: Vector2i) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = _main.world.grid.cell_to_screen(cell)
	event.relative = event.position-_viewport.get_mouse_position()
	_viewport.push_input(event,true)
	await _settle()

func _mouse(point: Vector2) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		_viewport.push_input(event,true)
	await _settle()

func _right_cancel() -> void:
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = _main.world.grid.cell_to_screen(TARGET)
		event.button_index = MOUSE_BUTTON_RIGHT
		event.pressed = pressed
		_viewport.push_input(event,true)
	await _settle()

func _check_bounds(root: Control) -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(_viewport.size)).grow(1)
	assert_true(bounds.encloses(root.get_global_rect()))
	for node: Node in root.find_children("*","Button",true,false):
		var control: Control = node as Control
		if control.is_visible_in_tree():
			assert_true(root.get_global_rect().grow(1).encloses(control.get_global_rect()))

func _capture(name: String) -> void:
	if DisplayServer.get_name()!="headless":
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://phase65f_%s.png" % name),OK)
