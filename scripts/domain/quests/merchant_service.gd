## MerchantService — deterministic daily trade with finite saved stock.
## API:
##   func get_offer(day: int, season: StringName) -> MerchantOfferData
##   func confirm_trade(day: int, season: StringName, available: bool, inventory: InventoryState, wallet: WalletState) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name MerchantService
extends RefCounted

var offers: Array[Resource] = []
var world_seed: int = 0
var _consumed_days: Array[int] = []
var _busy: bool = false

func get_offer(day: int, season: StringName) -> MerchantOfferData:
	var eligible: Array[MerchantOfferData] = []
	for resource: Resource in offers:
		var offer: MerchantOfferData = resource as MerchantOfferData
		if offer != null and (offer.seasons.is_empty() or offer.seasons.has(String(season))):
			eligible.append(offer)
	if eligible.is_empty():
		return null
	var rng: RandomNumberGenerator = DetRandom.make_rng(world_seed, day, DetRandom.TAG_MERCHANT)
	return eligible[rng.randi_range(0, eligible.size() - 1)]

func is_consumed(day: int) -> bool:
	return _consumed_days.has(day)

func confirm_trade(day: int, season: StringName, available: bool, inventory: InventoryState, wallet: WalletState) -> bool:
	if _busy or not available or is_consumed(day) or day < 0 or inventory == null or wallet == null:
		return false
	var offer: MerchantOfferData = get_offer(day, season)
	if offer == null or offer.quantity <= 0 or offer.unit_price <= 0 or DataRegistry.get_item(offer.item_id) == null:
		return false
	var total: int = offer.quantity * offer.unit_price
	var snapshot: Dictionary = inventory.serialize()
	if offer.kind == "discount":
		if not wallet.can_afford(total) or not inventory.can_add_item(offer.item_id, offer.quantity):
			return false
	elif offer.kind == "request":
		if not inventory.has_item(offer.item_id, offer.quantity):
			return false
	else:
		return false
	_busy = true
	if offer.kind == "discount":
		if not wallet.remove_coins(total, &"minh_discount"):
			_busy = false
			return false
		if inventory.add_item(offer.item_id, offer.quantity) != offer.quantity:
			inventory.deserialize(snapshot)
			wallet.add_coins(total, &"minh_rollback")
			_busy = false
			return false
	else:
		if not inventory.remove_item(offer.item_id, offer.quantity):
			_busy = false
			return false
		wallet.add_coins(total, &"minh_request")
	_consumed_days.append(day)
	_busy = false
	return true

func serialize() -> Dictionary:
	return {"world_seed": world_seed, "consumed_days": _consumed_days.duplicate()}

func deserialize(data: Dictionary) -> void:
	var seed_value: Variant = data.get("world_seed", 0)
	world_seed = int(seed_value) if seed_value is int or seed_value is float else 0
	_consumed_days.clear()
	var days: Variant = data.get("consumed_days", [])
	if days is Array:
		for value: Variant in days:
			if (value is int or value is float) and int(value) >= 0 and not _consumed_days.has(int(value)):
				_consumed_days.append(int(value))
