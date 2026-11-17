extends GutTest
const CELL: Vector2i = Vector2i(2,3)
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
	_main.machine_inventory.add_machine(&"stove",2)
	_flow = _main.machine_placement_flow

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(1)

func test_native_place_rotate_no_click_through_busy_return_and_one_machine() -> void:
	var before: Dictionary = _owners()
	await _begin()
	assert_eq(_owners(),before)
	assert_false(_main.world.player.movement_enabled)
	assert_true(GameClock.paused)
	assert_eq(_main.ui_coordinator.get_active_panel(),_flow.panel)
	await _point(_main.world.player.get_cell())
	assert_eq(_flow.preview.reason,&"player_occupied")
	await _world_click(_main.world.player.get_cell())
	assert_true(_flow.active)
	assert_eq(_owners(),before)
	await _point(CELL)
	assert_true(_flow.preview.ok)
	await _key(KEY_R)
	assert_eq(_flow.rotation,90)
	await _key(KEY_Q)
	assert_eq(_flow.rotation,0)
	await _key(KEY_R)
	await _world_click(CELL)
	assert_false(_flow.active)
	assert_eq(_main.machine_placements.get_placement(CELL).rotation,90)
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),1)
	assert_eq(_main.farm_state.serialize(),before.farm)
	before = _owners()
	await _world_click(CELL)
	_main.tool_controller.select_seed()
	await _world_click(CELL)
	assert_eq(_owners(),before,"Post-placement clicks cannot till/sow under the machine or duplicate it")
	# Existing saves may already contain a crop under an older test placement.
	var crop: CropData = DataRegistry.get_crop_for_seed(DataRegistry.get_starter_seed_for_season(GameClock.season)) as CropData
	assert_true(_main.farm_state.till_cell(CELL))
	assert_true(_main.farm_state.plant_crop(CELL,crop.crop_id))
	_main.tool_controller.perform_crop_action(CELL,&"water")
	assert_true(_main.farm_state.get_plot(CELL).watered)
	for day: int in range(_main.farm_state.get_growth_target(CELL)):
		_main.farm_state.water_cell(CELL)
		_main.farm_state.advance_day()
	assert_true(_main.farm_state.can_harvest(CELL))
	_main.tool_controller.perform_crop_action(CELL,&"harvest")
	assert_false(_main.farm_state.can_harvest(CELL),"Legacy crops can still be cared for and harvested")
	_main.inventory.add_item(&"carrot",2)
	assert_true(_main.machine_operations.start(CELL,&"stove_carrot_meal",1).ok)
	_main.machine_shop_panel.open_machine(CELL)
	await _settle()
	var footer: LifeMachineFooter = _main.machine_shop_panel.screen.footer
	assert_true(footer.buttons[&"return"].disabled)
	before = _owners()
	_main.machine_shop_panel.controller.request(&"return")
	await _settle()
	assert_eq(_owners(),before)
	assert_eq(_main.machine_shop_panel.controller.result.reason,&"machine_busy")
	_main.machine_shop_panel.close()
	_main.machine_operations.advance_day()
	_main.machine_shop_panel.open_machine(CELL)
	await _settle()
	assert_true(footer.buttons[&"return"].disabled)
	await _click(footer.buttons[&"collect"])
	assert_false(footer.buttons[&"return"].disabled)
	await _click(footer.buttons[&"return"])
	assert_true(_main.machine_placements.get_placement(CELL).is_empty())
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),2)
	assert_eq(_main.inventory.get_quantity(&"temp_carrot_meal"),1)
	assert_eq(_main.machine_shop_panel.controller.result.reason,&"removed")
	before = _owners()
	_main.machine_shop_panel.controller.request(&"return")
	assert_eq(_owners(),before)
	await _begin()
	await _point(CELL)
	await _key(KEY_SPACE)
	assert_false(_flow.active,"Space confirms the focused background plane once")

func test_preview_matrix_and_modal_lifecycle_cancel_without_reservation_or_clock_change() -> void:
	var before: Dictionary = _owners()
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		var sizes: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
		for index: int in range(sizes.size()):
			var size: Vector2i = sizes[index]
			_viewport.size = size
			_main.world.camera_rig.set("_zoom_index",index)
			await _begin()
			await _point(CELL)
			assert_eq(_main.world.camera.zoom,Vector2.ONE*float(_main.world.CONFIG.zoom_levels[index]))
			assert_almost_eq(_flow.panel.ghost.position,_main.world.grid.cell_to_screen(CELL),Vector2.ONE)
			assert_true(_flow.preview.ok)
			await _capture("%s_%d_valid" % [locale,size.x])
			await _point(_main.world.player.get_cell())
			assert_false(_flow.preview.ok)
			await _capture("%s_%d_invalid" % [locale,size.x])
			await _key(KEY_TAB)
			assert_true(_flow.active)
			assert_false(_main.inventory_panel.visible)
			await _key(KEY_ESCAPE)
			assert_false(_flow.active)
			assert_false(_flow.panel.ghost.visible)
			assert_eq(_owners(),before)
	await _begin()
	await _point(CELL)
	assert_true(_main.call("_save_game_to_slot",1))
	var payload: Dictionary = SaveService.load_game(1)
	assert_eq(payload.machine_inventory.machines[0].quantity,2.0)
	_main.call("_load_payload",payload)
	await _settle()
	assert_false(_flow.active)
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),2)
	await _begin()
	await _point(CELL)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	assert_false(_flow.active)
	_main.inventory_panel.close_inventory()
	GameClock.paused = false
	await _begin()
	await _click(_flow.panel.status.cancel_button)
	assert_false(GameClock.paused,"Original running clock resumes")
	await _begin()
	await _point(CELL)
	_main.call("_start_new_game","Lan","Vườn mới")
	await _settle()
	assert_false(_flow.active)
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),0)
	assert_eq(_main.machine_placements.get_all_placements().size(),0)

func test_forced_day_end_sleep_and_title_discard_pending_placement() -> void:
	var stock: Dictionary = _main.machine_inventory.serialize()
	await _begin()
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	await _settle()
	assert_false(_flow.active)
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.day_end_flow.panel)
	assert_eq(_main.machine_inventory.serialize(),stock)
	assert_true(_main.day_end_flow.cancel())
	await _begin()
	var right: InputEventMouseButton = InputEventMouseButton.new()
	right.button_index = MOUSE_BUTTON_RIGHT
	right.pressed = true
	right.position = _main.world.grid.cell_to_screen(CELL)
	_viewport.push_input(right,true)
	assert_false(_flow.active)
	await _begin()
	assert_true(_main.call("_return_to_start_menu"))
	await _settle()
	assert_false(_flow.active)
	assert_true(_main.start_menu.visible)
	_main.start_menu.hide()
	await _begin()
	assert_true(GameClock.try_sleep())
	await _settle()
	assert_false(_flow.active)
	assert_false(_main.world.player.movement_enabled)
	assert_eq(_main.machine_inventory.serialize(),stock)
	assert_true(_main.machine_placements.get_all_placements().is_empty())

func _owners() -> Dictionary:
	return {"owned":_main.machine_inventory.serialize(),"placed":_main.machine_placements.serialize(),"jobs":_main.machine_operations.serialize(),"farm":_main.farm_state.serialize(),"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"clock":GameClock.serialize()}

func _begin() -> void:
	_main.machine_shop_panel.open()
	await _settle()
	_main.machine_shop_panel.controller.request(&"place")
	await _settle()
	assert_true(_flow.active)

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()
func _point(cell: Vector2i) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = _main.world.grid.cell_to_screen(cell)
	event.relative = event.position-_viewport.get_mouse_position()
	_viewport.push_input(event,true)
	await _settle()

func _world_click(cell: Vector2i) -> void:
	await _point(cell)
	await _mouse(_main.world.grid.cell_to_screen(cell))

func _click(button: Control) -> void:
	await _mouse(button.get_global_rect().get_center())

func _mouse(point: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _capture(name: String) -> void:
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(_viewport.size)).grow(1)
	assert_true(bounds.encloses(_flow.panel.status.get_global_rect()))
	for node: Node in _flow.panel.status.find_children("*","Button",true,false):
		assert_true(bounds.encloses((node as Control).get_global_rect()))
	if DisplayServer.get_name()!="headless":
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://phase65e_%s.png" % name),OK)
