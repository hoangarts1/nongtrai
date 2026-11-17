## LandRuntime ? Main-owned land command/lifecycle adapter; transient UI only.
## API: configure(main), open(), close(), purchase(parcel_id), restore(data), refresh().
class_name LandRuntime
extends Node

var panel: LifeLandScreen
var busy: bool = false
var model: Dictionary = {}
var result: Dictionary = {}
var _main: Node
var _queued: bool = false
var _layout_queued: bool = false

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/land/land_screen.tscn").instantiate() as LifeLandScreen
	panel.name = "LandExpansion"
	main.add_child(panel)
	panel.closed.connect(close)
	panel.purchased.connect(purchase)
	panel.visibility_changed.connect(_visibility_changed)
	panel.minimum_size_changed.connect(_queue_layout)
	main.wallet.coins_changed.connect(_coins_changed)
	main.get_viewport().size_changed.connect(_layout)

func open() -> void:
	if bool(_main.call("_purchase_in_progress")) or not OS.is_debug_build() or not bool(_main.get("_game_started")) or GameClock.is_sleeping() or _main.day_end_flow.is_advancing():
		return
	if _main.machine_shop_panel==null or _main.ui_coordinator.get_active_panel()!=_main.machine_shop_panel or _main.machine_shop_panel.controller.operation_mode:
		return
	result = {}
	panel.ensure_built()
	panel.show()
	refresh()
	_layout()
	panel.close_button.call_deferred("grab_focus")

func close() -> void:
	panel.hide()

func restore(data: Dictionary) -> void:
	if bool(_main.call("_purchase_in_progress")):
		return
	close()
	_main.land_ownership.deserialize(data)
	_refresh_world()

func purchase(parcel_id: StringName) -> void:
	if bool(_main.call("_purchase_in_progress")) or not panel.visible or _main.ui_coordinator.get_active_panel()!=panel or GameClock.is_sleeping() or not bool(_main.get("_game_started")):
		return
	if model.is_empty() or parcel_id.is_empty() or parcel_id!=StringName(model.id):
		return
	busy = true
	result = _main.land_expansion.purchase(parcel_id)
	if bool(result.ok):
		_refresh_world()
		_main.call("_mark_save_dirty")
	busy = false
	refresh()

func refresh() -> void:
	_queued = false
	if _main==null or panel==null or not panel.visible:
		return
	model = LifeLandSnapshot.capture(_main)
	LifeLandPresenter.render(panel,model,result)

func _refresh_world() -> void:
	if _main.presentation!=null:
		_main.presentation.refresh_land(_main.land_ownership.get_owned_regions())

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		call_deferred("_layout")

func _layout() -> void:
	_layout_queued = false
	if panel==null or not panel.visible:
		return
	var viewport: Vector2 = panel.get_viewport_rect().size
	panel.size = Vector2(minf(820,viewport.x-64),minf(580,viewport.y-48))
	panel.position = (viewport-panel.size)*0.5

func _visibility_changed() -> void:
	if not panel.visible:
		model = {}
		result = {}
		panel.expected_id = &""

func _coins_changed(_total: int, _delta: int, reason: StringName) -> void:
	if reason==&"load" and not busy:
		close()
	elif panel.visible and not _queued:
		_queued = true
		call_deferred("refresh")

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and _main!=null:
		refresh()
