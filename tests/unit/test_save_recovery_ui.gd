extends GutTest

var _viewport: SubViewport
var _main: Node
var _files: Dictionary = {}
var _clock: Dictionary
var _paused: bool
var _locale: String
var _resume_requests: int = 0

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	for slot: int in [0, 1]:
		for index: int in range(4):
			var path: String = _path(slot, index)
			_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
			_remove(path)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152, 648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	for path: String in _files:
		_remove(path)
		var bytes: Variant = _files[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(bytes)
			file.close()
	_files.clear()

func _path(slot: int, index: int = 0) -> String:
	return "user://saves/slot_%d.json%s" % [slot, "" if index == 0 else ".bak%d" % index]

func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)

func _write(slot: int, index: int, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open(_path(slot, index), FileAccess.WRITE)
	file.store_string(text)
	file.close()

func _fixture(kind: String) -> void:
	for slot: int in [0, 1]:
		for index: int in range(4):
			_remove(_path(slot, index))
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v12.json"))
	raw["profile"] = {"farm_name": "Trang trại Mùa An Lành — A long peaceful garden name ẩn ệ ữ ợ ỡ ằ ẫ", "player_name": "Mai"}
	var good: String = JSON.stringify(raw)
	if kind == "primary":
		_write(1, 0, good)
	elif kind == "recovered":
		_write(1, 0, "{broken")
		_write(1, 1, "{also broken")
		_write(1, 2, good)
	elif kind == "future":
		_write(1, 0, JSON.stringify({"meta":{"save_version":SaveService.CURRENT_VERSION+1}}))
		_write(1, 1, good)
	else:
		_write(1, 0, "{broken")
	_main.start_menu.refresh_continue()

func _owners() -> Dictionary:
	return {"farm": _main.farm_state.serialize(), "items": _main.inventory.serialize(), "coins": _main.wallet.serialize(), "weather": _main.weather_state.serialize()}

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _click(button: Control) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		_viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _resumed() -> void:
	_resume_requests += 1

func _capture_pause_matrix(kind: String) -> void:
	var before: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			await _settle()
			var bounds: Rect2 = _main.pause_menu.get_global_rect()
			assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(bounds))
			assert_true(bounds.encloses(_main.pause_menu.presenter.notice.get_global_rect()))
			assert_gt(_main.pause_menu.presenter.notice.label.get_global_rect().position.x, _main.pause_menu.presenter.notice.get_global_rect().position.x)
			assert_true(bounds.encloses(_main.pause_menu.shell.settings.apply_button.get_global_rect()))
			assert_true(bounds.encloses(_main.pause_menu.shell.close_button.get_global_rect()))
			assert_eq(_owners(), before)
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				assert_eq(_viewport.get_texture().get_image().save_png("user://recovery_pause_%s_%s_%d.png" % [kind, locale, dimensions.x]), OK)

func test_title_inspection_preserves_actual_report_owners_and_mode_on_live_translation() -> void:
	_fixture("recovered")
	SaveService.load_game(-1)
	var report: Dictionary = SaveService.get_load_report()
	var before: Dictionary = _owners()
	var hash_before: String = FileAccess.get_sha256(_path(1, 0))
	_main.start_menu.refresh_continue()
	await _settle()
	assert_eq(SaveService.get_load_report(), report)
	assert_eq(_owners(), before)
	assert_eq(FileAccess.get_sha256(_path(1, 0)), hash_before)
	assert_eq(_main.start_menu.screen.notice.label.text, tr("SAVE_NOTICE_RECOVERED") % 2)
	_main.start_menu.screen.set_mode(LifeTitleScreen.Mode.PROFILE)
	TranslationServer.set_locale("en")
	await _settle()
	assert_false(_main.start_menu.screen.notice.visible, "Translation must not reveal title-only notice")
	_main.start_menu.screen.set_mode(LifeTitleScreen.Mode.TITLE)
	assert_eq(_main.start_menu.screen.notice.label.text, tr("SAVE_NOTICE_RECOVERED") % 2)
	assert_eq(LifeSaveNotice.message({"status": &"recovered", "source_index": NAN}), tr("SAVE_NOTICE_INVALID"))

func test_native_continue_recovers_only_after_restore_and_refresh_never_repeats_toast() -> void:
	_fixture("recovered")
	await _settle()
	_main.hud_presenter.root.toasts.clear()
	await _click(_main.start_menu.screen.actions.continue_button)
	assert_false(_main.start_menu.visible)
	assert_true(bool(_main.get("_game_started")))
	assert_eq(_main.get_load_feedback().source_index, 2)
	var expected: String = tr("SAVE_NOTICE_RECOVERED") % 2
	assert_eq(_main.toast.text, expected)
	var matches: int = 0
	for child: Node in _main.hud_presenter.root.toasts.get_children():
		if (child as LifeHudToastCard).caption.text == expected:
			matches += 1
	assert_eq(matches, 1)
	var count: int = _main.hud_presenter.root.toasts.get_child_count()
	_main.start_menu.refresh_continue()
	_main.start_menu.refresh_continue()
	assert_eq(_main.hud_presenter.root.toasts.get_child_count(), count)
	assert_eq(_main.get_load_feedback().status, &"recovered")

func test_pause_recovers_future_and_busy_results_without_stale_success_or_lost_locale() -> void:
	_fixture("recovered")
	_main.set("_game_started", true)
	_main.start_menu.hide()
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	_main.pause_menu.open()
	await _settle()
	await _click(_main.pause_menu.shell.actions.load_button)
	var notice: LifeSaveNotice = _main.pause_menu.presenter.notice
	assert_true(notice.is_visible_in_tree())
	assert_eq(notice.label.text, tr("SAVE_NOTICE_RECOVERED") % 2)
	TranslationServer.set_locale("en")
	await _settle()
	assert_true(notice.is_visible_in_tree())
	assert_eq(notice.label.text, tr("SAVE_NOTICE_RECOVERED") % 2)
	await _capture_pause_matrix("recovered")
	_main.watering_runtime.busy = true
	_main.pause_menu.presenter.request(&"load")
	assert_false(notice.visible)
	assert_eq(_main.pause_menu.shell.settings.status.text, tr("PAUSE_LOAD_FAILED"))
	assert_eq(_main.get_load_feedback(), {})
	_main.watering_runtime.busy = false
	_fixture("future")
	var before: Dictionary = _owners()
	await _click(_main.pause_menu.shell.actions.load_button)
	assert_eq(notice.label.text, tr("SAVE_NOTICE_FUTURE"))
	assert_eq(_owners(), before)
	await _capture_pause_matrix("future")
	_main.pause_menu.configure(_main._save_game_to_slot.bind(-1), _main._load_game, _main._return_to_start_menu)
	_main.pause_menu.presenter.request(&"save")
	assert_eq(_main.pause_menu.shell.settings.status.text, tr("PAUSE_SAVE_FAILED"))
	assert_false(_main.start_menu.visible)

func test_source_and_error_matrix_both_locales_three_sizes_stays_read_only_and_reachable() -> void:
	_main.start_menu.configure(Callable(), _resumed, Callable())
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			_viewport.size = dimensions
			for kind: String in ["primary", "recovered", "future", "corrupt"]:
				_fixture(kind)
				await _settle()
				var screen: LifeTitleScreen = _main.start_menu.screen
				var bounds: Rect2 = _main.start_menu.get_global_rect()
				assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(bounds))
				assert_true(screen.notice.is_visible_in_tree())
				assert_true(bounds.encloses(screen.notice.get_global_rect()))
				assert_true(screen.notice.get_global_rect().encloses(screen.notice.label.get_global_rect()))
				assert_gt(screen.notice.label.get_global_rect().position.x, screen.notice.get_global_rect().position.x)
				assert_true(bounds.encloses(screen.actions.exit_button.get_global_rect()))
				assert_true(bounds.encloses(screen.actions.continue_button.get_global_rect()))
				assert_eq(screen.actions.continue_button.disabled, kind in ["future", "corrupt"])
				var before: Dictionary = _owners()
				if kind in ["future", "corrupt"]:
					_main.start_menu.presenter.request(&"continue")
					assert_eq(_resume_requests, 0)
				assert_eq(_owners(), before)
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					assert_eq(_viewport.get_texture().get_image().save_png("user://recovery_%s_%s_%d.png" % [locale, kind, dimensions.x]), OK)
