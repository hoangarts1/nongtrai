extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]
var _clock: Dictionary
var _pause: bool

func before_each() -> void:
	_clock = GameClock.serialize()
	_pause = GameClock.paused

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _pause

func _game() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	add_child(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.world.player.movement_enabled = true
	return main

func test_hud_regions_are_inside_viewport_and_do_not_overlap() -> void:
	for viewport_size: Vector2i in SIZES:
		get_tree().root.size = viewport_size
		get_viewport().size = viewport_size
		var main: Node = _game()
		await get_tree().process_frame
		await get_tree().process_frame
		var controls: Array[Control] = [main.get_node("ClockHud"), main.weather_hud, main.wallet_hud, main.quest_panel, main.hotbar_panel, main.hud_button_bar, main.world.interaction_prompt]
		for control: Control in controls:
			assert_true(Rect2(Vector2.ZERO, main.get_viewport().get_visible_rect().size).encloses(control.get_global_rect()), "%s fits %s" % [control.name, viewport_size])
		for first: int in range(controls.size()):
			for second: int in range(first + 1, controls.size()):
				assert_false(controls[first].get_global_rect().intersects(controls[second].get_global_rect()), "HUD overlap: %s / %s" % [controls[first].name, controls[second].name])
		assert_gte(main.hotbar_panel.get_theme_default_font_size(), 18)
		main.free()

func test_every_modal_has_readable_content_and_visible_controls_at_three_sizes() -> void:
	var locale_before: String = TranslationServer.get_locale()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for viewport_size: Vector2i in SIZES:
			get_tree().root.size = viewport_size
			get_viewport().size = viewport_size
			var main: Node = _game()
			main.inventory.clear()
			for item: Resource in DataRegistry.get_seed_items():
				main.inventory.add_item(item.get("item_id"), 5)
			main.inventory.add_item(&"turnip", 3)
			await get_tree().process_frame
			await _capture(main, "hud", locale, viewport_size)
			var panels: Array[Control] = [main.inventory_panel, main.pause_menu, main.debug_menu, main.tutorial_panel, main.seed_shop_panel, main.shipping_bin_panel, main.start_menu]
			for panel: Control in panels:
				if panel == main.inventory_panel:
					main.inventory_panel.toggle_inventory()
				elif panel == main.pause_menu or panel == main.seed_shop_panel or panel == main.shipping_bin_panel:
					panel.call("open")
				elif panel == main.tutorial_panel:
					main.tutorial_panel.open_help()
				else:
					panel.show()
				await get_tree().process_frame
				await get_tree().process_frame
				assert_true(panel.visible, "Requested modal stays open")
				assert_eq(main.ui_coordinator.get_active_panel(), panel)
				assert_false(main.hotbar_panel.visible)
				assert_false(main.world.interaction_prompt.visible)
				assert_false(main.world.player.movement_enabled)
				assert_true(Rect2(Vector2.ZERO, main.get_viewport().get_visible_rect().size).encloses(panel.get_global_rect()), "%s fits viewport: %s" % [panel.name, panel.get_global_rect()])
				for other: Control in panels:
					if other != panel:
						assert_false(other.visible, "Only one modal is visible")
				_check_buttons(panel, panel)
				if panel == main.pause_menu:
					panel.call("_toggle_settings")
					await get_tree().process_frame
					await get_tree().process_frame
					_check_buttons(panel, panel)
				if panel == main.start_menu:
					panel.call("_toggle_settings")
					await get_tree().process_frame
					_check_buttons(panel, panel)
					panel.call("_show_new_game_fields")
					panel.call("_show_new_game_fields")
					await get_tree().process_frame
					_check_buttons(panel, panel)
					assert_eq(panel.get("_name_box").get_child_count(), 3, "Repeated New Game does not duplicate its confirm button")
				await _capture(main, String(panel.name), locale, viewport_size)
				if panel == main.start_menu:
					panel.hide()
				else:
					main.ui_coordinator.close_active()
			main.free()
	TranslationServer.set_locale(locale_before)

func test_modal_shortcuts_replace_each_other_and_escape_closes_only_one() -> void:
	var main: Node = _game()
	await get_tree().process_frame
	for action: StringName in [&"open_inventory", &"toggle_debug_menu", &"open_help", &"open_journal"]:
		_push(action)
		await get_tree().process_frame
		var active: Control = main.ui_coordinator.get_active_panel()
		assert_not_null(active)
		assert_true(active.visible)
		assert_false(main.world.player.movement_enabled)
	_push(&"pause")
	await get_tree().process_frame
	assert_null(main.ui_coordinator.get_active_panel())
	assert_false(main.pause_menu.visible)
	assert_true(main.world.player.movement_enabled)
	main.seed_shop_panel.open()
	_push(&"interact")
	assert_false(main.seed_shop_panel.visible, "E still closes the shop")
	main.start_menu.show()
	_push(&"open_inventory")
	assert_true(main.start_menu.visible, "Start menu cannot be bypassed by gameplay keys")
	assert_false(main.inventory_panel.visible)
	main.free()

func _check_buttons(node: Node, panel: Control) -> void:
	for child: Node in node.get_children():
		if child is ScrollContainer:
			continue
		if child is Button and (child as Button).is_visible_in_tree():
			var button: Button = child as Button
			assert_true(panel.get_global_rect().encloses(button.get_global_rect()), "Visible button fits panel: %s / %s" % [panel.name, button.text])
			assert_gte(button.size.y, 36.0, "Readable button height")
		_check_buttons(child, panel)

func _push(action: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	get_viewport().push_input(event)

func _capture(main: Node, mode: String, locale: String, viewport_size: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var screenshot: Image = main.get_viewport().get_texture().get_image()
	assert_eq(screenshot.save_png("user://ui_repair_%s_%s_%dx%d.png" % [mode, locale, viewport_size.x, viewport_size.y]), OK)
