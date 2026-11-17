## LifeWateringUpgradeSnapshot - detached actual water/wallet and configured terms.
class_name LifeWateringUpgradeSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var current: int = main.watering_can.get_capacity()
	var quote: Dictionary = main.watering_upgrade.can_purchase(current)
	var config: WateringCanConfig = main.watering_upgrade_config
	return {"capacity":current,"charges":main.watering_can.get_charges(),"target":config.upgrade_capacity,"price":config.upgrade_price,"coins":main.wallet.get_coins(),"can_buy":bool(quote.ok),"reason":quote.reason}
