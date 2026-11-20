## ChickenCoopShopService — reserved actual wallet purchases for coop and food.
## API: configure(config,holding,inventory,wallet), quote(action,quantity,occupied), purchase(action,quantity,occupancy).
class_name ChickenCoopShopService
extends RefCounted
var _config: ChickenCoopSiteConfig
var _holding: ChickenCoopHoldingState
var _inventory: InventoryState
var _wallet: WalletState

func configure(config: ChickenCoopSiteConfig, holding: ChickenCoopHoldingState, inventory: InventoryState, wallet: WalletState) -> void:
	_config = config
	_holding = holding
	_inventory = inventory
	_wallet = wallet

func quote(action: StringName, quantity: int, occupied: Array[Vector2i]) -> Dictionary:
	if _config==null or _holding==null or _inventory==null or _wallet==null or not _config.validation_errors().is_empty():
		return ChickenCoopPurchaseRules.failure(&"invalid_state")
	if _holding.coop.is_busy():
		return ChickenCoopPurchaseRules.failure(&"purchase_busy")
	var price: int = _config.purchase_price
	if action==&"buy_coop":
		if _holding.is_owned():
			return ChickenCoopPurchaseRules.failure(&"already_owned")
		if quantity!=_config.initial_hens or not ChickenCoopPurchaseRules.clear_site(_config,occupied):
			return ChickenCoopPurchaseRules.failure(&"occupied")
	elif action==&"buy_feed":
		if not _holding.is_owned():
			return ChickenCoopPurchaseRules.failure(&"not_owned")
		var item: ItemData = DataRegistry.get_item(_config.coop_config.feed_item_id) as ItemData
		price = ChickenCoopPurchaseRules.feed_price(item,quantity) if item!=null and item.item_id==_config.coop_config.feed_item_id else -1
		if price<0:
			return ChickenCoopPurchaseRules.failure(&"invalid_quantity")
		if not _inventory.can_add_item(item.item_id,quantity):
			return ChickenCoopPurchaseRules.failure(&"inventory_full")
	else:
		return ChickenCoopPurchaseRules.failure(&"invalid_action")
	if not _wallet.can_afford(price):
		return ChickenCoopPurchaseRules.failure(&"insufficient_coins")
	return {"ok":true,"reason":&"ready","price":price,"quantity":quantity}

func purchase(action: StringName, quantity: int, occupancy: Callable) -> Dictionary:
	var cells: Array[Vector2i] = occupancy.call() if occupancy.is_valid() else []
	if not occupancy.is_valid():
		return ChickenCoopPurchaseRules.failure(&"invalid_context")
	var terms: Dictionary = quote(action,quantity,cells)
	if not bool(terms.ok):
		return terms
	var config: ChickenCoopSiteConfig = _config
	var holding: ChickenCoopHoldingState = _holding
	var inventory: InventoryState = _inventory
	var wallet: WalletState = _wallet
	var price: int = int(terms.price)
	var hens: int = config.initial_hens
	var footprint: Rect2i = config.footprint
	var entrance: Vector2i = config.entrance
	var food: StringName = config.coop_config.feed_item_id
	var reservation: Dictionary = holding.begin_purchase(hens) if action==&"buy_coop" else holding.coop.begin_shop()
	if not bool(reservation.ok):
		return reservation
	var token: RefCounted = reservation.token
	var reason: StringName = &"buy_chicken_coop" if action==&"buy_coop" else &"buy_chicken_feed"
	var paid: bool = EconomyService.debit(wallet,price,reason,true)
	var valid: bool = paid and config.validation_errors().is_empty()
	if action==&"buy_coop":
		valid = valid and config.footprint==footprint and config.entrance==entrance and config.purchase_price==price and config.initial_hens==hens and ChickenCoopPurchaseRules.clear_site(config,occupancy.call())
	else:
		var item: ItemData = DataRegistry.get_item(food) as ItemData
		valid = valid and item!=null and item.item_id==food and config.coop_config.feed_item_id==food and ChickenCoopPurchaseRules.feed_price(item,quantity)==price and inventory.can_add_item(food,quantity)
	var added: int = 0
	if valid and action==&"buy_feed":
		added = InventoryService.add(inventory,food,quantity,&"buy_chicken_food")
		if added!=quantity and added!=0:
			# Unknown inventory implementations must not turn transferred food into a free refund.
			return ChickenCoopPurchaseRules.failure(&"settlement_failed")
		valid = added==quantity
	if paid and not valid:
		EconomyService.credit(wallet,price,StringName(String(reason)+"_rollback"),true)
	var settled: bool = holding.finish_purchase(token,valid) if action==&"buy_coop" else holding.coop.finish_shop(token,valid)
	if not settled:
		return ChickenCoopPurchaseRules.failure(&"settlement_failed")
	return {"ok":valid,"reason":&"purchased" if valid else &"grant_rejected","price":price if valid else 0,"quantity":quantity if valid else 0}
