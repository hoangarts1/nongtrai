extends GutTest

class CountingSimulator extends RefCounted:
	var calls: int = 0
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		DaySimulator.new().simulate_day(farm)

var _main: Node
var _viewport: SubViewport
var _clock: Dictionary
var _paused: bool
var _locale: String

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	SaveService.delete_save(0)
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game","Mai","Vườn")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = false

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_completed_manual_morning_shows_after_save_and_dismiss_never_simulates_again() -> void:
	var cell: Vector2i = Vector2i.ZERO
	_main.farm_state.till_cell(cell)
	_main.farm_state.plant_crop(cell,&"turnip")
	_main.farm_state.water_cell(cell)
	var weather: Dictionary = _main.weather_state.serialize()
	weather["forecast"] = ["rain","sunny","cloudy"]
	_main.weather_state.deserialize(weather)
	var spy: CountingSimulator = CountingSimulator.new()
	_main.day_simulator = spy
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	_main.day_end_flow.confirm()
	assert_false(_main.morning_flow.panel.visible,"Never opens synchronously inside the rollover")
	assert_eq(int(SaveService.load_game(0).clock.day_index),1)
	await _settle()
	var panel: LifeMorningSheet = _main.morning_flow.panel
	assert_true(panel.visible)
	assert_eq(_main.ui_coordinator.get_active_panel(),panel)
	assert_eq(spy.calls,1)
	assert_eq(GameClock.day_index,1)
	assert_true(GameClock.paused)
	assert_false(_main.world.player.movement_enabled)
	assert_true(bool(_main.farm_state.get_plot(cell).watered),"Actual new-morning rain already ran")
	assert_eq(MorningSnapshot.capture(_main).water,0)
	var before: Dictionary = _domains()
	await _click(panel.begin_button)
	_main.morning_flow.dismiss()
	assert_eq(_domains(),before,"Begin Day is presentation only")
	assert_eq(spy.calls,1)
	assert_false(panel.visible)
	assert_false(GameClock.paused)
	assert_true(_main.world.player.movement_enabled)
	_main.morning_flow.queue_day(GameClock.day_index)
	await _settle()
	assert_false(panel.visible,"Same-day notifications cannot reopen a dismissed bulletin")

func test_waits_for_other_modal_and_day_end_retains_priority() -> void:
	GameClock.set_time(20,0)
	assert_true(GameClock.try_sleep(),"Existing direct path still calls Main once")
	GameClock.advance_minutes(GameClock.SLEEP_END_MINUTE-GameClock.minute)
	_main.inventory_panel.toggle_inventory()
	await _settle()
	assert_true(_main.inventory_panel.visible)
	assert_false(_main.morning_flow.panel.visible)
	_main.ui_coordinator.close_active()
	await _settle()
	assert_true(_main.morning_flow.panel.visible)
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	assert_false(_main.morning_flow.panel.visible)
	_main.morning_flow.panel.show()
	assert_false(_main.morning_flow.panel.visible,"Programmatic show cannot replace day-end review")
	assert_eq(_main.ui_coordinator.get_active_panel(),_main.day_end_flow.panel)
	assert_true(_main.day_end_flow.cancel())

func test_forced_cutoff_finishes_once_then_presents_one_bulletin() -> void:
	var spy: CountingSimulator = CountingSimulator.new()
	_main.day_simulator = spy
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	assert_true(_main.day_end_flow.state.forced)
	assert_false(_main.day_end_flow.cancel())
	_main.day_end_flow.confirm()
	_main.day_end_flow.confirm()
	await _settle()
	assert_eq(spy.calls,1)
	assert_eq(GameClock.day_index,1)
	assert_true(_main.morning_flow.panel.visible)
	assert_eq(int(SaveService.load_game(0).clock.day_index),1)
	_main.morning_flow.dismiss()
	_main.morning_flow.queue_day(GameClock.day_index)
	await _settle()
	assert_false(_main.morning_flow.panel.visible)
	assert_eq(spy.calls,1)

func test_title_load_and_new_game_reset_pending_and_never_replay_old_bulletins() -> void:
	assert_false(_main.morning_flow.panel.visible,"No bulletin on initial New Game/tutorial")
	GameClock.set_time(20,0)
	assert_true(GameClock.try_sleep())
	GameClock.advance_minutes(GameClock.SLEEP_END_MINUTE-GameClock.minute)
	assert_true(_main.call("_return_to_start_menu"))
	await _settle()
	assert_true(_main.start_menu.visible)
	assert_false(_main.morning_flow.panel.visible)
	_main.call("_continue_game")
	await _settle()
	assert_eq(GameClock.day_index,1)
	assert_false(_main.morning_flow.panel.visible,"Continue does not invent a pending UI notification")
	_main.call("_start_new_game","An","Mới")
	_main.tutorial_panel.close_help()
	await _settle()
	assert_eq(GameClock.day_index,0)
	assert_false(_main.morning_flow.panel.visible)
	GameClock.set_time(20,0)
	assert_true(GameClock.try_sleep())
	GameClock.advance_minutes(GameClock.SLEEP_END_MINUTE-GameClock.minute)
	await _settle()
	assert_true(_main.morning_flow.panel.visible,"A real later transition still works after reset")

func test_old_goldens_and_review_restore_do_not_auto_open_morning_or_change_schema() -> void:
	for version: int in range(1,9):
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		_main.call("_load_payload",raw)
		await _settle()
		assert_false(_main.morning_flow.panel.visible,"No bulletin just from v%d restore" % version)
		if _main.day_end_flow.panel.visible:
			assert_eq(_main.ui_coordinator.get_active_panel(),_main.day_end_flow.panel)
	assert_eq(SaveService.CURRENT_VERSION,17)

func test_snapshot_reads_actual_farm_prices_and_refresh_is_pure() -> void:
	var target: int = int(DataRegistry.get_crop(&"turnip").growth_days)
	_main.farm_state.deserialize({"plots":[
		{"cell_x":0,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":target,"growth_target":target,"watered":false},
		{"cell_x":1,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":0,"growth_target":target,"watered":false},
		{"cell_x":2,"cell_y":0,"tilled":true,"crop_id":"turnip","growth_days":target,"growth_target":target,"withered":true},
		{"cell_x":3,"cell_y":0,"tilled":true,"crop_id":""}
	]})
	GameClock.paused = true
	var before: Dictionary = _domains()
	var snapshot: Dictionary = MorningSnapshot.capture(_main)
	assert_eq(snapshot.day_in_season,GameClock.get_day_in_season(),"The clock already reports a one-based season day")
	assert_eq(snapshot.ready,1)
	assert_eq(snapshot.water,2)
	assert_eq(snapshot.empty,1)
	assert_eq(snapshot.withered,1)
	assert_eq(snapshot.forecast.size(),_main.weather_state.forecast.size())
	for row: Dictionary in snapshot.prices:
		assert_eq(int(row.price),int(DataRegistry.get_item(StringName(row.id)).sell_price))
		assert_eq(StringName(DataRegistry.get_item(StringName(row.id)).category),&"produce")
	MorningPresenter.render(_main.morning_flow.panel,snapshot)
	_main.morning_flow.panel.show()
	await _settle()
	for locale: String in ["vi","en","vi"]:
		TranslationServer.set_locale(locale)
		_main.morning_flow.refresh()
	assert_eq(_domains(),before,"Render/locale refresh never rerolls weather or mutates owners")
	_action(&"pause")
	await _settle()
	assert_false(_main.morning_flow.panel.visible)
	assert_true(GameClock.paused,"Pre-existing clock hold is restored")
	assert_eq(_domains(),before)

func _domains() -> Dictionary:
	return {"clock":GameClock.serialize(),"farm":_main.farm_state.serialize(),"weather":_main.weather_state.serialize(),"inventory":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),"quests":_main.quest_state.serialize(),"ledger":_main.day_end_flow.ledger.serialize(),"day_end":_main.day_end_flow.state.serialize()}

func _action(id: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = id
	event.pressed = true
	_viewport.push_input(event,true)

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

func _settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
