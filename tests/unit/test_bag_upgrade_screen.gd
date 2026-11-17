extends GutTest
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var locale: String

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	locale = TranslationServer.get_locale()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	await get_tree().process_frame
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)
	SaveService.delete_save(1)

func test_native_purchase_back_escape_and_slot52_quick_select_sort_discard() -> void:
	var flow: BagUpgradeFlow = main.bag_upgrade_flow
	assert_null(flow.panel.summary,"Modal contents stay lazy until used")
	await _key(KEY_B)
	await _click(main.inventory_panel.screen.footer.upgrade_button)
	assert_true(flow.panel.visible)
	assert_false(main.inventory_panel.visible)
	assert_eq(main.ui_coordinator.get_active_panel(),flow.panel)
	assert_false(main.world.player.movement_enabled)
	assert_true(flow.panel.footer.buy_button.disabled)
	await _click(flow.panel.footer.buy_button)
	assert_eq(main.wallet.get_coins(),100)
	main.wallet.add_coins(900,&"test")
	await _settle()
	flow.panel.footer.buy_button.grab_focus()
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),700)
	assert_eq(main.inventory.capacity,52)
	assert_true(flow.panel.footer.buy_button.disabled)
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),700)
	await _click(flow.panel.footer.back_button)
	assert_true(main.inventory_panel.visible)
	assert_true(main.inventory_panel.screen.footer.upgrade_button.disabled)
	await _key(KEY_ESCAPE)
	assert_null(main.ui_coordinator.get_active_panel())
	assert_true(main.world.player.movement_enabled)
	_fill52()
	await _key(KEY_B)
	await _scroll_bottom()
	var grid: LifeInventoryGrid = main.inventory_panel.screen.items
	assert_eq(grid.buttons.size(),52)
	assert_true(grid.get_global_rect().grow(1).encloses(grid.buttons[51].get_global_rect()),"Slot52 stays within the scroll viewport")
	await _click(grid.buttons[51])
	assert_eq(main.inventory_panel.controller.selected,51)
	await _key(KEY_F)
	assert_false(main.inventory_panel.visible)
	assert_eq(main.hotbar_panel.selected_index(),51)
	await _key(KEY_B)
	await _key(KEY_Z)
	assert_eq(main.inventory.get_slots()[0].item_id,&"spring_carrot_seed")
	assert_eq(main.inventory_panel.controller.selected,0)
	assert_eq(main.hotbar_panel.selected_index(),0)
	await _click(main.inventory_panel.screen.detail.discard_button)
	await _click(main.inventory_panel.screen.discard.confirm_button)
	assert_eq(main.inventory.get_slots()[0].quantity,6)
	assert_eq(main.inventory.capacity,52)
	assert_eq(main.wallet.get_coins(),700)
	assert_true(main.farm_state.serialize().get("plots",[]).is_empty())

func test_vi_en_three_sizes_affordability_complete_and_extra_rows_render_without_mutation() -> void:
	var flow: BagUpgradeFlow = main.bag_upgrade_flow
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1600,900)]:
			viewport.size = dimensions
			main.ui_coordinator.close_active()
			main.inventory.deserialize({"capacity":40,"slots":[]})
			main.wallet.deserialize({"coins":100})
			main.inventory_panel.toggle_inventory()
			await _settle()
			await _click(main.inventory_panel.screen.footer.upgrade_button)
			assert_true(flow.panel.visible)
			await _capture("%s_%d_locked" % [language,dimensions.x],true)
			main.wallet.add_coins(900,&"test")
			await _settle()
			await _capture("%s_%d_available" % [language,dimensions.x],true)
			await _click(flow.panel.footer.buy_button)
			assert_eq(main.inventory.capacity,52)
			assert_eq(main.wallet.get_coins(),700)
			await _capture("%s_%d_complete" % [language,dimensions.x],true)
			await _click(flow.panel.footer.back_button)
			_fill52()
			await _settle()
			await _scroll_bottom()
			assert_eq(main.inventory_panel.screen.items.buttons.size(),52)
			await _click(main.inventory_panel.screen.items.buttons[51])
			assert_eq(main.inventory_panel.controller.selected,51)
			await _capture("%s_%d_slot52" % [language,dimensions.x],false)

func _fill52() -> void:
	var slots: Array[Dictionary] = []
	for index: int in range(51):
		slots.append({"item_id":"turnip","quantity":1})
	slots.append({"item_id":"spring_carrot_seed","quantity":7})
	main.inventory.deserialize({"capacity":52,"slots":slots})

func _settle() -> void:
	var previous: Array[Rect2] = []
	var stable: int = 0
	for frame: int in range(90):
		await get_tree().process_frame
		var rects: Array[Rect2] = [main.inventory_panel.get_global_rect(),main.inventory_panel.screen.items.get_global_rect(),main.inventory_panel.screen.footer.get_global_rect()]
		if main.bag_upgrade_flow.panel.visible:
			rects.append(main.bag_upgrade_flow.panel.get_global_rect())
			rects.append(main.bag_upgrade_flow.panel.footer.get_global_rect())
		var pending: bool = main.inventory_panel.controller._queued or main.bag_upgrade_flow._queued or main.bag_upgrade_flow._layout_queued or main.ui_coordinator._layout_queued
		stable = stable+1 if not pending and rects==previous else 0
		previous = rects
		if stable>=2:
			return
	assert_true(false,"Native bag upgrade layout did not settle within90 frames")

func _scroll_bottom() -> void:
	var grid: LifeInventoryGrid = main.inventory_panel.screen.items
	var point: Vector2 = grid.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion,true)
	for step: int in range(12):
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		viewport.push_input(event,true)
		event = event.duplicate() as InputEventMouseButton
		event.pressed = false
		viewport.push_input(event,true)
	await _settle()

func _click(button: Control) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion,true)
	await get_tree().process_frame
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _capture(stem: String, modal: bool) -> void:
	var pointer: InputEventMouseMotion = InputEventMouseMotion.new()
	pointer.position = Vector2(15,15)
	viewport.push_input(pointer,true)
	if not modal:
		var focused: Control = viewport.gui_get_focus_owner()
		if focused!=null:
			focused.release_focus()
		var last: LifeInventorySlot = main.inventory_panel.screen.items.buttons[51]
		for frame: int in range(30):
			await get_tree().process_frame
			if last.scale.is_equal_approx(Vector2.ONE):
				break
	await _settle()
	var panel: Control = main.bag_upgrade_flow.panel if modal else main.inventory_panel
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(viewport.size)).grow(1)
	assert_true(bounds.encloses(panel.get_global_rect()),stem+" stays within viewport")
	if modal:
		for node: Node in panel.find_children("*","Control",true,false):
			var control: Control = node as Control
			if control.is_visible_in_tree():
				assert_true(panel.get_global_rect().grow(1).encloses(control.get_global_rect()),String(control.name)+" stays within modal")
	else:
		var grid: LifeInventoryGrid = main.inventory_panel.screen.items
		assert_true(grid.get_global_rect().grow(1).encloses(grid.buttons[51].get_global_rect()),"Slot52 stays within the scroll viewport")
		assert_true(panel.get_global_rect().encloses(main.inventory_panel.screen.footer.get_global_rect()))
	var before: Dictionary = {"inventory":main.inventory.serialize(),"wallet":main.wallet.serialize(),"clock":GameClock.serialize()}
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase65g_%s.png" % stem),OK)
	assert_eq({"inventory":main.inventory.serialize(),"wallet":main.wallet.serialize(),"clock":GameClock.serialize()},before)
