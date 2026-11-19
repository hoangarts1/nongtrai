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

func test_native_j_lazy_history_back_escape_and_ordinary_quest_invariant() -> void:
	await f.prepare_dust(self)
	var before: Dictionary = f.owners()
	var files: Dictionary = _saves()
	await f.key(self, KEY_J)
	var panel: NpcPanel = main.npc_system.journal
	assert_true(panel.visible)
	assert_null(panel.book.ecology_sheet)
	assert_true(panel.book.find_children("*", "ProgressBar", true, false).is_empty())
	await f.mouse(self, panel.book.ecology_button.get_global_rect().get_center())
	var sheet: LifeEcologySheet = panel.book.ecology_sheet
	assert_not_null(sheet)
	assert_true(sheet.director_history.records.text.contains(tr("DIR_DUST_TITLE")))
	assert_eq(sheet.director_history.note.text, tr("DIR_READ_HISTORY_NOTE"))
	assert_eq(f.viewport.gui_get_focus_owner(), sheet.back_button)
	await f.mouse(self, sheet.back_button.get_global_rect().get_center())
	assert_null(panel.book.ecology_sheet)
	assert_true(panel.book.find_children("*", "ProgressBar", true, false).is_empty())
	assert_eq(f.viewport.gui_get_focus_owner(), panel.book.ecology_button)
	await f.key(self, KEY_ESCAPE)
	assert_false(panel.visible)
	assert_eq(f.owners(), before)
	assert_eq(_saves(), files)

func test_history_records_selected_dates_not_proof_of_effect_after_off_or_load() -> void:
	await f.prepare_dust(self)
	var history: Array = main.director_state.serialize().history
	assert_true(main.director_runtime.set_enabled(false))
	var model: Dictionary = LifeDirectorSnapshot.capture(main)
	assert_false(model.enabled)
	assert_eq(model.pending, [])
	assert_eq(model.active, [])
	assert_eq(model.history, history)
	var described: Dictionary = LifeDirectorPresenter.describe(model)
	assert_eq(described.summary, tr("DIR_READ_OFF"))
	assert_true(described.history.contains(tr("DIR_READ_SELECTED")))
	assert_true(described.history.contains(tr("DIR_DUST_COUNTER")))
	assert_eq(described.history_note, tr("DIR_READ_HISTORY_NOTE"))
	assert_true(main._save_game_to_slot(98))
	assert_true(main._load_payload(SaveService.load_game(98)))
	assert_eq(LifeDirectorSnapshot.capture(main).history, history)
	assert_eq(main.watering_runtime.get_charge_cost(), 1)
