extends GutTest

var _clock: Dictionary
var _paused: bool
var _test_viewport: SubViewport
var _saved_slots: Dictionary = {}

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	for slot: int in [0, 1]:
		var path: String = "user://saves/slot_%d.json" % slot
		_saved_slots[slot] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	_test_viewport = SubViewport.new()
	_test_viewport.size = Vector2i(1152, 648)
	_test_viewport.own_world_3d = true
	_test_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(_test_viewport)

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	for slot: int in _saved_slots:
		var path: String = "user://saves/slot_%d.json" % slot
		if _saved_slots[slot] == null:
			SaveService.delete_save(slot)
		else:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(_saved_slots[slot])
			file.close()
	_saved_slots.clear()

func test_actual_mouse_clicks_reach_start_settings_and_new_game_buttons() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_test_viewport.add_child(main)
	main.start_menu.show()
	await _settle()
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		assert_eq(_test_viewport.get_texture().get_image().save_png("user://chibi_title_mouse_verified.png"), OK)
	var menu: Control = main.start_menu
	var buttons: Array[Button] = []
	_collect_buttons(menu, buttons)
	var settings: Button = _by_text(buttons, tr("UI_SETTINGS"))
	assert_not_null(settings)
	await _click(settings)
	assert_true((menu.get("_settings_box") as Control).visible, "Physical mouse event reaches Settings")
	await _click(_by_text(buttons, tr("UI_MAIN_NEW_GAME")))
	assert_true((menu.get("_name_box") as Control).visible, "Physical mouse event reaches New Game")
	assert_false((menu.get("_settings_box") as Control).visible)
	var confirm: Button = (menu.get("_name_box") as Node).get_node_or_null("ConfirmNewGame")
	assert_not_null(confirm)
	if confirm != null:
		# Keep test saves isolated; verify dispatch to the configured request callback.
		menu.configure(_record_start, Callable(), Callable())
		await _click(confirm)
		assert_eq(_start_requests, 1, "Confirm receives a real press/release, not pressed.emit")
		assert_false(menu.visible)

var _start_requests: int = 0

func _record_start(_player: String, _farm: String) -> void:
	_start_requests += 1

func test_mouse_clicks_work_after_switching_inventory_and_shop() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_test_viewport.add_child(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	await _settle()
	await _click(main.hud_button_bar.get_button(&"inventory"))
	assert_true(main.inventory_panel.visible, "HUD backpack receives mouse")
	var buttons: Array[Button] = []
	_collect_buttons(main.inventory_panel, buttons)
	await _click(buttons[0])
	assert_false(main.inventory_panel.visible, "Inventory close receives mouse")
	main.seed_shop_panel.open()
	await _settle()
	buttons.clear()
	_collect_buttons(main.seed_shop_panel, buttons)
	await _click(_by_text(buttons, tr("UI_CLOSE")))
	assert_false(main.seed_shop_panel.visible, "Shop close receives mouse above backdrop")
	assert_true(main.world.player.movement_enabled)

func test_continue_click_loads_autosave_when_only_slot_zero_exists() -> void:
	SaveService.save_game({"clock": {"day_index": 9, "minute": 720}, "wallet": {"coins": 321}, "profile": {"farm_name": "Mouse test"}}, 0)
	SaveService.delete_save(1)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_test_viewport.add_child(main)
	await _settle()
	assert_true(main.start_menu.visible, "Always enter through title screen")
	var buttons: Array[Button] = []
	_collect_buttons(main.start_menu, buttons)
	var resume: Button = _by_text(buttons, tr("UI_MAIN_CONTINUE"))
	assert_false(resume.disabled, "Slot zero is a valid continue source")
	await _click(resume)
	assert_false(main.start_menu.visible)
	assert_true(bool(main.get("_game_started")))
	assert_eq(GameClock.day_index, 9)
	assert_eq(main.wallet.get_coins(), 321)

func test_new_game_resets_old_world_and_hotbar_keys_choose_items() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_test_viewport.add_child(main)
	main.farm_state.till_cell(Vector2i(1, 1))
	main.wallet.add_coins(999, &"test")
	main.inventory.add_item(&"turnip", 8)
	GameClock.deserialize({"day_index": 56, "minute": 900, "season": "autumn", "year": 1})
	main.call("_start_new_game", "New", "New farm")
	await _settle()
	assert_eq(GameClock.day_index, 0)
	assert_eq(GameClock.season, &"spring")
	assert_true(main.farm_state.get_plot(Vector2i(1, 1)).is_empty())
	assert_eq(main.wallet.get_coins(), 100)
	assert_eq(main.inventory.get_quantity(&"turnip"), 0)
	assert_eq(main.inventory.get_quantity(&"turnip_seed"), 10)
	main.tutorial_panel.close_help()
	await _settle()
	var action: InputEventAction = InputEventAction.new()
	action.action = &"hotbar_1"
	action.pressed = true
	_test_viewport.push_input(action)
	assert_eq(main.hotbar_panel.get_selected_slot().get("item_id"), &"turnip_seed")

func test_icon_and_title_assets_are_present_and_translated() -> void:
	for id: String in UiIcons.ICON_IDS:
		var icon: Texture2D = UiIcons.get_icon(StringName(id))
		assert_not_null(icon, "Every declared icon resolves: %s" % id)
		var expected_size: Vector2 = Vector2(128, 128) if id in ["hoe", "watering_can", "seed", "harvest"] else Vector2(64, 64)
		assert_eq(icon.get_size(), expected_size, "C2 tool stickers are 128px; existing UI SVGs remain 64px: %s" % id)
	assert_not_null(preload("res://assets/ui/title_valley.png"))
	var keys: PackedStringArray = ["UI_TITLE_TAGLINE", "UI_TITLE_SAVE_SUMMARY", "UI_BIND_MOUSE_LEFT", "UI_BIND_TOOL_ALTERNATIVE", "UI_BIND_UP", "UI_BIND_DOWN", "UI_BIND_LEFT", "UI_BIND_RIGHT"]
	var paths: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]
	assert_true(DataValidator.validate_translation_keys(paths, keys).is_empty())

func _click(button: Button) -> void:
	if button == null:
		return
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	_test_viewport.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_test_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _collect_buttons(node: Node, result: Array[Button]) -> void:
	for child: Node in node.get_children():
		if child is Button:
			result.append(child as Button)
		_collect_buttons(child, result)

func _by_text(buttons: Array[Button], caption: String) -> Button:
	for button: Button in buttons:
		if button.text == caption:
			return button
	return null
