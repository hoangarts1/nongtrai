extends GutTest

var _clock: Dictionary
var _paused: bool
var _locale: String
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	GameClock.deserialize({})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	_main.set("_game_started",true)
	_main.day_end_flow.reset()
	_main.inventory.clear()

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _settle() -> void:
	# Wait for actual deferred work and geometry, not a delay after every action.
	var previous: Array[Rect2] = []
	var stable_frames: int = 0
	for frame: int in range(120):
		await get_tree().process_frame
		var current: Array[Rect2] = _visible_rects()
		var pending: bool = bool(_main.inventory_panel.controller.get("_queued")) or bool(_main.ui_coordinator.get("_layout_queued"))
		stable_frames = stable_frames+1 if not pending and current==previous else 0
		previous = current
		if stable_frames>=2:
			return
	assert_true(false,"Native inventory refresh/layout did not settle within120 process frames")

func _visible_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for node: Node in _main.find_children("*","Control",true,false):
		var control: Control = node as Control
		if control.is_visible_in_tree():
			rects.append(control.get_global_rect())
	return rects

func _key(code: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	_viewport.push_input(event)
	event = event.duplicate() as InputEventKey
	event.pressed = false
	_viewport.push_input(event)
	await _settle()

func _click(button: Button) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = button.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	_viewport.push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	_viewport.push_input(event)
	await _settle()

func test_filtered_mouse_selection_and_f_use_original_stack_without_changing_economy() -> void:
	_main.inventory.add_item(&"turnip",3)
	_main.inventory.add_item(&"spring_pea_seed",7)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	var screen: LifeInventoryScreen = _main.inventory_panel.screen
	var wallet: Dictionary = _main.wallet.serialize()
	var ledger: Dictionary = _main.day_end_flow.ledger.serialize()
	await _click(screen.filters.buttons[1])
	assert_eq(screen.items.visible_indices,[1])
	assert_eq(screen.items.buttons.size(),40)
	await _click(screen.items.buttons[0])
	assert_true(_main.inventory_panel.visible)
	assert_eq(screen.detail.count_label.text,tr("INV_QUANTITY") % 7)
	await _key(KEY_F)
	assert_false(_main.inventory_panel.visible)
	assert_eq(_main.hotbar_panel.get_selected_slot()["item_id"],&"spring_pea_seed")
	assert_eq(_main.tool_controller.get_selected_tool(),&"seed")
	assert_eq(_main.inventory.get_quantity(&"spring_pea_seed"),7)
	assert_eq(_main.wallet.serialize(),wallet)
	assert_eq(_main.day_end_flow.ledger.serialize(),ledger)

func test_native_tabs_contextual_keys_and_forced_summary_lock() -> void:
	_main.inventory.add_item(&"turnip",3)
	_main.inventory.add_item(&"turnip_seed",7)
	_main.hotbar_panel.select_slot(0)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	var screen: LifeInventoryScreen = _main.inventory_panel.screen
	assert_eq(screen.tabs.buttons.size(),5)
	await _click(screen.tabs.buttons[0])
	assert_true(screen.tabs.buttons[0].button_pressed,"Current tab remains selected after repeated click")
	for index: int in range(5):
		assert_eq(screen.tabs.buttons[index].disabled,index not in [0,1,2])
	var farm: Dictionary = _main.farm_state.serialize()
	await _key(KEY_Z)
	assert_eq(_main.hotbar_panel.get_selected_slot()["item_id"],&"turnip")
	await _key(KEY_E)
	assert_true(_main.character_flow.panel.visible)
	assert_false(_main.inventory_panel.visible)
	await _key(KEY_E)
	assert_true(_main.npc_system.journal.visible)
	assert_false(_main.inventory_panel.visible)
	assert_false(_main.npc_system.dialogue.visible)
	assert_false(_main.world.player.movement_enabled)
	await _key(KEY_Q)
	assert_true(_main.character_flow.panel.visible)
	await _key(KEY_Q)
	assert_true(_main.inventory_panel.visible)
	await _click(screen.tabs.buttons[2])
	assert_true(_main.npc_system.journal.visible)
	await _click(_main.npc_system.journal.tabs.buttons[0])
	assert_true(_main.inventory_panel.visible)
	assert_eq(_main.farm_state.serialize(),farm)
	await _key(KEY_ESCAPE)
	assert_false(_main.inventory_panel.visible)
	assert_true(_main.world.player.movement_enabled)
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	assert_true(_main.day_end_flow.panel.visible)
	for code: Key in [KEY_Q,KEY_E,KEY_F,KEY_Z,KEY_B]:
		await _key(code)
		assert_true(_main.day_end_flow.panel.visible)
		assert_false(_main.inventory_panel.visible)
		assert_false(_main.npc_system.journal.visible)
	assert_eq(_main.inventory.get_quantity(&"turnip"),3)

func test_rapid_close_click_passes_through_read_only_clock_decoration() -> void:
	_main.inventory_panel.toggle_inventory()
	await get_tree().process_frame
	await get_tree().process_frame
	var close: Button = _main.inventory_panel.screen.tabs.close_button
	assert_true(_main.hud_presenter.root.clock_card.is_visible_in_tree())
	await _click(close)
	assert_false(_main.inventory_panel.visible)
	assert_true(_main.world.player.movement_enabled)

func test_discard_confirm_cancel_stale_request_and_hotbar_remap() -> void:
	_main.inventory.deserialize({"capacity":40,"slots":[{"item_id":"turnip","quantity":3},{"item_id":"turnip_seed","quantity":7}]})
	_main.hotbar_panel.select_slot(1)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	var screen: LifeInventoryScreen = _main.inventory_panel.screen
	await _click(screen.detail.discard_button)
	assert_true(screen.discard.visible)
	await _key(KEY_ESCAPE)
	assert_true(_main.inventory_panel.visible)
	assert_false(screen.discard.visible)
	await _click(screen.detail.discard_button)
	_main.inventory.add_item(&"turnip",1)
	_main.inventory_panel.controller.confirm_discard(3)
	assert_eq(_main.inventory.get_quantity(&"turnip"),4,"Stale request cancelled on revision change")
	await _settle()
	await _click(screen.detail.discard_button)
	screen.discard.amount.value = 4
	await _settle()
	assert_eq(int(screen.discard.amount.value),4)
	await _click(screen.discard.confirm_button)
	assert_eq(_main.inventory.get_quantity(&"turnip"),0)
	assert_eq(_main.hotbar_panel.get_selected_slot()["item_id"],&"turnip_seed")
	assert_eq(_main.hotbar_panel.active_tool(),&"")
	assert_false(screen.discard.visible)

func test_reference_regions_both_languages_three_sizes_empty_full_filter_and_discard() -> void:
	_main.inventory_panel.toggle_inventory()
	var screen: LifeInventoryScreen = _main.inventory_panel.screen
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for extent: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			_viewport.size = extent
			for mode: String in ["empty","partial","full","filter","discard"]:
				_main.inventory.clear()
				_main.inventory_panel.controller.filter(&"")
				if mode!="empty":
					_main.inventory.add_item(&"spring_carrot_seed",19)
					_main.inventory.add_item(&"turnip",8)
				if mode=="full":
					_main.inventory.add_item(&"turnip",20*38+12)
				if mode=="filter":
					_main.inventory_panel.controller.filter(&"tool")
				await _settle()
				if mode=="discard":
					_main.inventory_panel.controller.request_discard()
					await _settle()
				var rect: Rect2 = _main.inventory_panel.get_global_rect()
				assert_true(Rect2(Vector2.ZERO,Vector2(extent)).encloses(rect),"Inventory fits %s %s %s %s" % [locale,extent,mode,rect])
				for control: Control in [screen.tabs,screen.filters,screen.items,screen.footer,screen.discard if mode=="discard" else screen.detail]:
					assert_true(rect.encloses(control.get_global_rect()),"Child fits: %s %s %s %s" % [control.get_class(),locale,extent,mode])
				assert_eq(screen.items.buttons.size(),40)
				assert_lte(screen.items.grid.get_combined_minimum_size().y,screen.items.size.y,"All five default rows are visible")
				assert_lte(screen.items.get_h_scroll_bar().max_value,screen.items.size.x+1)
				assert_false(screen.items.get_global_rect().intersects(screen.detail.get_global_rect()))
				await _capture("iso5_%s_%s_%d" % [locale,mode,extent.x])
			_main.inventory_panel.controller.cancel_discard()
			_main.inventory_panel.controller.show_tab(2)
			await _settle()
			assert_true(_main.npc_system.journal.visible)
			await _capture("iso5_%s_journal_%d" % [locale,extent.x])
			_main.inventory_panel.controller.show_tab(0)
			await _settle()

func _capture(filename: String) -> void:
	if DisplayServer.get_name()!="headless":
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://%s.png" % filename),OK)

func test_larger_legacy_inventory_keeps_extra_rows_reachable() -> void:
	var slots: Array[Dictionary] = []
	for index: int in range(60):
		slots.append({"item_id":"turnip_seed","quantity":index+1})
	_main.inventory.deserialize({"capacity":60,"slots":slots})
	_main.inventory_panel.toggle_inventory()
	await _settle()
	var items: LifeInventoryGrid = _main.inventory_panel.screen.items
	assert_eq(items.buttons.size(),60)
	assert_gt(items.get_v_scroll_bar().max_value,items.size.y)
	items.ensure_control_visible(items.buttons[59])
	await _settle()
	await _click(items.buttons[59])
	await _key(KEY_F)
	assert_eq(_main.hotbar_panel.get_selected_slot()["quantity"],60)
	assert_eq(_main.inventory.get_slots().size(),60)
