## ChickenCoopFlow — transient modal/layout/read-model adapter.
class_name ChickenCoopFlow
extends Node
var panel: LifeChickenCoopScreen
var model: Dictionary = {}
var result: Dictionary = {}
var _main: Node
var _queued: bool = false
var _layout_queued: bool = false

func configure(main: Node) -> void:
	_main = main
	panel = preload("res://ui/chicken_coop/chicken_coop_screen.tscn").instantiate() as LifeChickenCoopScreen
	main.add_child(panel)
	panel.minimum_size_changed.connect(_queue_layout)
	panel.closed.connect(close)
	panel.backed.connect(back_to_bag)
	panel.commanded.connect(command)
	main.chicken_coop_runtime.changed.connect(_queue_refresh)
	main.wallet.coins_changed.connect(func(_a: int,_b: int,_r: StringName) -> void: _queue_refresh())
	main.inventory.inventory_changed.connect(func(_slots: Array[Dictionary]) -> void: _queue_refresh())
	main.get_viewport().size_changed.connect(_layout)

func open() -> void:
	if _main.chicken_coop_runtime.context().is_empty() or bool(_main.call("_purchase_in_progress")):
		return
	panel.ensure_built()
	result = {}
	panel.show()
	refresh()
	_layout()
	panel.close_button.call_deferred("grab_focus")

func close() -> void:
	if _main.chicken_coop_runtime.busy or _main.chicken_coop.coop.is_busy():
		return
	panel.hide()

func back_to_bag() -> void:
	if not panel.visible or bool(_main.call("_purchase_in_progress")):
		return
	close()
	_main.inventory_panel.toggle_inventory()

func command(action: StringName, quantity: int) -> void:
	if not panel.visible or model.is_empty():
		return
	var current: Dictionary = LifeChickenCoopSnapshot.capture(_main)
	if current.price!=model.price or current.feed_price!=model.feed_price or current.hens!=model.hens:
		result = {"ok":false,"reason":&"stale_quantity"}
	else:
		result = _buy_feed_with_receipt(quantity) if action == &"buy_feed" else _main.chicken_coop_runtime.execute(action,quantity)
	refresh()

func _buy_feed_with_receipt(quantity: int) -> Dictionary:
	var runtime: ChickenCoopRuntime = _main.chicken_coop_runtime
	var config: ChickenCoopSiteConfig = ChickenCoopRuntime.CONFIG
	var near: bool = GrayBoxWorld.is_player_near_interactable(Vector2(_main.world.get_player_cell()), Vector2(config.entrance), _main.world.CONFIG.interaction_reach)
	if bool(_main.call("_purchase_in_progress")) or not bool(_main.get("_game_started")) or not near or GameClock.is_sleeping() or _main.ui_coordinator.get_active_panel() != panel:
		return ChickenCoopPurchaseRules.failure(&"invalid_context")
	var receipt: Dictionary = _main.director_activity_collector.begin_command(&"chicken_feed")
	if not receipt.ok:
		return ChickenCoopPurchaseRules.failure(&"invalid_context")
	# Reuse the exact existing shop command under the same runtime lock. Its public
	# execute() preflight rejects the collector lock, so this UI adapter owns entry.
	runtime.busy = true
	var purchased: Dictionary = runtime.shop.purchase(&"buy_feed", quantity, runtime.occupied_cells)
	runtime.busy = false
	runtime.refresh_site()
	_main.call("_mark_save_dirty")
	runtime.changed.emit()
	_main.director_activity_collector.finish_command(receipt.token, {"item_purchased": int(purchased.quantity)} if purchased.ok else {}, purchased.reason != &"settlement_failed")
	return purchased

func _queue_refresh() -> void:
	if not _queued and panel.visible:
		_queued = true
		call_deferred("refresh")

func refresh() -> void:
	_queued = false
	if panel==null or not panel.visible:
		return
	model = LifeChickenCoopSnapshot.capture(_main)
	LifeChickenCoopPresenter.render(panel,model,result)
	_layout()

func _queue_layout() -> void:
	if not _layout_queued:
		_layout_queued = true
		call_deferred("_layout")

func _layout() -> void:
	_layout_queued = false
	if panel==null or not panel.visible:
		return
	var viewport: Vector2 = panel.get_viewport_rect().size
	panel.size = Vector2(minf(1000,viewport.x-64),minf(600,viewport.y-48))
	panel.position = (viewport-panel.size)*0.5

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and panel!=null:
		refresh()
