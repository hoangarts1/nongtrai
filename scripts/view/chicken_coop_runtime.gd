## ChickenCoopRuntime — Main-owned application commands; domain owns all persistent values.
## API: configure(main), context(), occupied_cells(), execute(action,quantity), restore(payload), reset(), refresh_site().
class_name ChickenCoopRuntime
extends Node
signal changed()
const CONFIG: ChickenCoopSiteConfig = preload("res://data/chicken_coop_site.tres")
var busy: bool = false
var simulator: DaySimulator = DaySimulator.new()
var shop: ChickenCoopShopService = ChickenCoopShopService.new()
var feeding: ChickenCoopFeedingService = ChickenCoopFeedingService.new()
var collection: ChickenCoopCollectionService = ChickenCoopCollectionService.new()
var site: ChickenCoopSiteView
var _main: Node

func configure(main: Node) -> void:
	_main = main
	main.chicken_coop.configure(CONFIG.coop_config,GameClock.day_index)
	shop.configure(CONFIG,main.chicken_coop,main.inventory,main.wallet)
	feeding.configure(main.chicken_coop.coop,main.inventory)
	collection.configure(main.chicken_coop.coop,main.inventory)
	main.world.configure_chicken_coop(context,func() -> void: main.chicken_coop_flow.open())
	site = ChickenCoopSiteView.new()
	site.name = "ChickenCoopSite"
	main.world.objects.add_child(site)
	site.configure(main.world,main.chicken_coop,CONFIG)

func context() -> Dictionary:
	if not bool(_main.get("_game_started")) or busy or _main.chicken_coop.coop.is_busy() or GameClock.is_sleeping() or not _main.world.player.movement_enabled:
		return {}
	if _main.ui_coordinator!=null and _main.ui_coordinator.get_active_panel()!=null:
		return {}
	return {"site_id":CONFIG.site_id} if _near() else {}

func _near() -> bool:
	return GrayBoxWorld.is_player_near_interactable(Vector2(_main.world.get_player_cell()),Vector2(CONFIG.entrance),_main.world.CONFIG.interaction_reach)

func occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = [_main.world.get_player_cell()]
	for value: Variant in _main.npc_system.state.cells.values():
		cells.append(value as Vector2i)
	for y: int in range(CONFIG.footprint.position.y,CONFIG.footprint.end.y):
		for x: int in range(CONFIG.footprint.position.x,CONFIG.footprint.end.x):
			var cell: Vector2i = Vector2i(x,y)
			if not _main.farm_state.get_plot(cell).is_empty():
				cells.append(cell)
	for row: Dictionary in _main.machine_placements.get_all_placements():
		cells.append(row.cell as Vector2i)
	return cells

func execute(action: StringName, quantity: int) -> Dictionary:
	if bool(_main.call("_purchase_in_progress")) or not bool(_main.get("_game_started")) or not _near() or GameClock.is_sleeping() or _main.ui_coordinator.get_active_panel()!=_main.chicken_coop_flow.panel:
		return ChickenCoopPurchaseRules.failure(&"invalid_context")
	busy = true
	var result: Dictionary
	if action==&"buy_coop" or action==&"buy_feed":
		result = shop.purchase(action,quantity,occupied_cells)
	elif not _main.chicken_coop.is_owned():
		result = ChickenCoopPurchaseRules.failure(&"not_owned")
	elif action==&"feed":
		result = feeding.feed(GameClock.day_index,quantity)
	elif action==&"collect":
		result = collection.collect(quantity)
	else:
		result = ChickenCoopPurchaseRules.failure(&"invalid_action")
	busy = false
	refresh_site()
	_main.call("_mark_save_dirty")
	changed.emit()
	return result

func prepare_restore() -> void:
	_main.chicken_coop_flow.close()
	var empty: Array[Rect2i] = []
	_main.npc_system.set_dynamic_obstacles(empty)

func reset() -> void:
	_main.chicken_coop.configure(CONFIG.coop_config,GameClock.day_index)
	refresh_site()

func restore(payload: Dictionary) -> void:
	_main.chicken_coop.configure(CONFIG.coop_config,GameClock.day_index)
	_main.chicken_coop.deserialize(ChickenCoopSaveCodec.normalize(payload.get("chicken_coop"),GameClock.day_index,CONFIG.coop_config))
	refresh_site()

func refresh_site() -> void:
	site.refresh()
	var regions: Array[Rect2i] = []
	if _main.chicken_coop.is_owned():
		regions.append(CONFIG.footprint)
	_main.npc_system.set_dynamic_obstacles(regions)
