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
	GameClock.paused = true

func after_each() -> void:
	if is_instance_valid(_viewport):
		_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)

func _game(dimensions: Vector2i = Vector2i(1152,648)) -> void:
	_viewport = SubViewport.new()
	_viewport.size = dimensions
	_viewport.world_2d = World2D.new()
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.set("_game_started",true)
	GameClock.paused = true
	await _settle()

func test_views_are_small_modules_and_display_actual_state() -> void:
	await _game()
	var root: LifeHudRoot = _main.hud_presenter.root
	assert_same(root.theme,LifeTheme.get_theme())
	assert_eq(_main.hotbar_panel.toolbar.buttons.size(),8)
	assert_eq(_main.hud_button_bar.bar.get_child_count(),4,"Only working screens have buttons")
	_main.wallet.add_coins(234,&"test")
	assert_string_contains(root.coins.amount.text,"334")
	GameClock.set_time(21,40)
	assert_eq(root.clock_card.time_label.text,"21:40")
	assert_eq(root.clock_card.arc.minute,1300)
	_main.weather_state.force_weather(&"rain")
	assert_eq(root.clock_card.arc.weather_id,&"rain")
	assert_string_contains(_main.quest_panel.card.progress.text,"0 / 7")
	_main.farm_state.till_cell(Vector2i(0,0))
	assert_string_contains(_main.quest_panel.card.progress.text,"1 / 7")
	for path: String in ["hud_root","hud_presenter","hud_regions","clock_card","clock_arc","quest_card","toolbar","toolbar_slot","shortcut_bar","toast_stack","toast_card","hud_frame","hud_parts"]:
		var script: String = FileAccess.get_file_as_string("res://ui/hud/%s.gd" % path)
		assert_lte(script.split("\n").size(),250,"Small UI responsibility: %s" % path)
	assert_null(root.find_child("Stamina",true,false))
	assert_null(root.find_child("EventCard",true,false))

func test_physical_toolbar_clicks_numeric_window_and_legacy_nine_preserve_inventory() -> void:
	await _game()
	_main.inventory.clear()
	for item: Resource in DataRegistry.get_seed_items():
		_main.inventory.add_item(item.get("item_id"),3)
	var before: Dictionary = _main.inventory.serialize()
	var toolbar: LifeHudToolbar = _main.hotbar_panel.toolbar
	await _click(toolbar.buttons[1])
	assert_eq(_main.tool_controller.get_selected_tool(),&"water")
	await _action(&"hotbar_3")
	assert_eq(_main.tool_controller.get_selected_tool(),&"harvest")
	await _click(toolbar.buttons[3])
	assert_eq(_main.hotbar_panel.get_selected_slot(),_main.inventory.get_slots()[0])
	assert_eq(_main.tool_controller.get_selected_tool(),&"seed")
	await _action(&"hotbar_9")
	assert_eq(_main.hotbar_panel.get_selected_slot(),_main.inventory.get_slots()[8])
	assert_eq(toolbar.active_index,6,"Legacy ninth stack appears in the current five-stack window")
	await _action(&"hotbar_4")
	assert_eq(_main.hotbar_panel.get_selected_slot(),_main.inventory.get_slots()[5])
	assert_eq(_main.inventory.serialize(),before,"Selection never mutates inventory")
	_main.inventory_panel.toggle_inventory()
	await _action(&"hotbar_2")
	assert_eq(_main.tool_controller.get_selected_tool(),&"seed","Modal consumes tool input")
	_main.ui_coordinator.close_active()
	await _action(&"hotbar_1")
	assert_eq(_main.tool_controller.get_selected_tool(),&"hoe")

func test_b_i_tab_open_inventory_and_round_buttons_preserve_modal_lock() -> void:
	await _game()
	assert_eq(InputMap.action_get_events(&"open_build").size(),0)
	for key: Key in [KEY_B,KEY_I,KEY_TAB]:
		await _key(key)
		assert_true(_main.inventory_panel.visible,"Physical inventory shortcut: %s" % OS.get_keycode_string(key))
		assert_false(_main.world.player.movement_enabled)
		assert_false(_main.hotbar_panel.visible)
		await _key(KEY_ESCAPE)
		assert_false(_main.inventory_panel.visible)
		assert_true(_main.world.player.movement_enabled)
	await _click(_main.hud_button_bar.get_button(&"journal"))
	assert_true(_main.npc_system.journal.visible)
	await _key(KEY_ESCAPE)
	await _click(_main.hud_button_bar.get_button(&"pause"))
	assert_true(_main.pause_menu.visible)
	await _key(KEY_ESCAPE)
	assert_null(_main.ui_coordinator.get_active_panel())

func test_toasts_are_bounded_expire_and_do_not_mutate_state() -> void:
	await _game()
	var before: Dictionary = _main.inventory.serialize()
	var stack: LifeHudToastStack = _main.hud_presenter.root.toasts
	stack.clear()
	for message: String in ["first","second","third"]:
		stack.show_message(message)
	assert_eq(stack.get_child_count(),2)
	assert_eq((stack.get_child(0) as LifeHudToastCard).caption.text,"second")
	_main.feedback.show_message(tr("UI_SAVED"))
	assert_eq(stack.get_child_count(),2)
	assert_eq((stack.get_child(1) as LifeHudToastCard).caption.text,tr("UI_SAVED"))
	assert_eq(_main.inventory.serialize(),before)
	await get_tree().create_timer(3.15).timeout
	assert_eq(stack.get_child_count(),0)

func test_day_night_rain_layout_in_both_locales_and_three_sizes() -> void:
	for locale: String in ["vi","en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]:
			await _game(dimensions)
			_main.inventory.add_item(&"turnip_seed",10)
			var root: LifeHudRoot = _main.hud_presenter.root
			for mode: String in ["day","night","rain"]:
				GameClock.set_time(6 if mode=="day" else 21,3 if mode=="day" else 40)
				_main.weather_state.force_weather(&"rain" if mode=="rain" else &"sunny")
				root.toasts.clear()
				_main.feedback.show_message(tr("UI_SAVED"))
				await _settle()
				var controls: Array[Control] = [_main.quest_panel,_main.hotbar_panel,_main.hud_button_bar,root.right_column,_main.world.interaction_prompt,root.toasts]
				for control: Control in controls:
					assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(control.get_global_rect()),"Fits: %s %s %s rect=%s minimum=%s" % [control.name,locale,dimensions,control.get_global_rect(),control.get_combined_minimum_size()])
				for first: int in range(controls.size()):
					for second: int in range(first+1,controls.size()):
						assert_false(controls[first].get_global_rect().intersects(controls[second].get_global_rect()),"No overlap: %s / %s" % [controls[first].name,controls[second].name])
				for button: Button in _main.hotbar_panel.toolbar.buttons:
					assert_true(_main.hotbar_panel.get_global_rect().encloses(button.get_global_rect()))
				assert_lt(_main.quest_panel.position.x,dimensions.x*0.3)
				assert_gt(root.right_column.position.x,dimensions.x*0.7)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					var image: Image = _viewport.get_texture().get_image()
					assert_eq(image.save_png("user://iso3_%s_%s_%d.png" % [locale,mode,dimensions.x]),OK)
			_viewport.free()
			await get_tree().process_frame

func _action(action: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	_viewport.push_input(event,true)
	await _settle()

func _key(key: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
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
	for frame: int in range(6):
		await get_tree().process_frame
