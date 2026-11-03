## InventoryActions — stateless validated requests; InventoryState owns mutations.
## API:
##   static func sort(inventory: InventoryState) -> Array[int]
##   static func discard(inventory: InventoryState, index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool
class_name InventoryActions
extends RefCounted

static func sort(inventory: InventoryState) -> Array[int]:
	return inventory.sort_slots() if inventory != null else []

static func discard(inventory: InventoryState, index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool:
	return inventory != null and inventory.discard_from_slot(index,expected_id,expected_quantity,expected_revision,quantity)
