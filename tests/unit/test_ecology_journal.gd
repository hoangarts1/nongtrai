extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
const SIZES: Array[Vector2i] = [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]
var _fixture: RefCounted
var _main: Node
var _panel: NpcPanel
var _captures: int = 0

func before_each() -> void:
	_fixture = FIXTURE.new()
	_fixture.setup(self)
	_main = _fixture.main
	_panel = _main.npc_system.journal
	_captures = 0

func after_each() -> void:
	_panel.book_controller.ecology_controller.reset()
	await _fixture.settle(self)
	_fixture.cleanup()

func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_fixture.viewport.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		_fixture.viewport.push_input(event, true)
		await get_tree().process_frame
	await _fixture.settle(self)

func _open() -> LifeEcologySheet:
	_main.npc_system.open_journal()
	await _fixture.settle(self)
	await _click(_panel.book.ecology_button)
	return _panel.book.ecology_sheet

func _owners() -> Dictionary:
	var values: Dictionary = _fixture.owners()
	values.ecology = _main.ecology_state.serialize()
	values.land = _main.land_ownership.serialize()
	return values

func test_native_j_entry_mouse_and_keyboard_back_preserve_tabs_filters_and_owners() -> void:
	var before: Dictionary = _owners()
	await _fixture.key(self, KEY_J)
	assert_true(_panel.visible)
	assert_true(_panel.book.find_children("*", "ProgressBar", true, false).is_empty())
	await _click(_panel.book.ecology_button)
	var sheet: LifeEcologySheet = _panel.book.ecology_sheet
	assert_not_null(sheet)
	assert_true(_panel.book_controller.ecology_controller.is_open())
	assert_false(_panel.book.body.visible)
	assert_eq(sheet.metric_rows.size(), 3)
	assert_eq(sheet.metric_rows[0].bar.value, _main.ecology_state.get_metrics().tree_cover)
	assert_false(sheet.metric_rows[2].bar.visible)
	assert_eq(sheet.metric_rows[2].value.text, tr("ECO_UNMEASURED"))
	for index: int in range(_panel.book.tabs.buttons.size()):
		assert_eq(_panel.book.tabs.buttons[index].disabled, index not in [0, 1, 2])
	assert_eq(_panel.book.filters.buttons.size(), 4)
	sheet.back_button.grab_focus()
	await _fixture.key(self, KEY_ENTER)
	assert_null(_panel.book.ecology_sheet)
	assert_true(_panel.book.body.visible)
	assert_true(_panel.book.find_children("*", "ProgressBar", true, false).is_empty())
	assert_eq(_owners(), before)
	await _click(_panel.book.ecology_button)
	await _fixture.key(self, KEY_Q)
	assert_true(_main.character_flow.panel.visible)
	assert_false(_panel.visible)
	await _fixture.key(self, KEY_E)
	assert_true(_panel.visible)
	assert_null(_panel.book.ecology_sheet)
	await _fixture.key(self, KEY_ESCAPE)
	assert_false(_panel.visible)
	assert_eq(_owners(), before)

func test_live_language_refresh_real_thresholds_water_and_readonly_save_bytes() -> void:
	assert_true(_main.ecology_state.deserialize({"day_index": GameClock.day_index, "metrics": {"tree_cover": 30.0, "biodiversity": 25.0, "water_clarity": 99.0}, "triggered": []}))
	var before: Dictionary = _owners()
	var saved: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	var sheet: LifeEcologySheet = await _open()
	assert_not_null(sheet)
	for locale: String in ["vi", "en", "vi"]:
		TranslationServer.set_locale(locale)
		await _fixture.settle(self)
		assert_eq(sheet.title.text, tr("ECO_TITLE"))
		assert_eq(sheet.back_button.text, tr("ECO_BACK"))
		assert_eq(sheet.metric_rows[0].bar.value, 30.0)
		assert_eq(sheet.metric_rows[0].summary.labels.status_text.text, tr("ECO_ACTIVE"))
		assert_false(sheet.metric_rows[2].bar.visible)
		assert_eq(sheet.metric_rows[2].value.text, tr("ECO_UNMEASURED"))
		assert_false(sheet.metric_rows[2].summary.labels.source_text.visible)
	assert_eq(_owners(), before)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"), saved)
	var reservation: Dictionary = _main.ecology_state.begin_day(GameClock.day_index + 1)
	assert_true(reservation.ok)
	TranslationServer.set_locale("en")
	await _fixture.settle(self)
	assert_true(sheet.waiting.visible)
	assert_false(sheet.scroll.visible)
	assert_eq(sheet.title.text, tr("ECO_TITLE"))
	assert_eq(sheet.back_button.text, tr("ECO_BACK"))
	assert_true(_main.ecology_state.abort_day(reservation.token))

func test_hidden_entry_load_new_game_and_day_end_precedence_reset_transient_page() -> void:
	_panel.book.ecology_button.pressed.emit()
	assert_null(_panel.book.ecology_sheet)
	assert_not_null(await _open())
	var payload: Dictionary = SaveService.load_game(1)
	assert_true(_main.call("_load_payload", payload))
	await _fixture.settle(self)
	assert_null(_panel.book.ecology_sheet)
	assert_not_null(await _open())
	_main.call("_start_new_game", "An", "Other")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	await _fixture.settle(self)
	assert_null(_panel.book.ecology_sheet)
	GameClock.set_time(20, 0)
	assert_true(_main.day_end_flow.request())
	_panel.book.ecology_button.pressed.emit()
	assert_null(_panel.book.ecology_sheet)
	assert_true(_main.day_end_flow.panel.visible)
	assert_true(_main.day_end_flow.cancel())

func test_both_locales_three_sizes_actual_states_scroll_focus_and_fresh_captures() -> void:
	var sheet: LifeEcologySheet = await _open()
	assert_not_null(sheet)
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_fixture.viewport.size = dimensions
			for kind: String in ["initial", "active", "long"]:
				var score: float = 0.0 if kind == "initial" else 50.0
				assert_true(_main.ecology_state.deserialize({"day_index": GameClock.day_index, "metrics": {"tree_cover": score, "biodiversity": score, "water_clarity": 99.0}, "triggered": []}))
				_panel.book_controller.ecology_controller.queue_render()
				await _fixture.settle(self)
				if kind == "long":
					sheet.metric_rows[0].summary.labels.hint.text = (tr("ECO_HINT_TREES") + " ").repeat(12)
				await _fixture.settle(self)
				assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(_panel.get_global_rect()), str(dimensions))
				assert_lt(_panel.book.ecology_button.size.x, _panel.size.x * 0.25, "Entry leaves room for existing tabs")
				for control: Control in [_panel.book.tabs, _panel.book.ecology_button, sheet.title, sheet.scroll, sheet.back_button]:
					assert_true(_panel.get_global_rect().encloses(control.get_global_rect()), control.name)
				assert_false(sheet.metric_rows[2].bar.visible)
				sheet.scroll.scroll_vertical = 0
				await _capture("%s_%d_%s_top" % [locale, dimensions.x, kind])
				sheet.scroll.scroll_vertical = int(sheet.scroll.get_v_scroll_bar().max_value)
				await _fixture.settle(self)
				assert_gt(sheet.scroll.scroll_vertical, 0)
				assert_true(sheet.scroll.get_global_rect().intersects(sheet.metric_rows[2].get_global_rect()))
				await _capture("%s_%d_%s_water" % [locale, dimensions.x, kind])
	if DisplayServer.get_name() != "headless":
		assert_eq(_captures, 36)

func _capture(id: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_fixture.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	assert_eq(_fixture.viewport.get_texture().get_image().save_png("user://eco_journal_%s.png" % id), OK)
	_captures += 1
