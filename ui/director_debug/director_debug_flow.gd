## LifeDirectorDebugFlow - guarded commands and read-only coalesced modal display.
class_name LifeDirectorDebugFlow
extends Node

var panel: LifeDirectorDebugSheet
var model: Dictionary = {}
var result: StringName = &""
var busy: bool = false
var _main: Node
var _queued: bool = false

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/director_debug/director_sheet.tscn").instantiate() as LifeDirectorDebugSheet
	main.add_child(panel)
	panel.closed.connect(close)
	panel.enabled_requested.connect(set_enabled)
	panel.force_requested.connect(queue_force)
	main.director_activity.activity_changed.connect(queue_refresh)
	main.director_state.director_changed.connect(queue_refresh)
	main.ecology_state.ecology_changed.connect(queue_refresh)
	main.weather_state.weather_changed.connect(queue_refresh)
	main.get_viewport().size_changed.connect(_layout)
	main.debug_menu.register_action(tr("DIR_DEBUG_ENTRY"), open, &"DIR_DEBUG_ENTRY")

func _can_open() -> bool:
	return OS.is_debug_build() and _main.director_runtime.authorization_allowed() and bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.is_sleeping() and not GameClock.is_day_end_held() and not bool(_main.call("_purchase_in_progress"))

func open() -> bool:
	if busy or not _can_open():
		return false
	_main.ui_coordinator.close_active()
	result = &""
	panel.show()
	refresh()
	panel.close_button.call_deferred("grab_focus")
	return panel.visible

func close() -> void:
	if not busy and not bool(_main.call("_purchase_in_progress")):
		panel.hide()

func reset() -> void:
	panel.hide()
	model = {}
	result = &""

func set_enabled(value: bool) -> bool:
	if busy or not panel.visible or _main.ui_coordinator.get_active_panel() != panel or not _can_open():
		return false
	busy = true
	var changed: bool = _main.director_runtime.set_enabled(value)
	busy = false
	result = &"DIR_DEBUG_ENABLED" if changed and value else (&"DIR_DEBUG_DISABLED" if changed else &"DIR_DEBUG_BLOCKED")
	refresh()
	return changed

func queue_force(id: StringName) -> bool:
	if busy or not panel.visible or _main.ui_coordinator.get_active_panel() != panel or not _can_open():
		return false
	var current: Dictionary = LifeDirectorDebugSnapshot.capture(_main)
	var eligible: bool = id.is_empty() and current.enabled and not String(current.forced).is_empty()
	for row: Dictionary in current.candidates:
		if row.id == String(id):
			eligible = current.ready and current.can_control and row.eligible
	if not eligible:
		result = &"DIR_DEBUG_BLOCKED"
		refresh()
		return false
	busy = true
	var queued: bool = _main.director_runtime.queue_force(id)
	busy = false
	result = (&"DIR_DEBUG_CLEARED" if id.is_empty() else &"DIR_DEBUG_QUEUED") if queued else &"DIR_DEBUG_BLOCKED"
	refresh()
	return queued

func queue_refresh(_value: Variant = null) -> void:
	if not _queued and panel.visible:
		_queued = true
		call_deferred("refresh")

func refresh() -> void:
	_queued = false
	if panel == null or not panel.visible:
		return
	model = LifeDirectorDebugSnapshot.capture(_main)
	LifeDirectorDebugPresenter.render(panel, model, result)
	_layout()

func _layout() -> void:
	if panel != null and panel.visible:
		var viewport: Vector2 = panel.get_viewport_rect().size
		panel.size = Vector2(minf(1200, viewport.x - 64), minf(760, viewport.y - 48))
		panel.position = (viewport - panel.size) * 0.5

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and panel != null:
		queue_refresh()
