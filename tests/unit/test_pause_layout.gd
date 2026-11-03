extends GutTest

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
var _viewport: SubViewport
var _main: Node
var _clock: Dictionary
var _paused: bool
var _locale: String
var _music: float
var _effects: float
var _preference_locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_music = Settings.get_music_volume()
	_effects = Settings.get_effects_volume()
	_preference_locale = Settings.get_locale()
	_viewport = SubViewport.new()
	_viewport.size = SIZES[0]
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Settings.set_music_volume(_music)
	Settings.set_effects_volume(_effects)
	Settings.set_locale(_preference_locale)
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _game() -> void:
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.set("_game_started",true)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = false
	_main.pause_menu.open()

func test_reference_two_panel_layout_all_tabs_and_states_in_both_locales() -> void:
	for locale: String in ["vi","en"]:
		for dimensions: Vector2i in SIZES:
			Settings.set_locale(locale)
			_viewport.size = dimensions
			_game()
			await _settle()
			var panel: Control = _main.pause_menu
			var shell: LifePauseShell = _main.pause_menu.shell
			var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(dimensions))
			assert_true(bounds.encloses(panel.get_global_rect()),"Pause fits viewport")
			assert_false(shell.actions.get_global_rect().intersects(shell.settings.get_global_rect()))
			for tab: int in range(4):
				shell.settings.select_tab(tab)
				await _settle()
				_check_controls(panel,panel.get_global_rect())
				assert_true(_main.ui_coordinator.get_active_panel() == panel)
				assert_false(_main.world.player.movement_enabled)
				assert_true(GameClock.paused)
				await _capture("%s_tab%d_%d" % [locale,tab,dimensions.x])
			shell.settings.select_tab(0)
			shell.settings.audio.set_values(0.7,0.85)
			await _capture("%s_dirty_%d" % [locale,dimensions.x])
			_main.pause_menu.presenter.defaults()
			await _capture("%s_default_%d" % [locale,dimensions.x])
			shell.settings.game.set_locale(locale)
			_main.pause_menu.presenter.apply()
			await _capture("%s_applied_%d" % [locale,dimensions.x])
			_main.pause_menu.presenter.show_result(&"PAUSE_SAVE_FAILED")
			await _capture("%s_save_failed_%d" % [locale,dimensions.x])
			_main.pause_menu.close()
			_main.pause_menu.open()
			assert_eq(shell.settings.status.text,tr("PAUSE_DRAFT_NOTE"))
			await _capture("%s_reopened_%d" % [locale,dimensions.x])
			_main.free()

func test_physical_mouse_tabs_sliders_apply_save_load_and_close() -> void:
	Settings.set_locale("vi")
	_game()
	await _settle()
	var shell: LifePauseShell = _main.pause_menu.shell
	await _click(shell.settings.tabs[3])
	assert_eq(shell.settings.active_tab,3)
	await _click(shell.settings.tabs[0])
	assert_eq(shell.settings.active_tab,0)
	var slider: HSlider = shell.settings.audio.effects
	var previous: float = Settings.get_effects_volume()
	var point: Vector2 = slider.get_global_rect().position+Vector2(slider.size.x*0.25,slider.size.y*0.5)
	await _mouse(point)
	assert_lt(slider.value,0.5,"Physical click changes native slider")
	assert_almost_eq(Settings.get_effects_volume(),previous,0.001,"Edit is still a draft")
	await _click(shell.settings.apply_button)
	assert_almost_eq(Settings.get_effects_volume(),slider.value,0.001)
	slider.value = 0.6
	assert_eq(shell.settings.status.text,tr("PAUSE_DRAFT_NOTE"),"Editing after Apply restores draft feedback")
	var coins: int = _main.wallet.get_coins()
	await _click(shell.actions.save_button)
	assert_eq(shell.settings.status.text,tr("UI_SAVED"))
	_main.wallet.add_coins(7,&"test")
	await _click(shell.actions.load_button)
	assert_eq(_main.wallet.get_coins(),coins)
	assert_eq(shell.settings.status.text,tr("PAUSE_LOADED"))
	assert_true(_main.pause_menu.visible)
	await _click(shell.close_button)
	assert_false(_main.pause_menu.visible)
	assert_true(_main.world.player.movement_enabled)
	assert_false(GameClock.paused)

func test_native_focus_keys_do_not_trigger_inventory_or_world_tools() -> void:
	_game()
	await _settle()
	var shell: LifePauseShell = _main.pause_menu.shell
	var farm: Dictionary = _main.farm_state.serialize()
	var inventory: Dictionary = _main.inventory.serialize()
	shell.settings.audio.music.value = 0.5
	shell.settings.audio.music.grab_focus()
	await _key(KEY_RIGHT)
	assert_almost_eq(shell.settings.audio.music.value,0.55,0.001,"Arrow reaches native slider")
	await _key(KEY_TAB)
	assert_true(_main.pause_menu.visible,"Tab traverses focus rather than opening Bag")
	assert_false(_main.inventory_panel.visible)
	assert_eq(_main.farm_state.serialize(),farm)
	assert_eq(_main.inventory.serialize(),inventory)
	shell.settings.default_button.grab_focus()
	await _key(KEY_SPACE)
	assert_eq(shell.settings.status.text,tr("PAUSE_DEFAULT_DRAFT"),"Space activates focused button")
	await _key(KEY_ESCAPE)
	assert_false(_main.pause_menu.visible)
	assert_true(_main.world.player.movement_enabled)

func _check_controls(node: Node, bounds: Rect2) -> void:
	for child: Node in node.get_children():
		if child is Control and (child as Control).is_visible_in_tree():
			var control: Control = child as Control
			if control is Button or control is HSlider:
				# Pages may scroll, but horizontal clipping is always a layout failure.
				assert_gte(control.get_global_rect().position.x,bounds.position.x)
				assert_lte(control.get_global_rect().end.x,bounds.end.x+0.1,"%s right edge %s / %s" % [control.name,control.get_global_rect(),bounds])
				assert_gte(control.size.y,36.0)
		_check_controls(child,bounds)

func _click(control: Control) -> void:
	await _mouse(control.get_global_rect().get_center())

func _mouse(point: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	_viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _capture(id: String) -> void:
	await _settle()
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://iso7_%s.png" % id),OK)
