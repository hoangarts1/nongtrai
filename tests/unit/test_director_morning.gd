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

func test_committed_pending_warning_survives_actual_save_before_single_morning_and_dismissal() -> void:
	await f.prepare_dust(self)
	var pending: Dictionary = main.director_state.serialize().pending[0]
	assert_eq(int(pending.start_day) - GameClock.day_index, 2)
	GameClock.sleep_to_morning()
	GameClock.paused = true
	await f.settle(self)
	assert_true(main.morning_flow.panel.visible)
	var saved: Dictionary = SaveService.load_game(0)
	assert_eq(int(saved.clock.day_index), GameClock.day_index)
	assert_eq(saved.director, main.director_state.serialize())
	var model: Dictionary = MorningSnapshot.capture(main).director
	assert_eq(model.pending, main.director_state.serialize().pending)
	assert_eq(int(model.pending[0].start_day) - int(model.day_index), 1)
	assert_true(main.morning_flow.panel.director.summary.text.contains(tr("DIR_DUST_TITLE")))
	var before: Dictionary = f.owners()
	var files: Dictionary = _saves()
	main.morning_flow.refresh()
	main.morning_flow.dismiss()
	main.morning_flow.dismiss()
	await f.settle(self)
	assert_false(main.morning_flow.panel.visible)
	assert_eq(f.owners(), before)
	assert_eq(_saves(), files)
	assert_true(main._load_payload(saved))
	await f.settle(self)
	assert_false(main.morning_flow.panel.visible)
	assert_eq(main.director_state.serialize(), saved.director)

func test_actual_current_water_counter_tooltip_and_cost_change_without_owner_mutation() -> void:
	await f.prepare_dust(self)
	await f.advance(self, 2, 100.0, 0.0)
	var model: Dictionary = LifeDirectorSnapshot.capture(main)
	assert_eq(model.charge_cost, 2)
	assert_eq(model.dust_reason, "extra_charge")
	var before: Dictionary = f.owners()
	main.hud_presenter._refresh_water_detail()
	assert_eq(main.hotbar_panel.toolbar.water_meter.amount.text, tr("WATER_CAN_COUNT") % [20, 20])
	assert_true(main.hotbar_panel.toolbar.water_meter.tooltip_text.contains(tr("DIR_READ_WATER") % 2))
	assert_true(main.hotbar_panel.toolbar.water_meter.tooltip_text.contains(tr("DIR_READ_REFILL")))
	assert_eq(f.owners(), before)
	main.weather_state.force_weather(&"rain")
	model = LifeDirectorSnapshot.capture(main)
	assert_eq(model.charge_cost, 1)
	assert_eq(model.dust_reason, "rain")
	assert_true(LifeDirectorPresenter.water_text(model).contains(tr("DIR_READ_RAIN")))
	main.weather_state.force_weather(&"sunny")
	var eco: Dictionary = main.ecology_state.serialize()
	eco.metrics.tree_cover = 30.0
	main.ecology_state.deserialize(eco)
	assert_eq(LifeDirectorSnapshot.capture(main).charge_cost, 1)
	assert_eq(LifeDirectorSnapshot.capture(main).dust_reason, "canopy")
	assert_eq(main.watering_can.serialize(), before.water)

func test_disabled_partial_stale_expired_and_detached_readouts_never_invent_event_or_measurement() -> void:
	assert_eq(LifeDirectorPresenter.status(LifeDirectorSnapshot.capture(main)), tr("DIR_READ_OFF"))
	assert_true(main.director_runtime.set_enabled(true))
	assert_eq(LifeDirectorPresenter.status(LifeDirectorSnapshot.capture(main)), tr("DIR_READ_PARTIAL"))
	var eco: Dictionary = main.ecology_state.serialize()
	eco.day_index += 1
	main.ecology_state.deserialize(eco)
	assert_false(LifeDirectorSnapshot.capture(main).ok)
	eco.day_index -= 1
	main.ecology_state.deserialize(eco)
	assert_true(main.director_runtime.set_enabled(false))
	await f.prepare_dust(self)
	await f.advance(self, 3, 100.0, 0.0)
	var model: Dictionary = LifeDirectorSnapshot.capture(main)
	for event: Dictionary in model.active:
		assert_ne(event.event_id, "gentle_dust")
	assert_eq(model.charge_cost, 1)
	var before: Dictionary = f.owners()
	model.history.clear()
	model.active.clear()
	assert_eq(f.owners(), before)
