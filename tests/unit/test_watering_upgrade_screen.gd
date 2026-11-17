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
	viewport.world_2d = World2D.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.set_process(false)
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

func test_native_entry_focus_purchase_back_escape_and_prior_pause_hold() -> void:
	var flow: WateringUpgradeFlow = main.watering_upgrade_flow
	assert_null(flow.panel.summary)
	GameClock.paused = false
	await _key(KEY_B)
	await _click(main.inventory_panel.screen.footer.watering_upgrade_button)
	assert_true(flow.panel.visible)
	assert_false(main.inventory_panel.visible)
	assert_eq(main.ui_coordinator.get_active_panel(),flow.panel)
	assert_true(GameClock.paused)
	assert_false(main.world.player.movement_enabled)
	assert_eq(flow.panel.summary.capacity.text,tr("WATER_UP_CAPACITY") % [20,40])
	assert_eq(flow.panel.summary.price.text,tr("WATER_UP_PRICE") % 200)
	assert_true(flow.panel.footer.buy_button.disabled)
	main.wallet.add_coins(400,&"test")
	await _settle()
	await _key(KEY_TAB)
	assert_true(viewport.gui_get_focus_owner()!=null)
	flow.panel.footer.buy_button.grab_focus()
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),300)
	assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":20})
	assert_true(flow.panel.footer.buy_button.disabled)
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),300)
	await _click(flow.panel.footer.back_button)
	assert_true(main.inventory_panel.visible)
	assert_true(main.inventory_panel.screen.footer.watering_upgrade_button.disabled)
	assert_false(main.inventory_panel.screen.footer.upgrade_button.disabled)
	await _key(KEY_ESCAPE)
	assert_null(main.ui_coordinator.get_active_panel())
	assert_false(GameClock.paused)
	assert_true(main.world.player.movement_enabled)
	main.watering_can.deserialize({"capacity":20,"charges":7})
	main.watering_runtime.refresh()
	GameClock.paused = true
	await _key(KEY_B)
	await _click(main.inventory_panel.screen.footer.watering_upgrade_button)
	await _key(KEY_ESCAPE)
	assert_true(GameClock.paused,"Existing debug clock hold survives modal dismissal")
	assert_false(main.inventory_panel.visible)
	assert_false(flow.panel.visible)

func test_vi_en_three_sizes_insufficient_available_completed_and_bag_footer_fit() -> void:
	var flow: WateringUpgradeFlow = main.watering_upgrade_flow
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1600,900)]:
			viewport.size = dimensions
			main.ui_coordinator.close_active()
			main.watering_can.deserialize({"capacity":20,"charges":7})
			main.watering_runtime.refresh()
			main.wallet.deserialize({"coins":100})
			main.inventory_panel.toggle_inventory()
			await _settle()
			var footer: LifeInventoryFooter = main.inventory_panel.screen.footer
			assert_true(main.inventory_panel.get_global_rect().encloses(footer.get_global_rect()))
			assert_true(footer.get_global_rect().encloses(footer.watering_upgrade_button.get_global_rect()))
			assert_lte(main.inventory_panel.screen.items.grid.get_combined_minimum_size().y,main.inventory_panel.screen.items.size.y,"All five rows stay visible with both upgrades")
			await _capture("%s_%d_bag" % [language,dimensions.x],main.inventory_panel)
			await _click(footer.watering_upgrade_button)
			assert_true(flow.panel.visible)
			assert_eq(flow.model.target,40)
			assert_eq(flow.model.price,200)
			await _capture("%s_%d_insufficient" % [language,dimensions.x],flow.panel)
			main.wallet.add_coins(400,&"test")
			await _settle()
			await _capture("%s_%d_available" % [language,dimensions.x],flow.panel)
			await _click(flow.panel.footer.buy_button)
			assert_eq(main.watering_can.serialize(),{"capacity":40,"charges":7})
			await _capture("%s_%d_complete" % [language,dimensions.x],flow.panel)

func test_live_locale_and_water_notifications_update_open_readonly_sheet() -> void:
	main.inventory_panel.toggle_inventory()
	main.watering_upgrade_flow.open()
	var flow: WateringUpgradeFlow = main.watering_upgrade_flow
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		main.watering_can.deserialize({"capacity":20,"charges":0})
		main.watering_runtime.refresh()
		await _settle()
		assert_eq(flow.panel.summary.remaining.text,tr("WATER_UP_REMAINING") % 0)
		assert_eq(flow.panel.footer.back_button.text,tr("WATER_UP_BACK"))
		assert_eq(flow.panel.summary.description.text,tr("WATER_UP_DESCRIPTION"))
		assert_eq(main.hotbar_panel.toolbar.buttons.size(),8)
		assert_eq(main.watering_can.serialize(),{"capacity":20,"charges":0})

func _settle() -> void:
	var previous: Array[Rect2] = []
	var stable: int = 0
	for frame: int in range(90):
		await get_tree().process_frame
		var rects: Array[Rect2] = [main.inventory_panel.get_global_rect(),main.inventory_panel.screen.items.get_global_rect(),main.inventory_panel.screen.footer.get_global_rect()]
		if main.watering_upgrade_flow.panel.visible:
			rects.append(main.watering_upgrade_flow.panel.get_global_rect())
			rects.append(main.watering_upgrade_flow.panel.footer.get_global_rect())
		var pending: bool = main.inventory_panel.controller._queued or main.watering_upgrade_flow._queued or main.watering_upgrade_flow._layout_queued or main.ui_coordinator._layout_queued
		stable = stable+1 if not pending and rects==previous else 0
		previous = rects
		if stable>=2:
			return
	assert_true(false,"Native bag upgrade layout did not settle within90 frames")

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

func _capture(stem: String, panel: Control) -> void:
	var pointer: InputEventMouseMotion = InputEventMouseMotion.new()
	pointer.position = Vector2(15,15)
	viewport.push_input(pointer,true)
	await _settle()
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(viewport.size)).grow(1)
	assert_true(bounds.encloses(panel.get_global_rect()),stem+" stays within viewport")
	if panel==main.watering_upgrade_flow.panel:
		for node: Node in panel.find_children("*","Control",true,false):
			var control: Control = node as Control
			if control.is_visible_in_tree():
				assert_true(panel.get_global_rect().grow(1).encloses(control.get_global_rect()),stem+" "+String(control.name))
	var before: Dictionary = {"can":main.watering_can.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"clock":GameClock.serialize()}
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase65h3_%s.png" % stem),OK)
	assert_eq({"can":main.watering_can.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"clock":GameClock.serialize()},before)
