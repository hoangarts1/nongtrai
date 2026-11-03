## LifeDayEndFlow — one application path from review to the existing morning simulation.
class_name LifeDayEndFlow
extends Node

var ledger: DayLedgerState = DayLedgerState.new()
var state: DayEndState = DayEndState.new()
var panel: LifeDayEndSheet
var _main: Node

func configure(main: Node) -> void:
	_main = main
	ledger.reset(GameClock.day_index)
	panel = preload("res://ui/day_end/day_end_sheet.tscn").instantiate() as LifeDayEndSheet
	panel.name = "DayEndSheet"
	main.add_child(panel)
	panel.confirmed.connect(confirm)
	panel.cancelled.connect(cancel)
	main.world.bed_requested.connect(request)
	GameClock.day_end_requested.connect(_cutoff)
	main.wallet.coins_changed.connect(_money_changed)
	Events.item_sold.connect(_sold)
	Events.item_purchased.connect(_bought)

func request(automatic: bool = false) -> bool:
	if not bool(_main.get("_game_started")) or GameClock.is_sleeping():
		return false
	if not automatic and not GameClock.can_sleep():
		return false
	if not state.review(GameClock.day_index,automatic):
		return false
	GameClock.hold_day_end(GameClock.day_index)
	_main.ui_coordinator.close_active()
	_refresh()
	panel.show()
	_main._save_game_to_slot(1)
	return true

func cancel() -> bool:
	if not state.cancel():
		return false
	GameClock.release_day_end(GameClock.day_index)
	panel.hide()
	_main._save_game_to_slot(1)
	return true

func confirm() -> void:
	if not state.confirm(GameClock.day_index):
		return
	panel.continue_button.disabled = true
	# Existing Main.day_started remains the only simulation path. Guard stays set
	# throughout all synchronous callbacks, including attempted re-entrant confirms.
	GameClock.sleep_started.emit()
	GameClock.sleep_to_morning()
	GameClock.sleep_finished.emit(GameClock.day_index)
	state.reconcile(GameClock.day_index)
	panel.hide()
	_main._save_game_to_slot(0)

func is_advancing() -> bool:
	return state.phase == DayEndState.Phase.ADVANCING

func on_morning(day: int) -> void:
	ledger.reset(day)
	if not is_advancing():
		state.reconcile(day)
		panel.hide()

func reset() -> void:
	GameClock.release_day_end(GameClock.day_index)
	ledger.reset(GameClock.day_index)
	state = DayEndState.new()
	panel.hide()

func restore(payload: Dictionary) -> void:
	panel.hide()
	var raw_ledger: Variant = payload.get("day_ledger",{})
	ledger.deserialize(raw_ledger if raw_ledger is Dictionary else {})
	if ledger.day_index != GameClock.day_index:
		ledger.reset(GameClock.day_index,false)
	var raw_state: Variant = payload.get("day_end",{})
	state.deserialize(raw_state if raw_state is Dictionary else {})
	state.reconcile(GameClock.day_index)
	if GameClock.minute >= GameClock.DAY_END_MINUTE and state.phase == DayEndState.Phase.IDLE:
		state.review(GameClock.day_index,true)
	if state.phase == DayEndState.Phase.REVIEW:
		state.forced = state.forced or GameClock.minute >= GameClock.DAY_END_MINUTE
		if not state.forced and not GameClock.can_sleep():
			state.cancel()
			return
		GameClock.hold_day_end(GameClock.day_index)
		_refresh()
		panel.show()

func _cutoff(_day: int) -> void:
	request(true)

func _money_changed(_total: int, delta: int, reason: StringName) -> void:
	if bool(_main.get("_game_started")):
		ledger.record(delta,reason)
		if panel.visible:
			_refresh()

func _sold(id: StringName, quantity: int, total: int) -> void:
	ledger.annotate_trade(&"sell_produce",id,quantity,total)

func _bought(id: StringName, quantity: int, total: int) -> void:
	ledger.annotate_trade(&"buy_seed",id,quantity,total)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and panel != null and panel.visible:
		_refresh()

func _refresh() -> void:
	LifeDayEndPresenter.render(panel,ledger,_main,state.forced)
