## ChickenCoopFeedingService — stateless actual-feed debit and reserved-hen grant.
## API:
##   func configure(state: ChickenCoopState, inventory: InventoryState) -> void
##   func can_feed(day_index: int, hens_to_feed: int) -> Dictionary
##   func feed(day_index: int, hens_to_feed: int) -> Dictionary
class_name ChickenCoopFeedingService
extends RefCounted

var _state: ChickenCoopState
var _inventory: InventoryState

func configure(state: ChickenCoopState, inventory: InventoryState) -> void:
	_state = state
	_inventory = inventory

func can_feed(day_index: int, hens_to_feed: int) -> Dictionary:
	return _quote(_state,_inventory,day_index,hens_to_feed)

func feed(day_index: int, hens_to_feed: int) -> Dictionary:
	var state: ChickenCoopState = _state
	var inventory: InventoryState = _inventory
	var preview: Dictionary = _quote(state,inventory,day_index,hens_to_feed)
	if not bool(preview.ok):
		return preview
	var reserved: Dictionary = state.begin_feeding(day_index,hens_to_feed)
	if not bool(reserved.ok):
		return reserved
	var item_id: StringName = StringName(reserved.item_id)
	var units: int = int(reserved.feed_units)
	var debited: bool = inventory.remove_item(item_id,units)
	if not state.finish_feeding(reserved.token as RefCounted,debited):
		return _failure(&"settlement_failed")
	return {"ok":debited,"reason":&"fed" if debited else &"debit_rejected","item_id":item_id,"feed_units":units if debited else 0,"hens_fed":hens_to_feed if debited else 0,"fed_hens":int(state.serialize().fed_hens)}

func _quote(state: ChickenCoopState, inventory: InventoryState, day_index: int, hens_to_feed: int) -> Dictionary:
	if state==null or inventory==null:
		return _failure(&"invalid_state")
	var quote: Dictionary = state.feeding_quote(day_index,hens_to_feed)
	if not bool(quote.ok):
		return quote
	var item_id: StringName = StringName(quote.item_id)
	var item: ItemData = DataRegistry.get_item(item_id) as ItemData
	if item==null or item.item_id!=item_id or item.max_stack<=0:
		return _failure(&"unknown_feed")
	if not inventory.has_item(item_id,int(quote.feed_units)):
		return _failure(&"missing_feed")
	return quote

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
