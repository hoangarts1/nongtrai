## LifeLandSnapshot ? detached reads from actual owners; never buys or grants.
class_name LifeLandSnapshot
extends RefCounted

static func owned_cells(state: LandOwnershipState) -> int:
	var count: int = 0
	for region: Rect2i in state.get_owned_regions():
		count += region.get_area()
	return count

static func capture(main: Node) -> Dictionary:
	var config: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
	var id: StringName = main.land_ownership.next_parcel_id()
	var model: Dictionary = {"id":id,"owned":owned_cells(main.land_ownership),"coins":main.wallet.get_coins(),"name":&"LAND_COMPLETE","extra":0,"price":0,"reason":&"no_available_parcel","can_buy":false}
	if id.is_empty():
		return model
	for parcel: ExpansionParcelData in config.parcels:
		if parcel.parcel_id==id:
			model.name = parcel.display_name_key
			model.extra = parcel.region.get_area()
	var quote: Dictionary = LandExpansionRules.quote_cost(config,main.land_ownership.get_owned_ids().size()+1)
	model.price = int(quote.get("price",0))
	var available: Dictionary = main.land_expansion.can_purchase(id)
	model.can_buy = bool(available.ok)
	model.reason = available.reason
	return model
