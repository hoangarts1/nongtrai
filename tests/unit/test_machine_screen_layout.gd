extends GutTest

const CELL: Vector2i = Vector2i(2, 3)
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
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game", "Mai", "Garden")
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

func test_shop_and_locked_matrix_keeps_two_rows_land_text_and_last_machine_reachable() -> void:
	_main.wallet.add_coins(DataRegistry.get_machine(&"stove").purchase_price * 8, &"test_layout")
	_main.machine_inventory.add_machine(&"stove", 1)
	var before: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in _sizes():
			_viewport.size = dimensions
			_panel.open()
			await _settle()
			_panel.screen.catalog.cards[0].grab_focus()
			_panel.controller.select(&"machine:stove")
			_panel.screen.catalog.scroll_vertical = 0
			await _settle()
			assert_eq(_panel.screen.catalog.cards.size(), 7)
			assert_false(_panel.screen.footer.buttons[&"buy"].disabled)
			assert_false(_panel.screen.footer.buttons[&"place"].disabled)
			assert_eq(_panel.screen.land_button.text, tr("LAND_TITLE"))
			assert_eq(_panel.screen.banner.caption.text, tr("UI_MACHINE_SHOP_TITLE"))
			_assert_layout(true)
			for index: int in range(2):
				assert_true(_panel.screen.catalog.get_global_rect().encloses(_panel.screen.catalog.cards[index].get_global_rect()))
			await _capture("%s_%d_shop" % [locale, dimensions.x])
			_panel.controller.select(&"machine:roaster")
			await _settle()
			var last: LifeMachineCard = _panel.screen.catalog.cards[-1]
			_panel.screen.catalog.ensure_control_visible(last)
			last.grab_focus()
			await _settle()
			assert_eq(_panel.controller.selected, &"roaster")
			assert_true(_panel.screen.footer.buttons[&"buy"].disabled)
			assert_true(_panel.screen.catalog.get_global_rect().grow(1).encloses(last.get_global_rect()), "%s %s last=%s catalog=%s" % [locale, dimensions, last.get_global_rect(), _panel.screen.catalog.get_global_rect()])
			_assert_layout(true)
			await _capture("%s_%d_locked" % [locale, dimensions.x])
	assert_eq(_owners(), before, "Selection, locale, resize and capture never transact")

func test_idle_working_ready_and_full_bag_matrix_reads_real_buffer_and_disabled_reasons() -> void:
	_main.machine_inventory.add_machine(&"stove", 1)
	assert_true(_main.machine_build.place(&"stove", CELL, 0).ok)
	await _operation_matrix("idle")
	var recipe: RecipeData = DataRegistry.get_recipe(&"stove_carrot_meal") as RecipeData
	for input: Dictionary in recipe.input_entries():
		_main.inventory.add_item(StringName(input.item_id), int(input.quantity))
	assert_true(_main.machine_operations.start(CELL, recipe.recipe_id, recipe.unlock_house_level).ok)
	await _operation_matrix("working")
	for day: int in range(recipe.duration_days):
		_main.machine_operations.advance_day()
	await _operation_matrix("ready")
	var item: ItemData = DataRegistry.get_item(&"turnip") as ItemData
	_main.inventory.add_item(item.item_id, item.max_stack * _main.inventory.capacity)
	assert_eq(_main.machine_operations.can_collect_output(CELL).reason, &"inventory_full")
	await _operation_matrix("fullbag")
	var before: Dictionary = _owners()
	_panel.controller.request(&"collect")
	await _settle()
	assert_eq(_panel.controller.result.reason, &"inventory_full")
	assert_eq(_owners(), before)

func test_long_detail_and_feedback_remain_scrollable_and_fully_readable_in_both_locales() -> void:
	var before: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in _sizes():
			_viewport.size = dimensions
			_panel.open()
			await _settle()
			var title: String = tr("MACHINE_ROASTER_NAME").repeat(48)
			var feedback: String = tr("UI_MACHINE_COLLECT_FULL").repeat(3)
			_panel.screen.details.title.text = title
			_panel.screen.footer.result.text = feedback
			await _settle()
			_assert_layout(true)
			assert_eq(_panel.screen.details.title.text, title)
			assert_eq(_panel.screen.footer.result.text, feedback)
			assert_gte(_panel.screen.footer.result.size.y, float(_panel.screen.footer.result.get_line_count() * _panel.screen.footer.result.get_line_height()))
			_panel.screen.details.ensure_control_visible(_panel.screen.details.terms)
			await _settle()
			assert_gt(_panel.screen.details.scroll_vertical, 0)
			assert_true(_panel.screen.details.get_global_rect().grow(1).encloses(_panel.screen.details.terms.get_global_rect()))
			await _capture("%s_%d_long" % [locale, dimensions.x])
	assert_eq(_owners(), before)

func test_header_aliases_and_native_focus_survive_resize_locale_and_deferred_refresh() -> void:
	_panel.open()
	await _settle()
	assert_eq(_panel.screen.banner, _panel.screen.header.banner)
	assert_eq(_panel.screen.land_button, _panel.screen.header.land_button)
	assert_eq(_panel.screen.close_button, _panel.screen.header.close_button)
	var before: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in _sizes():
			_viewport.size = dimensions
			await _settle()
			var card: LifeMachineCard = _panel.screen.catalog.cards[-1]
			_panel.screen.catalog.ensure_control_visible(card)
			await _settle()
			await _click(card)
			var focused: Control = _viewport.gui_get_focus_owner()
			var scroll: int = _panel.screen.catalog.scroll_vertical
			_panel.controller.queue_refresh()
			await _settle()
			assert_eq(_viewport.gui_get_focus_owner(), focused)
			assert_eq(_panel.screen.catalog.cards[-1], card)
			assert_eq(_panel.screen.catalog.scroll_vertical, scroll)
			assert_eq(_panel.controller.selected, &"roaster")
			await _key(KEY_TAB)
			assert_true(_panel.visible)
			assert_false(_main.inventory_panel.visible)
			await _click(_panel.screen.close_button)
			assert_false(_panel.visible)
			assert_true(_main.world.player.movement_enabled)
			_panel.open()
			await _settle()
	assert_eq(_owners(), before)
	await _click(_panel.screen.land_button)
	assert_false(_panel.visible)
	assert_true(_main.land_runtime.panel.visible)
	assert_eq(_owners(), before, "The header's real land entry does not purchase land")

func _operation_matrix(tag: String) -> void:
	var before: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in _sizes():
			_viewport.size = dimensions
			_panel.open_machine(CELL)
			await _settle()
			_assert_layout(false)
			assert_eq(_panel.screen.banner.caption.text, tr("MUI_OPERATION_TITLE"))
			assert_false(_panel.screen.land_button.visible)
			assert_true(_panel.screen.footer.buttons[&"collect"].disabled != (tag == "ready"))
			if tag in ["ready", "fullbag"]:
				assert_true(_panel.screen.details.output.visible)
				assert_true(_panel.screen.details.get_global_rect().encloses(_panel.screen.details.output.get_global_rect()))
				assert_true(_panel.screen.details.output.text.contains(str(_main.machine_operations.get_state(CELL).output_quantity)))
			if tag == "fullbag":
				assert_eq(_panel.screen.footer.buttons[&"collect"].tooltip_text, tr("UI_MACHINE_COLLECT_FULL"))
			if tag == "working":
				assert_true(_panel.screen.footer.buttons[&"move"].disabled)
				assert_true(_panel.screen.footer.buttons[&"return"].disabled)
			await _capture("%s_%d_%s" % [locale, dimensions.x, tag])
	assert_eq(_owners(), before, tag + " layout reads actual owners without advancing time")

func _assert_layout(shop: bool) -> void:
	var screen: LifeMachineScreen = _panel.screen
	var bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(_viewport.size)).grow(1)
	assert_true(bounds.encloses(_panel.get_global_rect()))
	assert_lte(screen.header.size.y, _panel.size.y * 0.2)
	assert_gte(screen.body.size.y, 240.0)
	assert_lte(screen.header.get_global_rect().end.y, screen.body.get_global_rect().position.y)
	assert_lte(screen.body.get_global_rect().end.y, screen.footer.get_global_rect().position.y)
	assert_true(screen.body.get_global_rect().grow(1).encloses(screen.details.get_global_rect()))
	assert_true(screen.body.get_global_rect().grow(1).encloses(screen.catalog.get_global_rect()))
	assert_false(screen.details.get_global_rect().intersects(screen.catalog.get_global_rect()))
	assert_true(bounds.encloses(screen.footer.get_global_rect()))
	assert_eq(screen.close_button.text, tr("UI_CLOSE"))
	assert_gte(screen.close_button.size.y, 44.0)
	if shop:
		assert_true(screen.land_button.visible)
		assert_gte(screen.land_button.size.x, screen.land_button.get_combined_minimum_size().x)
		assert_gte(screen.land_button.size.y, 44.0)
		assert_false(screen.banner.get_global_rect().intersects(screen.land_button.get_global_rect()))
	var visible_buttons: Array[Button] = []
	for button: Button in screen.footer.buttons.values():
		if button.visible:
			assert_true(bounds.encloses(button.get_global_rect()))
			assert_false(button.text.is_empty())
			for previous: Button in visible_buttons:
				assert_false(button.get_global_rect().intersects(previous.get_global_rect()))
			visible_buttons.append(button)

func _sizes() -> Array[Vector2i]:
	return [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]

func _owners() -> Dictionary:
	return {"clock": GameClock.serialize(), "farm": _main.farm_state.serialize(), "wallet": _main.wallet.serialize(), "bag": _main.inventory.serialize(), "water": _main.watering_can.serialize(), "coop": _main.chicken_coop.serialize(), "weather": _main.weather_state.serialize(), "ledger": _main.day_end_flow.ledger.serialize(), "machines": _main.machine_operations.serialize(), "stock": _main.machine_inventory.serialize(), "placements": _main.machine_placements.serialize()}

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

func _capture(suffix: String) -> void:
	if DisplayServer.get_name() != "headless":
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://audit_f3_%s.png" % suffix), OK)

func _click(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()
