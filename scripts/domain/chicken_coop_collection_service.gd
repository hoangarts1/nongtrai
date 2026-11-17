## ChickenCoopCollectionService — stateless adapter over actual coop/bag owners.
## API:
##   func configure(state: ChickenCoopState, inventory: InventoryState) -> void
##   func can_collect(expected_quantity: int) -> Dictionary
##   func collect(expected_quantity: int) -> Dictionary
class_name ChickenCoopCollectionService
extends RefCounted

var _state: ChickenCoopState
var _inventory: InventoryState

func configure(state: ChickenCoopState, inventory: InventoryState) -> void:
	_state = state
	_inventory = inventory

func can_collect(expected_quantity: int) -> Dictionary:
	return _quote(_state,_inventory,expected_quantity)

func collect(expected_quantity: int) -> Dictionary:
	# Callbacks may configure this facade again; this transfer keeps its original owners.
	var state: ChickenCoopState = _state
	var inventory: InventoryState = _inventory
	var preview: Dictionary = _quote(state,inventory,expected_quantity)
	if not bool(preview.ok):
		return preview
	var reserved: Dictionary = state.begin_collection(expected_quantity)
	if not bool(reserved.ok):
		return reserved
	var item_id: StringName = StringName(reserved.item_id)
	var quantity: int = int(reserved.quantity)
	var added: int = inventory.add_item(item_id,quantity)
	var remaining: int = quantity-added
	if not state.finish_collection(reserved.token as RefCounted,remaining):
		# A broken added-count contract cannot safely be guessed or paid out twice.
		return _failure(&"settlement_failed")
	var reason: StringName = &"collected" if remaining==0 else (&"transfer_rejected" if added==0 else &"partial_transfer")
	return {"ok":remaining==0,"reason":reason,"item_id":item_id,"quantity":added,"remaining":remaining}

func _quote(state: ChickenCoopState, inventory: InventoryState, expected_quantity: int) -> Dictionary:
	if state==null or inventory==null:
		return _failure(&"invalid_state")
	var quote: Dictionary = state.collection_quote(expected_quantity)
	if not bool(quote.ok):
		return quote
	var item_id: StringName = StringName(quote.item_id)
	var item: ItemData = DataRegistry.get_item(item_id) as ItemData
	if item==null or item.item_id!=item_id or item.max_stack<=0:
		return _failure(&"unknown_item")
	if not inventory.can_add_item(item_id,int(quote.quantity)):
		return _failure(&"inventory_full")
	return quote

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
