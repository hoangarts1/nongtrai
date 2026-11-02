extends GutTest

var _viewport: SubViewport
var _locale: String
var _paused: bool

func before_each() -> void:
	_locale = TranslationServer.get_locale()
	_paused = GameClock.paused
	GameClock.paused = true
	TranslationServer.set_locale("vi")
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(800,500)
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(_viewport)

func after_each() -> void:
	TranslationServer.set_locale(_locale)
	GameClock.paused = _paused

func _component(id: String) -> Control:
	var scene: PackedScene = load("res://ui/components/%s.tscn" % id) as PackedScene
	var component: Control = scene.instantiate() as Control
	_viewport.add_child(component)
	component.position = Vector2(40,40)
	return component

func test_native_buttons_emit_real_clicks_and_preview_states_do_not_mutate_theme() -> void:
	var button: LifeButtonBase = _component("btn_primary") as LifeButtonBase
	button.size = Vector2(220,52)
	button.set_caption(&"UI_CONTINUE")
	watch_signals(button)
	await _settle()
	var original: Color = (LifeTheme.get_theme().get_stylebox(&"normal",&"LifePrimary") as StyleBoxFlat).bg_color
	await _click(button.get_global_rect().get_center())
	assert_signal_emitted(button,"pressed")
	button.set_preview_state(&"hover")
	assert_eq(button.theme_type_variation,&"LifePrimaryPreviewHover")
	button.set_preview_state(&"pressed")
	assert_eq(button.theme_type_variation,&"LifePrimaryPreviewPressed")
	button.set_preview_state(&"disabled")
	assert_true(button.disabled)
	assert_eq((LifeTheme.get_theme().get_stylebox(&"normal",&"LifePrimary") as StyleBoxFlat).bg_color,original)

func test_slot_empty_selected_locked_and_quantity_are_view_only() -> void:
	var slot: LifeItemSlot = _component("item_slot") as LifeItemSlot
	var inventory: InventoryState = InventoryState.new()
	inventory.add_item(&"spring_carrot",7)
	var before: Dictionary = inventory.serialize()
	watch_signals(slot)
	assert_eq(slot.state,LifeItemSlot.SlotState.EMPTY)
	slot.set_item(&"spring_carrot",7,&"ITEM_SPRING_CARROT")
	slot.set_state(LifeItemSlot.SlotState.SELECTED)
	assert_eq(slot.theme_type_variation,&"LifeItemSlotSelected")
	var quantity_label: Label = slot.get_node("QuantityInset/Quantity") as Label
	assert_eq(quantity_label.text,"7")
	await _settle()
	await _click(slot.get_global_rect().get_center())
	assert_signal_emitted_with_parameters(slot,"slot_requested",[&"spring_carrot"])
	assert_lte(quantity_label.get_global_rect().end.x,slot.get_global_rect().end.x-5)
	slot.set_state(LifeItemSlot.SlotState.LOCKED)
	assert_true(slot.disabled)
	assert_eq((slot.get_node("Lock") as Label).text,tr("UI_KIT_LOCKED"))
	var requests: int = get_signal_emit_count(slot,"slot_requested")
	await _click(slot.get_global_rect().get_center())
	assert_eq(get_signal_emit_count(slot,"slot_requested"),requests,"Locked slot cannot submit an inventory request")
	assert_eq(inventory.serialize(),before)
	slot.set_item(&"",0,&"UI_KIT_EMPTY")
	assert_eq(slot.state,LifeItemSlot.SlotState.EMPTY)

func test_toggle_slider_tabs_and_integer_coin_localization() -> void:
	var toggle: LifeToggle = _component("toggle_on_off") as LifeToggle
	toggle.size = Vector2(180,48)
	watch_signals(toggle)
	await _settle()
	await _click(toggle.get_global_rect().get_center())
	assert_true(toggle.button_pressed)
	assert_eq(toggle.text,"BẬT")
	assert_signal_emitted(toggle,"toggled")
	toggle.hide()
	var slider: LifeSlider = _component("slider_styled") as LifeSlider
	watch_signals(slider)
	slider.value = 70
	assert_eq(slider.value,70.0)
	assert_signal_emitted(slider,"value_changed")
	slider.hide()
	var tabs: LifeTabBar = _component("tab_bar") as LifeTabBar
	tabs.size = Vector2(700,52)
	watch_signals(tabs)
	await _settle()
	await _click(tabs.buttons[4].get_global_rect().get_center())
	assert_eq(tabs.active,4)
	assert_signal_emitted_with_parameters(tabs,"tab_requested",[4])
	tabs.hide()
	var coins: LifeCoinLabel = _component("coin_label") as LifeCoinLabel
	coins.set_coins(1240)
	assert_eq(coins.amount.text,"1.240 xu")
	TranslationServer.set_locale("en")
	assert_eq(coins.amount.text,"1,240 coins")

func test_key_hints_use_existing_input_and_display_components_clamp_only_their_view() -> void:
	var actions: Array[StringName] = InputMap.get_actions()
	var hint: LifeKeyHint = _component("key_hint") as LifeKeyHint
	hint.set_action(&"interact")
	assert_false(hint.caption.text.is_empty())
	assert_eq(InputMap.get_actions(),actions)
	hint.hide()
	var hearts: LifeHeartRow = _component("heart_row") as LifeHeartRow
	hearts.set_hearts(9)
	assert_eq(hearts.filled,5)
	hearts.set_hearts(-1)
	assert_eq(hearts.filled,0)
	hearts.hide()
	var bar: LifeProgressBar = _component("progress_bar_styled") as LifeProgressBar
	bar.set_displayed_value(78,100)
	assert_eq(bar.value,78.0)
	bar.set_tone(&"blue")
	assert_eq(bar.theme_type_variation,&"LifeProgressBlue")
	bar.set_displayed_value(999,100)
	assert_eq(bar.value,100.0)

func _click(point: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
