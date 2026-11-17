## LifeBagUpgradeSnapshot - detached reads; no currency or item mutation.
class_name LifeBagUpgradeSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var current: int = main.inventory.capacity
	var quote: Dictionary = main.bag_upgrade.can_purchase(current)
	return {"capacity":current,"target":maxi(current,int(quote.get("target",current))),"price":int(quote.get("price",0)),"coins":main.wallet.get_coins(),"can_buy":bool(quote.ok),"reason":quote.reason}
