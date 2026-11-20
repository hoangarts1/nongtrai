extends GutTest

class CountingSimulator extends RefCounted:
	var calls: int = 0
	func simulate_day(farm: FarmGridState) -> void:
		calls += 1
		DaySimulator.new().simulate_day(farm)

var _clock: Dictionary
var _paused: bool
var _locale: String
var _viewport: SubViewport
var _main: Node

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_locale = TranslationServer.get_locale()
	GameClock.deserialize({})
	GameClock.paused = true

func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(_viewport):
		_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.paused = _paused
	TranslationServer.set_locale(_locale)
	SaveService.delete_save(77)

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
	_main.ui_coordinator.close_active()
	_main.set("_game_started",true)
	_main.day_end_flow.reset()
	GameClock.paused = true
	await _settle()

func _trade() -> void:
	_main.wallet.add_coins(250,&"gift")
	assert_true(_main.seed_shop_panel.try_buy_item(&"turnip_seed",4))
	_main.inventory.add_item(&"turnip",3)
	_main.shipping_bin_panel.call("_select_item",&"turnip")
	_main.shipping_bin_panel.call("_set_max_quantity")
	_main.shipping_bin_panel.call("_confirm_sale")

func test_manual_bed_review_stay_and_escape_preserve_state() -> void:
	await _game()
	GameClock.set_time(20,0)
	_main.world.player.move_to_cell(Vector2i(11,8))
	var before: Dictionary = _main.farm_state.serialize()
	await _action(&"interact")
	var flow: LifeDayEndFlow = _main.day_end_flow
	assert_true(flow.panel.visible)
	assert_true(GameClock.is_day_end_held())
	assert_false(_main.world.player.movement_enabled)
	assert_false(_main.hotbar_panel.visible)
	GameClock.advance_minutes(600)
	assert_eq(GameClock.day_index,0,"Review cannot be bypassed by direct clock advancement")
	await _action(&"open_inventory")
	assert_false(_main.inventory_panel.visible)
	_main.pause_menu.open()
	assert_false(_main.pause_menu.visible,"Programmatic modal switching is also blocked")
	await _action(&"pause")
	assert_false(flow.panel.visible)
	assert_false(GameClock.is_day_end_held())
	assert_eq(_main.farm_state.serialize(),before)
	assert_eq(GameClock.day_index,0)
	assert_true(flow.request())
	await _click(flow.panel.stay_button)
	assert_false(flow.panel.visible)

func test_confirm_is_reentrant_safe_and_saves_only_completed_morning() -> void:
	await _game()
	_trade()
	var cell: Vector2i = Vector2i(0,0)
	_main.farm_state.till_cell(cell)
	_main.farm_state.plant_crop(cell,&"turnip")
	_main.farm_state.water_cell(cell)
	var spy: CountingSimulator = CountingSimulator.new()
	_main.day_simulator = spy
	GameClock.set_time(20,0)
	var flow: LifeDayEndFlow = _main.day_end_flow
	assert_true(flow.request())
	var reentry: Callable = func(_day: int) -> void:
		flow.confirm()
		_main.call("_save_game_to_slot",77)
	GameClock.day_started.connect(reentry)
	await _click(flow.panel.continue_button)
	flow.confirm()
	GameClock.day_started.disconnect(reentry)
	assert_eq(spy.calls,1)
	assert_eq(GameClock.day_index,1)
	assert_eq(GameClock.minute,GameClock.MORNING_MINUTE)
	assert_false(flow.panel.visible)
	assert_false(GameClock.is_day_end_held())
	assert_eq(int(_main.farm_state.get_plot(cell)["growth_days"]),1)
	assert_true(_main.quest_state.is_step_completed(3),"Existing sleep completion event is preserved")
	assert_true(SaveService.load_game(77).is_empty(),"No unsafe mid-rollover snapshot")
	var saved: Dictionary = SaveService.load_game(0)
	assert_eq(int(saved["clock"]["day_index"]),1)
	assert_eq(int(saved["day_end"]["phase"]),int(DayEndState.Phase.IDLE))
	assert_eq(saved["day_ledger"]["entries"],[])
	assert_true(saved["quests"]["completed"][3],"Autosave includes sleep completion")

func test_forced_cutoff_cannot_cancel_or_advance_behind_review() -> void:
	await _game()
	GameClock.set_time(25,59)
	GameClock.advance_minutes(1)
	await _settle()
	var flow: LifeDayEndFlow = _main.day_end_flow
	assert_true(flow.panel.visible)
	assert_true(flow.state.forced)
	assert_false(flow.panel.stay_button.visible)
	assert_false(flow.cancel())
	await _action(&"pause")
	GameClock.advance_minutes(900)
	assert_eq(GameClock.day_index,0)
	assert_true(flow.panel.visible)
	flow.confirm()
	flow.confirm()
	assert_eq(GameClock.day_index,1)

func test_real_trades_refunds_failed_purchase_and_review_save_restore() -> void:
	await _game()
	_trade()
	var flow: LifeDayEndFlow = _main.day_end_flow
	var buy: int = int(DataRegistry.get_item(&"turnip_seed").get("buy_price"))*4
	var sell: int = int(DataRegistry.get_item(&"turnip").get("sell_price"))*3
	assert_eq(flow.ledger.totals(),{"income":250+sell,"expense":buy,"profit":250+sell-buy})
	var journal: Dictionary = flow.ledger.serialize()
	assert_false(_main.seed_shop_panel.try_buy_item(&"turnip_seed",99999))
	assert_eq(flow.ledger.serialize(),journal)
	GameClock.set_time(20,0)
	assert_true(flow.request())
	var saved: Dictionary = SaveService.load_game(1)
	assert_eq(int(saved["meta"]["save_version"]),17)
	assert_true(flow.cancel())
	_main.call("_load_payload",saved)
	await _settle()
	assert_true(flow.panel.visible)
	assert_eq(flow.ledger.serialize(),journal)
	assert_true(GameClock.is_day_end_held())
	flow.confirm()
	var morning: Dictionary = SaveService.load_game(0)
	for repeat: int in range(2):
		_main.call("_load_payload",morning)
		flow.confirm()
		assert_eq(GameClock.day_index,1,"Completed snapshot never replays rollover")

func test_old_or_corrupt_history_is_not_reported_as_known_zero() -> void:
	await _game()
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v4.json"))
	_main.call("_load_payload",SaveService.migrate_4_to_5(old))
	assert_eq(_main.wallet.get_coins(),160)
	assert_false(_main.day_end_flow.ledger.complete)
	GameClock.set_time(20,0)
	assert_true(_main.day_end_flow.request())
	assert_eq(_main.day_end_flow.panel.ledger_view.note.text,tr("END_HISTORY_INCOMPLETE"))
	assert_true(_main.day_end_flow.cancel())
	old["day_ledger"] = ["bad"]
	old["day_end"] = {"phase":"bad"}
	_main.call("_load_payload",old)
	assert_false(_main.day_end_flow.ledger.complete)
	assert_false(_main.day_end_flow.panel.visible)

func test_language_changes_update_hidden_and_visible_summary() -> void:
	await _game()
	TranslationServer.set_locale("vi")
	GameClock.set_time(20,0)
	var flow: LifeDayEndFlow = _main.day_end_flow
	assert_true(flow.request())
	TranslationServer.set_locale("en")
	assert_eq(flow.panel.title.text,tr("END_TITLE") % (GameClock.day_index+1))
	assert_eq(flow.panel.continue_button.text,tr("END_NEXT_DAY"))
	assert_eq(flow.panel.ledger_view.heading.text,tr("END_LEDGER"))
	assert_true(flow.cancel())
	TranslationServer.set_locale("vi")
	assert_eq(flow.panel.stay_button.text,tr("END_STAY"))
	assert_true(flow.request())
	assert_eq(flow.panel.title.text,tr("END_TITLE") % (GameClock.day_index+1))

func _action(action: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	_viewport.push_input(event,true)
	await _settle()

func _click(button: Button) -> void:
	await _settle()
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
	for frame: int in range(8):
		await get_tree().process_frame
