## InventoryActions — stateless validated requests; InventoryState owns mutations.
## API:
##   static func sort(inventory: InventoryState) -> Array[int]
##   static func discard(inventory: InventoryState, index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool
class_name InventoryActions
extends RefCounted

static func sort(inventory: InventoryState) -> Array[int]:
	return InventoryService.sort(inventory,&"inventory_action") if inventory != null else []

static func discard(inventory: InventoryState, index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool:
	return inventory != null and InventoryService.discard(inventory,index,expected_id,expected_quantity,expected_revision,quantity,&"inventory_action")
