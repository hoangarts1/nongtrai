extends GutTest

func test_exact_control_m_is_distinct_from_map_and_additional_modifiers() -> void:
	var event: InputEventKey = _key()
	assert_true(MachineShopShortcut.matches(event, true))
	assert_false(event.is_action(&"open_map", true))
	event.ctrl_pressed = false
	assert_false(MachineShopShortcut.matches(event, true))
	assert_true(event.is_action(&"open_map", true))
	event.ctrl_pressed = true
	for modifier: StringName in [&"shift_pressed", &"alt_pressed", &"meta_pressed"]:
		event.set(modifier, true)
		assert_false(MachineShopShortcut.matches(event, true), String(modifier))
		event.set(modifier, false)
	assert_true(MachineShopShortcut.matches(event, true))

func test_release_echo_and_release_build_flag_cannot_request_the_debug_action() -> void:
	var event: InputEventKey = _key()
	assert_false(MachineShopShortcut.matches(event, false))
	assert_false(MachineShopShortcut.matches(null, true))
	event.pressed = false
	assert_false(MachineShopShortcut.matches(event, true))
	event.pressed = true
	event.echo = true
	assert_false(MachineShopShortcut.matches(event, true))
	event.echo = false
	assert_true(MachineShopShortcut.matches(event, true))

func test_physical_binding_and_explicit_action_compatibility_preserve_the_input_map() -> void:
	var before: Array[InputEvent] = InputMap.action_get_events(&"toggle_debug_menu")
	assert_eq(before.size(), 1)
	var configured: InputEventKey = before[0] as InputEventKey
	assert_eq(configured.physical_keycode, KEY_M)
	assert_true(configured.ctrl_pressed)
	var original: String = configured.as_text()
	var event: InputEventKey = _key()
	event.keycode = KEY_NONE
	assert_true(MachineShopShortcut.matches(event, true), "Physical M remains the binding")
	event.keycode = KEY_M
	event.physical_keycode = KEY_N
	assert_false(MachineShopShortcut.matches(event, true), "Logical M does not override a different physical key")
	var action: InputEventAction = InputEventAction.new()
	action.action = &"toggle_debug_menu"
	action.pressed = true
	assert_true(MachineShopShortcut.matches(action, true), "Existing explicit logical test/action requests remain compatible")
	assert_false(MachineShopShortcut.matches(action, false))
	action.action = &"open_map"
	assert_false(MachineShopShortcut.matches(action, true))
	assert_eq(InputMap.action_get_events(&"toggle_debug_menu")[0].as_text(), original)

func _key() -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_M
	event.physical_keycode = KEY_M
	event.ctrl_pressed = true
	event.pressed = true
	return event
