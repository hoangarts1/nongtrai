## WateringUpgradeFlow - transient Main-owned UI/command adapter, no persistent owner.
## API: configure(main), open(), close(), back_to_bag(), purchase(expected_capacity), refresh().
class_name WateringUpgradeFlow
extends Node

var panel: LifeWateringUpgradeScreen
var busy: bool = false
var model: Dictionary = {}
var result: Dictionary = {}
var _main: Node
var _queued: bool = false
var _layout_queued: bool = false

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/watering_upgrade/watering_upgrade_screen.tscn").instantiate() as LifeWateringUpgradeScreen
	panel.name = "WateringUpgrade"
	main.add_child(panel)
	panel.closed.connect(close)
	panel.backed.connect(back_to_bag)
	panel.purchased.connect(purchase)
	panel.visibility_changed.connect(_visibility_changed)
	panel.minimum_size_changed.connect(_queue_layout)
	main.wallet.coins_changed.connect(_coins_changed)
	main.watering_runtime.water_changed.connect(_water_changed)
	main.get_viewport().size_changed.connect(_layout)

func open() -> void:
	if bool(_main.call("_purchase_in_progress")) or not bool(_main.get("_game_started")) or GameClock.is_sleeping() or _main.day_end_flow.is_advancing():
		return
	if _main.ui_coordinator.get_active_panel()!=_main.inventory_panel or not _main.inventory_panel.controller._pending.is_empty():
		return
	result = {}
	panel.ensure_built()
	panel.show()
	refresh()
	_layout()
	panel.close_button.call_deferred("grab_focus")

func close() -> void:
	panel.hide()

func back_to_bag() -> void:
	if busy or not panel.visible or _main.ui_coordinator.get_active_panel()!=panel:
		return
	close()
	if bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.is_sleeping() and _main.ui_coordinator.get_active_panel()==null:
		_main.inventory_panel.toggle_inventory()

func purchase(expected_capacity: int) -> void:
	if bool(_main.call("_purchase_in_progress")) or not panel.visible or _main.ui_coordinator.get_active_panel()!=panel or GameClock.is_sleeping() or not bool(_main.get("_game_started")):
		return
	if model.is_empty() or expected_capacity!=int(model.capacity):
		return
	# An on-screen quote must not silently change its price or target at confirmation.
	var current: Dictionary = LifeWateringUpgradeSnapshot.capture(_main)
	if current.price!=model.price or current.target!=model.target:
		result = {"ok":false,"reason":&"stale_capacity"}
		refresh()
		return
	var before: Dictionary = _main.watering_can.serialize()
	busy = true
	result = _main.watering_upgrade.purchase(expected_capacity)
	busy = false
	# Notify only after the command finishes; rejected grants may preserve independent changes.
	if _main.watering_can.serialize()!=before:
		_main.watering_runtime.refresh()
	refresh()

func refresh() -> void:
	_queued = false
	if panel==null or not panel.visible:
		return
	model = LifeWateringUpgradeSnapshot.capture(_main)
	LifeWateringUpgradePresenter.render(panel,model,result)

func _queue_refresh() -> void:
	if not _queued and panel.visible:
		_queued = true
		call_deferred("refresh")

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		call_deferred("_layout")

func _layout() -> void:
	_layout_queued = false
	if panel==null or not panel.visible:
		return
	var viewport: Vector2 = panel.get_viewport_rect().size
	panel.size = Vector2(minf(820,viewport.x-64),minf(540,viewport.y-48))
	panel.position = (viewport-panel.size)*0.5

func _visibility_changed() -> void:
	if not panel.visible:
		model = {}
		result = {}
		panel.expected_capacity = -1

func _coins_changed(_total: int, _delta: int, reason: StringName) -> void:
	if reason==&"load" and not busy:
		close()
	else:
		_queue_refresh()

func _water_changed(_charges: int, _capacity: int) -> void:
	_queue_refresh()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and panel!=null:
		refresh()
