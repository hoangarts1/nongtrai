extends GutTest

var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	GameClock.deserialize({"day_index": 0, "minute": 720, "season": "spring", "year": 1})
	GameClock.paused = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(_viewport)

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _game() -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.world.player.move_to_cell(Vector2i(2, 2))
	return main

func _plant(main: Node, id: StringName = &"spring_carrot") -> Vector2i:
	var cell: Vector2i = Vector2i(2, 2)
	main.farm_state.till_cell(cell)
	main.farm_state.plant_crop(cell, id)
	return cell

func test_crop_click_opens_countdown_without_consuming_or_using_tool() -> void:
	var main: Node = _game()
	var cell: Vector2i = _plant(main)
	await _settle()
	var before: Dictionary = main.farm_state.serialize()
	var inventory: Dictionary = main.inventory.serialize()
	var point: Vector2 = main.world.grid.cell_to_screen(cell)
	await _click(point)
	assert_true(main.crop_inspector.visible, "Actual crop click opens readable panel")
	assert_eq(main.farm_state.serialize(), before, "Inspection does not water/harvest by accident")
	assert_eq(main.inventory.serialize(), inventory)
	assert_eq(main.crop_inspector.get_remaining_minutes(), 3960)
	assert_eq(main.crop_inspector.title_label.text, tr("CROP_SPRING_CARROT"))
	GameClock.advance_minutes(1)
	assert_eq(main.crop_inspector.get_remaining_minutes(), 3959)
	assert_true(main.crop_inspector.countdown_label.text.contains("59"), "Clock signal refreshes text each minute")
	assert_true(main.crop_inspector.note_label.text.contains(tr("UI_CROP_ESTIMATE_NOTE")))
	await _click(main.crop_inspector.action_button.get_global_rect().get_center())
	assert_true(bool(main.farm_state.get_plot(cell).get("watered", false)), "Water button reuses existing tool action")
	assert_true(main.crop_inspector.action_button.disabled)
	main.inventory_panel.toggle_inventory()
	assert_false(main.crop_inspector.visible, "Full modal dismisses crop card")
	main.inventory_panel.close_inventory()
	assert_false(main.crop_inspector.visible)
	await _settle()

func test_day_growth_updates_estimate_and_missed_watering_delays_it() -> void:
	var main: Node = _game()
	var cell: Vector2i = _plant(main)
	main.crop_inspector.show_cell(cell)
	main.farm_state.water_cell(cell)
	main.day_simulator.simulate_day(main.farm_state)
	GameClock.deserialize({"day_index": 1, "minute": 360})
	assert_eq(main.crop_inspector.get_remaining_minutes(), 2880)
	assert_eq(main.farm_state.get_growth_remaining(cell), 2)
	var expected: String = main.crop_inspector.estimate_label.text
	main.day_simulator.simulate_day(main.farm_state)
	GameClock.deserialize({"day_index": 2, "minute": 360})
	assert_eq(main.farm_state.get_growth_remaining(cell), 2, "No water means no extra growth")
	assert_ne(main.crop_inspector.estimate_label.text, expected, "Conditional harvest day moves after a missed watering")
	assert_eq(main.crop_inspector.get_remaining_minutes(), 2880)
	main.farm_state.water_cell(cell)
	main.day_simulator.simulate_day(main.farm_state)
	main.farm_state.water_cell(cell)
	main.day_simulator.simulate_day(main.farm_state)
	assert_eq(main.crop_inspector.countdown_label.text, tr("CROP_STATUS_READY"))
	assert_eq(main.crop_inspector.get_remaining_minutes(), 0)
	assert_false(main.crop_inspector.action_button.disabled)
	await _settle()
	await _click(main.crop_inspector.action_button.get_global_rect().get_center())
	assert_false(main.crop_inspector.visible, "Harvest removes the selected plant and closes its inspector")
	assert_eq(main.inventory.get_quantity(&"spring_carrot"), 2)

func test_inventory_selection_replaces_hidden_grid_and_closes_inventory() -> void:
	var main: Node = _game()
	main.inventory.clear()
	main.inventory.add_item(&"spring_carrot_seed", 4)
	main.inventory.add_item(&"spring_pea_seed", 2)
	main.inventory_panel.toggle_inventory()
	await _settle()
	var select: Button = main.inventory_panel.get("_list").get_child(1).get_node("SelectSlot_1")
	await _click(select.get_global_rect().get_center())
	assert_false(main.inventory_panel.visible)
	assert_eq(main.hotbar_panel.get_selected_slot()["item_id"], &"spring_pea_seed")
	assert_eq(main.tool_controller.get_selected_tool(), &"seed")
	assert_eq(main.inventory.get_quantity(&"spring_pea_seed"), 2)
	assert_false(main.hotbar_panel.get_node("MarginContainer/Content/HBoxContainer").visible)

func test_clicking_top_of_mature_crop_inspects_it_instead_of_adjacent_ground() -> void:
	var main: Node = _game()
	var cell: Vector2i = _plant(main, &"turnip")
	for day: int in range(2):
		main.farm_state.water_cell(cell)
		main.day_simulator.simulate_day(main.farm_state)
	await _settle()
	var crop: Sprite2D = main.farm_view.get_crop_view(cell)
	var point: Vector2 = crop.get_global_transform_with_canvas() * Vector2(0, -40)
	assert_eq(main.farm_view.pick_crop(point, main.world.camera), cell)
	await _click(point)
	assert_true(main.crop_inspector.visible)
	assert_eq(main.crop_inspector.countdown_label.text, tr("CROP_STATUS_READY"))
	assert_true(main.farm_state.can_harvest(cell), "Clicking to inspect is not an accidental harvest")

func test_withered_state_and_out_of_reach_actions_are_safe() -> void:
	var main: Node = _game()
	var cell: Vector2i = _plant(main)
	main.crop_inspector.show_cell(cell)
	main.world.player.move_to_cell(Vector2i(-8, -8))
	main.tool_controller.perform_crop_action(cell, &"water")
	assert_false(bool(main.farm_state.get_plot(cell).get("watered", false)))
	GameClock.deserialize({"day_index": 30, "minute": 720, "season": "summer"})
	main.farm_state.mark_out_of_season()
	assert_eq(main.crop_inspector.countdown_label.text, tr("CROP_STATUS_WITHERED"))
	assert_eq(main.crop_inspector.get_remaining_minutes(), 0)
	assert_true(main.crop_inspector.action_button.disabled)

func test_inspector_layout_at_all_resolutions_and_languages() -> void:
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			var main: Node = _game()
			var cell: Vector2i = _plant(main)
			await _settle()
			await _capture("compact_hud", locale, dimensions)
			main.crop_inspector.show_cell(cell)
			await _settle()
			var panel: CropInspector = main.crop_inspector
			assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(panel.get_global_rect()))
			assert_false(panel.get_global_rect().intersects(main.hotbar_panel.get_global_rect()))
			assert_false(panel.get_global_rect().intersects(main.quest_panel.get_global_rect()))
			for control: Control in [panel.title_label, panel.countdown_label, panel.estimate_label, panel.water_label, panel.note_label, panel.action_button]:
				assert_true(panel.get_global_rect().encloses(control.get_global_rect()), "Crop detail inside card: %s (%s %s)" % [control.name, locale, dimensions])
			assert_gte(panel.countdown_label.get_theme_font_size("font_size"), 24)
			await _capture("crop_inspector", locale, dimensions)
			main.free()

func _click(point: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _capture(mode: String, locale: String, dimensions: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	assert_eq(_viewport.get_texture().get_image().save_png("user://%s_%s_%dx%d.png" % [mode, locale, dimensions.x, dimensions.y]), OK)
