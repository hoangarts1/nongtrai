## LifeMorningFlow — presentation-only queue after the existing completed rollover.
class_name LifeMorningFlow
extends Node

var panel: LifeMorningSheet
var _main: Node
var _pending_day: int = -1
var _last_shown: int = -1

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/morning/morning_sheet.tscn").instantiate() as LifeMorningSheet
	panel.name = "MorningBulletin"
	main.add_child(panel)
	panel.dismissed.connect(dismiss)
	reset()

func queue_day(day: int) -> void:
	if day == GameClock.day_index and day > _last_shown:
		_pending_day = day

func reset() -> void:
	_pending_day = -1
	_last_shown = GameClock.day_index
	if panel != null:
		panel.hide()

func dismiss() -> void:
	panel.hide()

func refresh() -> void:
	if panel != null and panel.visible:
		MorningPresenter.render(panel,MorningSnapshot.capture(_main))

func _process(_delta: float) -> void:
	if _main == null or _pending_day < 0:
		return
	if _pending_day != GameClock.day_index:
		_pending_day = -1
		return
	if not bool(_main.get("_game_started")) or _main.start_menu.visible or GameClock.is_sleeping():
		return
	if _main.day_end_flow.is_advancing() or _main.day_end_flow.panel.visible or _main.ui_coordinator.get_active_panel() != null:
		return
	MorningPresenter.render(panel,MorningSnapshot.capture(_main))
	panel.show()
	if panel.visible:
		_last_shown = _pending_day
		_pending_day = -1
		panel.begin_button.call_deferred("grab_focus")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and panel != null:
		refresh()
