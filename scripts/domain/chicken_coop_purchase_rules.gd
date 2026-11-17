## ChickenCoopPurchaseRules — pure geometry and integer cost preflight.
## API: static clear_site(config,cells), failure(reason), feed_price(item,quantity).
class_name ChickenCoopPurchaseRules
extends RefCounted

static func clear_site(config: ChickenCoopSiteConfig, cells: Array[Vector2i]) -> bool:
	for cell: Vector2i in cells:
		if config.footprint.has_point(cell):
			return false
	return true

static func failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}

static func feed_price(item: ItemData, quantity: int) -> int:
	if item==null or item.buy_price<=0 or quantity<=0 or quantity>item.max_stack or item.buy_price>ChickenCoopConfig.MAX_JSON_INTEGER/quantity:
		return -1
	return item.buy_price*quantity
