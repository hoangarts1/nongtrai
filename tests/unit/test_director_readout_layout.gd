extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	await f.settle(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func _saves() -> Dictionary:
	var result: Dictionary = {}
	for name: String in DirAccess.get_files_at(SaveService.SAVE_DIRECTORY):
		result[name] = FileAccess.get_sha256(SaveService.SAVE_DIRECTORY.path_join(name))
	return result

func _capture(tag: String, locale: String, size: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		return
	f.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var picture: Image = f.viewport.get_texture().get_image()
	assert_eq(picture.get_size(), size)
	assert_eq(picture.save_png("user://director_readout_%s_%s_%dx%d.png" % [tag, locale, size.x, size.y]), OK)

func _morning_matrix(tag: String) -> void:
	var before: Dictionary = f.owners()
	var files: Dictionary = _saves()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			f.viewport.size = size
			main.ui_coordinator.close_active()
			MorningPresenter.render(main.morning_flow.panel, MorningSnapshot.capture(main))
			main.morning_flow.panel.show()
			await f.settle(self)
			var panel: LifeMorningSheet = main.morning_flow.panel
			assert_true(Rect2(Vector2.ZERO, Vector2(size)).encloses(panel.get_global_rect()))
			for control: Control in [panel.director, panel.begin_button, panel.ecology, panel.tasks]:
				assert_true(panel.get_global_rect().encloses(control.get_global_rect()))
			assert_gt(panel.weather.size.y, 100.0)
			assert_true(panel.director.tooltip_text.contains(tr("DIR_DUST_COUNTER")))
			await _capture(tag, locale, size)
			await f.key(self, KEY_ESCAPE)
			assert_false(panel.visible)
	assert_eq(f.owners(), before)
	assert_eq(_saves(), files)

func test_native_pending_active_morning_and_lazy_journal_two_locales_three_sizes() -> void:
	await f.prepare_dust(self)
	await _morning_matrix("pending")
	await f.advance(self, 2, 100.0, 0.0)
	await _morning_matrix("active")
	var before: Dictionary = f.owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			f.viewport.size = size
			await f.key(self, KEY_J)
			var panel: NpcPanel = main.npc_system.journal
			await f.mouse(self, panel.book.ecology_button.get_global_rect().get_center())
			var sheet: LifeEcologySheet = panel.book.ecology_sheet
			assert_not_null(sheet)
			assert_true(Rect2(Vector2.ZERO, Vector2(size)).encloses(panel.get_global_rect()))
			sheet.scroll.ensure_control_visible(sheet.director_history.records)
			await f.settle(self)
			assert_true(sheet.scroll.get_global_rect().intersects(sheet.director_history.records.get_global_rect()))
			assert_true(panel.get_global_rect().encloses(sheet.back_button.get_global_rect()))
			await _capture("journal", locale, size)
			await f.key(self, KEY_ESCAPE)
			await f.settle(self)
			assert_null(panel.book.ecology_sheet)
	assert_eq(f.owners(), before)

func test_long_history_and_localized_copy_remain_inside_existing_scroll() -> void:
	await f.prepare_dust(self)
	await f.key(self, KEY_J)
	var panel: NpcPanel = main.npc_system.journal
	await f.mouse(self, panel.book.ecology_button.get_global_rect().get_center())
	var sheet: LifeEcologySheet = panel.book.ecology_sheet
	var before: Dictionary = f.owners()
	var stress: Dictionary = LifeDirectorSnapshot.capture(main)
	var actual: Dictionary = stress.history.back().duplicate(true)
	stress.history.clear()
	for _index: int in range(LifeDirectorRuntime.PROFILE.history_limit):
		stress.history.append(actual.duplicate(true))
	sheet.director_history.display(stress)
	sheet.director_history.note.text = tr("DIR_READ_HISTORY_NOTE").repeat(8)
	await f.settle(self)
	assert_true(panel.get_global_rect().encloses(sheet.back_button.get_global_rect()))
	assert_gt(sheet.scroll.get_v_scroll_bar().max_value, sheet.scroll.size.y)
	sheet.scroll.scroll_vertical = int(sheet.scroll.get_v_scroll_bar().max_value)
	await f.settle(self)
	assert_true(sheet.scroll.get_global_rect().intersects(sheet.director_history.records.get_global_rect()))
	assert_eq(f.owners(), before)
