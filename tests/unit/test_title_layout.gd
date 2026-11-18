extends GutTest

var _backup_snapshots: Dictionary = {}

const SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String
var _preferences: Dictionary
var _start_requests: int = 0
var _exit_requests: int = 0
var _continue_requests: int = 0

func before_each() -> void:
	_isolate_backups()
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	_preferences = {"locale":Settings.get_locale(),"music":Settings.get_music_volume(),"effects":Settings.get_effects_volume()}
	_start_requests = 0
	_exit_requests = 0
	_continue_requests = 0
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = SIZES[0]
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)

func after_each() -> void:
	_restore_backups()
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	Settings.set_locale(String(_preferences.locale))
	Settings.set_music_volume(float(_preferences.music))
	Settings.set_effects_volume(float(_preferences.effects))
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func _game() -> void:
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)

func test_reference01_layout_with_long_empty_corrupt_profile_settings_at_three_sizes() -> void:
	for locale: String in ["vi","en"]:
		for dimensions: Vector2i in SIZES:
			Settings.set_locale(locale)
			_viewport.size = dimensions
			SaveService.delete_save(0)
			SaveService.delete_save(1)
			_game()
			await _settle()
			assert_true(_main.start_menu.screen.actions.continue_button.disabled)
			await _inspect_capture("%s_empty_%d" % [locale,dimensions.x])
			assert_true(SaveService.save_game({"profile":{"farm_name":"Trang trại Mùa An Lành — A very long peaceful garden name","player_name":"Người làm vườn ẩn ệ ữ ợ ỡ ằ ẫ"},"wallet":{"coins":1240},"clock":{"day_index":2}},0))
			_main.start_menu.refresh_continue()
			await _inspect_capture("%s_latest_%d" % [locale,dimensions.x])
			SaveService.delete_save(0)
			assert_true(SaveService.save_game({},1))
			var file: FileAccess = FileAccess.open("user://saves/slot_1.json",FileAccess.WRITE)
			file.store_string("{broken")
			file.close()
			_main.start_menu.refresh_continue()
			assert_true(_main.start_menu.screen.actions.continue_button.disabled)
			await _inspect_capture("%s_corrupt_%d" % [locale,dimensions.x])
			_main.start_menu.call("_show_new_game_fields")
			await _inspect_capture("%s_profile_%d" % [locale,dimensions.x])
			_main.start_menu.handle_back()
			_main.start_menu.call("_toggle_settings")
			_main.start_menu.screen.settings.panel.audio.set_values(0.7,0.85)
			await _inspect_capture("%s_settings_audio_%d" % [locale,dimensions.x])
			_main.start_menu.screen.settings.panel.select_tab(3)
			await _inspect_capture("%s_settings_game_%d" % [locale,dimensions.x])
			_main.free()

func test_physical_buttons_confirm_back_settings_continue_exit() -> void:
	_game()
	await _settle()
	var menu: StartMenu = _main.start_menu
	menu.configure(_started,_continued,_exited)
	await _click(menu.screen.actions.settings_button)
	assert_eq(menu.screen.mode,LifeTitleScreen.Mode.SETTINGS)
	await _click(menu.screen.settings.back_button)
	assert_eq(menu.screen.mode,LifeTitleScreen.Mode.TITLE)
	await _click(menu.screen.actions.new_game_button)
	assert_true(menu.screen.profile.visible)
	await _click(menu.screen.profile.back_button)
	assert_eq(menu.screen.mode,LifeTitleScreen.Mode.TITLE)
	await _click(menu.screen.actions.exit_button)
	assert_eq(_exit_requests,1,"Native exit button dispatches to configured callback")
	assert_true(SaveService.save_game({},0))
	menu.refresh_continue()
	await _settle()
	SaveService.delete_save(0)
	await _click(menu.screen.actions.continue_button)
	assert_eq(_continue_requests,0,"A vanished save is rechecked on a real click")
	assert_true(menu.screen.actions.continue_button.disabled)
	assert_true(SaveService.save_game({},0))
	menu.refresh_continue()
	await _settle()
	await _click(menu.screen.actions.continue_button)
	assert_eq(_continue_requests,1)
	await _click(menu.screen.actions.new_game_button)
	await _click(menu.screen.profile.confirm_button)
	assert_eq(_start_requests,1,"One native press/release requests one new game")
	assert_false(menu.visible)

func test_native_focus_typing_and_escape_do_not_open_world_modals() -> void:
	_game()
	await _settle()
	var menu: StartMenu = _main.start_menu
	assert_true(menu.screen.actions.new_game_button.has_focus())
	await _key(KEY_TAB)
	assert_true(menu.visible)
	assert_false(_main.inventory_panel.visible)
	menu.screen.actions.new_game_button.grab_focus()
	await _key(KEY_ENTER)
	assert_eq(menu.screen.mode,LifeTitleScreen.Mode.PROFILE)
	assert_true(menu.screen.profile.player_name.has_focus())
	await _key(KEY_B,98)
	assert_eq(menu.screen.profile.player_name.text,"b","World shortcut letter stays in LineEdit")
	assert_false(_main.inventory_panel.visible)
	await _key(KEY_ESCAPE)
	assert_eq(menu.screen.mode,LifeTitleScreen.Mode.TITLE)
	assert_true(menu.visible,"Escape cannot dismiss the title into an unstarted world")
	await _key(KEY_ESCAPE)
	assert_true(menu.visible)
	assert_false(_main.world.player.movement_enabled)
	assert_false(bool(_main.get("_game_started")))
	assert_eq(_main.ui_coordinator.get_active_panel(),menu)

func _inspect_capture(id: String) -> void:
	await _settle()
	var menu: StartMenu = _main.start_menu
	assert_true(Rect2(Vector2.ZERO,Vector2(_viewport.size)).encloses(menu.get_global_rect()),"Title root fits viewport: "+id)
	assert_false(_main.world.player.movement_enabled)
	assert_true(GameClock.paused)
	assert_eq(_main.ui_coordinator.get_active_panel(),menu)
	_check_fixed(menu,menu.get_global_rect())
	if menu.screen.latest.visible and menu.screen.latest.day.visible:
		assert_true(menu.screen.latest.get_global_rect().encloses(menu.screen.latest.day.get_global_rect()),"Saved day stays visible outside the names scroll")
		assert_true(menu.screen.latest.get_global_rect().encloses(menu.screen.latest.coins.get_global_rect()),"Saved coins stay visible outside the names scroll")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		assert_eq(_viewport.get_texture().get_image().save_png("user://iso8a_%s.png" % id),OK)

func _check_fixed(node: Node, bounds: Rect2) -> void:
	for child: Node in node.get_children():
		if child is ScrollContainer:
			continue
		if child is Control and (child as Control).is_visible_in_tree():
			var control: Control = child as Control
			if control is BaseButton:
				assert_true(bounds.encloses(control.get_global_rect()),"Fixed control fits: %s / %s in %s" % [control.name,control.get_global_rect(),bounds])
				assert_gte(control.size.y,36.0)
		_check_fixed(child,bounds)

func _click(control: Control) -> void:
	var point: Vector2 = control.get_global_rect().get_center()
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

func _key(code: Key, character: int = 0) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.unicode = character
		event.pressed = pressed
		_viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _started(_player: String, _farm: String) -> void:
	_start_requests += 1

func _continued() -> void:
	_continue_requests += 1

func _exited() -> void:
	_exit_requests += 1

# Corruption without a usable backup must not inherit another test's recovery files.
func _isolate_backups() -> void:
	for slot: int in [0, 1]:
		for index: int in range(1, SaveService.MAX_BACKUPS + 1):
			var path: String = "%s/slot_%d.json.bak%d" % [SaveService.SAVE_DIRECTORY, slot, index]
			_backup_snapshots[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
			if FileAccess.file_exists(path):
				assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)

func _restore_backups() -> void:
	for path: String in _backup_snapshots:
		if FileAccess.file_exists(path):
			assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)
		var bytes: Variant = _backup_snapshots[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			assert_not_null(file)
			file.store_buffer(bytes)
			file.close()
	_backup_snapshots.clear()
