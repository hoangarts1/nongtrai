extends GutTest

const VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1920, 1080)
]

var _clock: Dictionary
var _paused: bool
var _mouse_mode: int

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_mouse_mode = Input.get_mouse_mode()

func after_each() -> void:
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Input.set_mouse_mode(_mouse_mode)

func test_cursor_exposes_paw_ui_pressed_and_tool_modes() -> void:
	var cursor: ChibiCursor = ChibiCursor.new()
	add_child_autofree(cursor)
	await get_tree().process_frame
	assert_eq(cursor.get_visual_mode(), &"world")
	cursor.set_tool_mode(&"watering_can")
	assert_eq(cursor.get_tool_mode(), &"watering_can")
	assert_eq(cursor.get_visual_mode(), &"watering_can")
	cursor.set_ui_hovered(true)
	assert_eq(cursor.get_visual_mode(), &"ui")
	cursor.set_pressed(true)
	assert_eq(cursor.get_visual_mode(), &"pressed")
	cursor.set_pressed(false)
	cursor.set_ui_hovered(false)
	assert_eq(cursor.get_visual_mode(), &"watering_can")

func test_motion_wires_real_tool_click_focus_and_native_tooltip_theme() -> void:
	var viewport: SubViewport = _new_viewport(Vector2i(1152, 648))
	var main: Node = _new_game(viewport)
	main.start_menu.hide()
	main.set("_game_started", true)
	main.tutorial_panel.close_help()
	await _settle()
	var motion: ChibiUiMotion = main.chibi_ui_motion
	assert_not_null(motion)
	assert_not_null(motion.get_cursor())
	assert_not_null(main.hotbar_panel.theme.get_stylebox("panel", "TooltipPanel"))
	var tool: Button = main.hotbar_panel.get_node("MarginContainer/Content/ToolRow/Tool_hoe") as Button
	assert_not_null(tool)
	assert_eq(tool.focus_mode, Control.FOCUS_ALL)
	assert_false(tool.tooltip_text.is_empty())
	await _move(viewport, tool.get_global_rect().get_center())
	assert_gt(tool.scale.x, 1.0, "Hover receives the small chibi bounce")
	await _click(viewport, tool)
	assert_eq(motion.get_cursor().get_tool_mode(), &"hoe", "A real tool click updates only cursor presentation")
	assert_true(tool.has_focus(), "Mouse/keyboard focus remains on the real Godot Button")

func test_title_focus_and_compact_hud_remain_safe_at_three_sizes() -> void:
	for viewport_size: Vector2i in VIEWPORT_SIZES:
		var viewport: SubViewport = _new_viewport(viewport_size)
		var main: Node = _new_game(viewport)
		await _settle()
		var new_game: Button = main.start_menu.get_node("MarginContainer/Column/NewGame") as Button
		assert_true(new_game.has_focus(), "Title primary action has keyboard focus at %s" % viewport_size)
		main.start_menu.hide()
		main.set("_game_started", true)
		main.tutorial_panel.close_help()
		await _settle()
		assert_lte(main.hotbar_panel.size.x, 260.0)
		assert_lte(main.hotbar_panel.size.y, 64.0)
		assert_lte(main.hud_button_bar.size.x, 232.0)
		assert_lte(main.hud_button_bar.size.y, 64.0)
		assert_true(Rect2(Vector2.ZERO, viewport.get_visible_rect().size).encloses(main.hotbar_panel.get_global_rect()))
		assert_true(Rect2(Vector2.ZERO, viewport.get_visible_rect().size).encloses(main.hud_button_bar.get_global_rect()))
		main.queue_free()
		await get_tree().process_frame

func _new_viewport(viewport_size: Vector2i) -> SubViewport:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = viewport_size
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(viewport)
	return viewport

func _new_game(viewport: SubViewport) -> Node:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	return main

func _move(viewport: SubViewport, position: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	viewport.push_input(motion, true)
	await _settle()

func _click(viewport: SubViewport, button: Button) -> void:
	var position: Vector2 = button.get_global_rect().get_center()
	await _move(viewport, position)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = position
		event.global_position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	for frame_index: int in range(6):
		await get_tree().process_frame
