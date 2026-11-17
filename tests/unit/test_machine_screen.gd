extends GutTest

var _main: Node
var _viewport: SubViewport
var _panel: MachineShopPanel
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
	_main.call("_start_new_game","Mai","Vườn Máy")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true
	_panel = _main.machine_shop_panel as MachineShopPanel

func after_each() -> void:
	_viewport.free()
	TranslationServer.set_locale(_locale)
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	SaveService.delete_save(1)

func test_native_purchase_place_process_save_load_collect_and_reset_use_real_owners() -> void:
	_panel.open()
	await _settle()
	assert_eq(_panel.controller.selected,&"stove")
	assert_true(_button(&"buy").disabled)
	var before: Dictionary = _owners()
	_panel.controller.request(&"buy")
	await _settle()
	assert_eq(_panel.controller.result.reason,&"insufficient_coins")
	assert_eq(_owners(),before)
	assert_eq(_panel._status.text,tr("MUI_NO_COINS"))
	await _choose(&"machine:roaster")
	assert_true(_button(&"buy").disabled)
	_panel.controller.request(&"buy")
	await _settle()
	assert_eq(_panel.controller.result.reason,&"house_level_locked")
	assert_eq(_owners(),before)
	await _choose(&"machine:stove")
	var price: int = DataRegistry.get_machine(&"stove").purchase_price
	_main.wallet.add_coins(price,&"test_machine_ui")
	await _settle()
	var coins: int = _main.wallet.get_coins()
	_main.wallet.coins_changed.connect(func(_total: int, _delta: int, reason: StringName) -> void:
		if reason==&"buy_machine":
			_panel.controller.request(&"buy")
	)
	_button(&"buy").grab_focus()
	await _key(KEY_SPACE)
	assert_eq(_main.wallet.get_coins(),coins-price,"Native Space spends exactly once despite wallet callback reentry")
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),1)
	assert_eq(_panel.controller.result.reason,&"purchased")
	await _click(_button(&"place"))
	assert_true(_main.machine_placement_flow.active)
	assert_eq(_main.machine_placements.get_all_placements().size(),0,"Opening placement does not commit")
	var point: Vector2 = _main.world.grid.cell_to_screen(Vector2i(2,3))
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	await _settle()
	await _click(_main.machine_placement_flow.panel.status.confirm_button)
	assert_eq(_main.machine_inventory.get_quantity(&"stove"),0)
	var placements: Array = _main.machine_placements.get_all_placements()
	assert_eq(placements.size(),1)
	var cell: Vector2i = placements[0].cell
	_main.machine_shop_panel.open()
	await _settle()
	await _choose(StringName("placement:%s" % cell))
	assert_true(_panel._machine_mode)
	assert_eq(_panel._machine_cell,cell)
	assert_true(_button(&"start").disabled)
	assert_eq(_button(&"start").tooltip_text,tr("MUI_MISSING_INPUT"))
	before = _owners()
	_panel.controller.request(&"start")
	await _settle()
	assert_eq(_panel.controller.result.reason,&"missing_input")
	assert_eq(_owners(),before,"Disabled Start preserves every owner, including absent jobs")
	_main.inventory.add_item(&"carrot",2)
	await _settle()
	assert_false(_button(&"start").disabled)
	_button(&"start").grab_focus()
	await _key(KEY_ENTER)
	assert_eq(_main.inventory.get_quantity(&"carrot"),0)
	assert_eq(_main.machine_operations.get_state(cell).status,MachineState.STATUS_WORKING)
	assert_eq(_panel._status.text,tr("MUI_STARTED"))
	assert_true(_button(&"start").disabled)
	assert_true(_button(&"collect").disabled)
	var art: Array[Node] = (_main.machine_presentation.get("_root") as Node).find_children("*","Sprite2D",true,false)
	assert_true((art[0] as Sprite2D).texture.resource_path.contains("work_a"))
	await _capture("working")
	_panel.close()
	_main.machine_operations.advance_day()
	_panel.open_machine(cell)
	await _settle()
	assert_false(_button(&"collect").disabled)
	assert_true(_main.call("_save_game_to_slot",1))
	var payload: Dictionary = SaveService.load_game(1)
	_main.call("_load_payload",payload)
	await _settle()
	assert_false(_panel.visible,"Loading resets transient operation selection")
	assert_false(_panel._machine_mode)
	assert_eq(_panel.controller.selected,&"")
	_panel.open_machine(cell)
	await _settle()
	var day: int = GameClock.day_index
	coins = _main.wallet.get_coins()
	await _click(_button(&"collect"))
	assert_eq(_main.inventory.get_quantity(&"temp_carrot_meal"),1)
	assert_eq(_main.machine_operations.get_state(cell).output_quantity,0)
	assert_eq(_panel.controller.result.reason,&"collected")
	art = (_main.machine_presentation.get("_root") as Node).find_children("*","Sprite2D",true,false)
	assert_true((art[0] as Sprite2D).texture.resource_path.contains("idle"))
	before = _owners()
	await _key(KEY_ESCAPE)
	assert_false(_panel.visible)
	assert_true(_main.world.player.movement_enabled)
	_panel.controller.request(&"collect")
	assert_eq(_owners(),before,"Hidden controls cannot execute stale commands")
	assert_eq(GameClock.day_index,day)
	assert_eq(_main.wallet.get_coins(),coins)
	_panel.open_machine(cell)
	await _settle()
	_main.call("_start_new_game","Lan","Vườn mới")
	await _settle()
	assert_false(_panel.visible)
	assert_eq(_panel.controller.selected,&"")
	assert_eq(_main.machine_placements.get_all_placements().size(),0)

func test_reference10_layout_locales_scroll_long_text_and_selection_do_not_transact() -> void:
	_main.wallet.add_coins(2000,&"test_machine_ui")
	_main.machine_inventory.add_machine(&"stove",2)
	var before: Dictionary = _owners()
	_panel.open()
	await _settle()
	assert_eq(_panel.screen.catalog.cards.size(),7)
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			_viewport.size = dimensions
			await _settle()
			await _choose(&"machine:stove")
			assert_eq(_panel.screen.details.title.text,tr("MACHINE_STOVE_NAME"))
			assert_false(_button(&"buy").disabled)
			assert_false(_button(&"place").disabled)
			for card: LifeMachineCard in _panel.screen.catalog.cards:
				assert_false(card.caption.text.contains("MACHINE_"))
				assert_not_null(card.image.texture)
			await _capture("%s_%d_shop" % [locale,dimensions.x])
			await _choose(&"machine:roaster")
			assert_eq(_panel.controller.selected,&"roaster")
			assert_true(_button(&"buy").disabled)
			var scroll: int = _panel.screen.catalog.scroll_vertical
			var focused: Control = _viewport.gui_get_focus_owner()
			_panel.controller.queue_refresh()
			await _settle()
			assert_eq(_panel.screen.catalog.scroll_vertical,scroll)
			assert_eq(_viewport.gui_get_focus_owner(),focused)
			assert_gt(scroll,0,"Last machine is accessible through catalogue scroll")
			assert_true(_panel.screen.tabs[1].disabled)
			assert_true(_panel.screen.tabs[2].disabled)
			await _capture("%s_%d_locked" % [locale,dimensions.x])
		_viewport.size = Vector2i(1152,648)
		await _settle()
		_panel.screen.details.title.text = tr("MACHINE_ROASTER_NAME").repeat(12)
		_panel.screen.footer.result.text = tr("UI_MACHINE_COLLECT_FULL").repeat(3)
		await _settle()
		await _capture(locale+"_long")
	assert_eq(_owners(),before,"Selection/scroll/locale/layout changes are read-only")
	await _key(KEY_TAB)
	assert_true(_panel.visible,"Tab navigates the machine GUI, not the bag shortcut")
	assert_false(_main.inventory_panel.visible)
	assert_false(_main.world.player.movement_enabled)
	await _key(KEY_ESCAPE)
	assert_true(GameClock.paused,"Original hold survives the modal")

func _button(action: StringName) -> Button:
	return _panel.screen.footer.buttons[action] as Button

func _owners() -> Dictionary:
	return {"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"owned":_main.machine_inventory.serialize(),"placed":_main.machine_placements.serialize(),"jobs":_main.machine_operations.serialize(),"farm":_main.farm_state.serialize(),"clock":GameClock.serialize()}

func _choose(key: StringName) -> void:
	for card: LifeMachineCard in _panel.screen.catalog.cards:
		if StringName(card.get_meta(&"machine_action"))==key:
			_panel.screen.catalog.ensure_control_visible(card)
			await _settle()
			await _click(card)
			return
	fail_test("Catalogue row missing: "+String(key))

func _settle() -> void:
	var previous: Array[Vector4] = []
	var stable: int = 0
	for frame: int in range(24):
		await get_tree().process_frame
		var current: Array[Vector4] = []
		_sample_layout(_panel.screen, current)
		stable = stable + 1 if current == previous else 0
		if stable >= 3:
			return
		previous = current
	fail_test("Machine minimum-size/rectangle layout did not converge within 24 frames")

func _sample_layout(node: Node, values: Array[Vector4]) -> void:
	if node is Control:
		var control: Control = node as Control
		var rect: Rect2 = control.get_global_rect()
		var minimum: Vector2 = control.get_combined_minimum_size()
		values.append(Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))
		values.append(Vector4(minimum.x, minimum.y, float(control.visible), 0.0))
	for child: Node in node.get_children():
		_sample_layout(child, values)

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _click(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
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

func _capture(suffix: String) -> void:
	await _settle()
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(_viewport.size)).grow(1)
	assert_true(bounds.encloses(_panel.get_global_rect()))
	assert_true(bounds.encloses(_panel.screen.footer.get_global_rect()))
	assert_true(bounds.encloses(_panel.screen.close_button.get_global_rect()))
	assert_almost_eq(_panel.get_global_rect().get_center(),Vector2(_viewport.size)/2.0,Vector2.ONE)
	assert_lte(_panel.screen.header.size.y, _panel.size.y * 0.2)
	assert_gte(_panel.screen.body.size.y, 240.0)
	assert_lte(_panel.screen.header.get_global_rect().end.y, _panel.screen.body.get_global_rect().position.y)
	assert_lte(_panel.screen.body.get_global_rect().end.y, _panel.screen.footer.get_global_rect().position.y)
	for button: Button in _panel.screen.footer.buttons.values():
		if button.visible:
			assert_true(bounds.encloses(button.get_global_rect()))
	if DisplayServer.get_name()!="headless":
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://phase65c_%s.png" % suffix),OK)
