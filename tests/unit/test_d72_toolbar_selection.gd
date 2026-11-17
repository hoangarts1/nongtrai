extends GutTest
const POINT: Vector2 = Vector2(550,350)
var main: Node
var viewport: SubViewport
var bar: LifeHudToolbar
var clock: Dictionary
var paused: bool
var accumulator: float
var speed: float
var locale: String

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	speed = GameClock.time_speed
	locale = TranslationServer.get_locale()
	GameClock.paused = true
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
	main.inventory.clear()
	var index: int = 0
	for item: Resource in DataRegistry.get_seed_items():
		if index==9:
			break
		main.inventory.add_item(item.get("item_id"),index+1)
		index += 1
	assert_eq(main.inventory.get_slots().size(),9)
	bar = main.hotbar_panel.toolbar
	await _settle()

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.time_speed = speed
	GameClock.paused = paused
	TranslationServer.set_locale(locale)
	SaveService.delete_save(1)

func test_real_item_boundaries_caption_icon_quantity_and_selected_style_in_vi_en() -> void:
	var before: Dictionary = _owners()
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for pair: Vector2i in [Vector2i(0,4),Vector2i(3,7),Vector2i(4,4),Vector2i(7,7),Vector2i(8,4)]:
			main.hotbar_panel.select_slot(pair.x)
			_check_item(pair.x,pair.y)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1600,900)]:
			viewport.size = dimensions
			for index: int in [0,8]:
				main.hotbar_panel.select_slot(index)
				_check_item(index,4)
				await _settle()
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).grow(1).encloses(main.hotbar_panel.get_global_rect()))
				assert_true(main.hotbar_panel.get_global_rect().grow(1).encloses(bar.caption.get_global_rect()))
				if DisplayServer.get_name()!="headless":
					viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					await RenderingServer.frame_post_draw
					assert_eq(viewport.get_texture().get_image().save_png("user://d72_c3_%s_%d_item%d.png" % [language,dimensions.x,index]),OK)
	assert_eq(_owners(),before,"Selection and rendering preserve actual game owners")

func test_native_nine_numbers_click_wheel_and_inventory_f_keep_the_same_real_stack() -> void:
	var before: Dictionary = _owners()
	var zoom: Vector2 = main.world.camera.zoom
	await _key(KEY_9)
	_check_item(8,4)
	await _pointer(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.hotbar_panel.active_tool(),&"hoe")
	assert_eq(bar.active_index,0)
	await _pointer(bar.buttons[0].get_global_rect().get_center(),MOUSE_BUTTON_WHEEL_UP)
	_check_item(8,4)
	await _key(KEY_6)
	_check_item(8,4)
	await _pointer(bar.buttons[5].get_global_rect().get_center(),MOUSE_BUTTON_LEFT)
	_check_item(8,4)
	main.hotbar_panel.select_slot(4)
	await _key(KEY_8)
	_check_item(7,7)
	await _pointer(POINT,MOUSE_BUTTON_WHEEL_DOWN,true)
	assert_eq(main.hotbar_panel.active_tool(),&"hoe")
	await _pointer(bar.buttons[4].get_global_rect().get_center(),MOUSE_BUTTON_LEFT)
	_check_item(4,4)
	await _key(KEY_B)
	assert_true(main.inventory_panel.visible)
	main.inventory_panel.controller.select(8)
	await _key(KEY_F)
	assert_false(main.inventory_panel.visible)
	assert_true(main.world.player.movement_enabled)
	_check_item(8,4)
	assert_eq(main.world.camera.zoom,zoom,"Qualified wheel never zooms")
	assert_eq(_owners(),before)

func test_actual_sort_discard_remap_and_invalid_or_empty_view_clear_stale_selection() -> void:
	main.hotbar_panel.select_slot(8)
	var identity: StringName = main.hotbar_panel.get_selected_slot()["item_id"]
	var stable: Dictionary = _owners()
	main.inventory_panel.toggle_inventory()
	main.inventory_panel.controller.sort_items()
	await _settle()
	assert_eq(main.hotbar_panel.get_selected_slot()["item_id"],identity,"Sort retains selected item identity")
	var selected: int = main.hotbar_panel.selected_index()
	_check_item(selected,4+selected%4)
	main.hotbar_panel.select_slot(7)
	identity = main.hotbar_panel.get_selected_slot()["item_id"]
	var discarded: int = int(main.inventory.get_slots()[0]["quantity"])
	main.inventory_panel.controller.select(0)
	main.inventory_panel.controller.request_discard()
	main.inventory_panel.controller.confirm_discard(discarded)
	main.inventory_panel.close_inventory()
	await _settle()
	assert_eq(main.inventory.get_slots().size(),8)
	assert_eq(main.hotbar_panel.get_selected_slot()["item_id"],identity)
	_check_item(6,6)
	stable.bag = main.inventory.serialize()
	assert_eq(_owners(),stable,"Only explicitly requested sorting/discard changes the bag")
	var before: Dictionary = _owners()
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for index: int in [-1,4,99]:
			bar.display(main.inventory.get_slots(),index,&"",0)
			_check_none()
		bar.display([],0,&"",0)
		bar.request(4)
		_check_none()
		assert_eq(main.hotbar_panel.selected_index(),6,"Empty display cannot request an absent item")
		main.hotbar_panel.refresh_readability()
		_check_item(6,6)
	assert_eq(_owners(),before)
	main.inventory.clear()
	assert_eq(main.hotbar_panel.active_tool(),&"hoe")
	assert_eq(bar.active_index,0)
	assert_eq(bar.caption.text,tr("UI_TOOL_HOE"))

func _check_item(index: int, visible_index: int) -> void:
	var item: Dictionary = main.inventory.get_slots()[index]
	var title: String = tr(String(DataRegistry.get_item(item["item_id"]).get("display_name_key")))
	assert_eq(main.hotbar_panel.selected_index(),index)
	assert_eq(main.hotbar_panel.active_tool(),&"")
	assert_eq(main.hotbar_panel.get_selected_slot(),item)
	assert_eq(bar.active_index,visible_index)
	assert_eq(bar.caption.text,title)
	assert_eq(bar.buttons[visible_index].tooltip_text,title)
	assert_eq(bar.buttons[visible_index].icon,UiIcons.for_item(item["item_id"]))
	assert_eq(bar.buttons[visible_index].quantity_label.text,str(item["quantity"]))
	for button_index: int in range(bar.buttons.size()):
		assert_eq(bar.buttons[button_index].theme_type_variation,&"LifeHudSlotSelected" if button_index==visible_index else &"LifeHudSlot")

func _check_none() -> void:
	assert_eq(bar.active_index,-1)
	assert_eq(bar.caption.text,tr("UI_TOOL_SEED"))
	for button: LifeHudToolbarSlot in bar.buttons:
		assert_eq(button.theme_type_variation,&"LifeHudSlot")

func _owners() -> Dictionary:
	return {"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"farm":main.farm_state.serialize(),"jobs":main.machine_operations.serialize(),"clock":GameClock.serialize(),"save":SaveService.load_game(1)}

func _settle() -> void:
	var previous: Rect2
	var stable: int = 0
	for frame: int in range(90):
		await get_tree().process_frame
		var current: Rect2 = main.hotbar_panel.get_global_rect()
		stable = stable+1 if current==previous and not main.ui_coordinator._layout_queued and not main.inventory_panel.controller._queued else 0
		previous = current
		if stable>=2:
			return
	assert_true(false,"Toolbar geometry did not settle")

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
	await _settle()

func _pointer(point: Vector2, button: MouseButton, shift: bool = false) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = button
		event.pressed = pressed
		event.shift_pressed = shift
		viewport.push_input(event,true)
	await _settle()
