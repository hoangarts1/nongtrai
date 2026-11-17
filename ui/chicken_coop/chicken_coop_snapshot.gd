## LifeChickenCoopSnapshot — read-only real owner projection.
class_name LifeChickenCoopSnapshot
extends RefCounted
static func capture(main: Node) -> Dictionary:
	var config: ChickenCoopSiteConfig = main.chicken_coop_runtime.CONFIG
	var state: Dictionary = main.chicken_coop.coop.serialize()
	var item: ItemData = DataRegistry.get_item(config.coop_config.feed_item_id) as ItemData
	var room: int = 0
	if item!=null:
		for quantity: int in range(1,item.max_stack+1):
			if not main.inventory.can_add_item(item.item_id,quantity):
				break
			room = quantity
	return {"owned":main.chicken_coop.is_owned(),"day":int(state.current_day)+1,"hens":state.hen_count,"fed":state.fed_hens,"eggs":state.pending_eggs,"food":main.inventory.get_quantity(config.coop_config.feed_item_id),"coins":main.wallet.get_coins(),"price":config.purchase_price,"initial_hens":config.initial_hens,"feed_price":item.buy_price if item!=null else 0,"stack_limit":item.max_stack if item!=null else 0,"feed_units":config.coop_config.feed_per_hen,"food_room":room,"buy":main.chicken_coop_runtime.shop.quote(&"buy_coop",config.initial_hens,main.chicken_coop_runtime.occupied_cells()),"collect":main.chicken_coop_runtime.collection.can_collect(int(state.pending_eggs))}
