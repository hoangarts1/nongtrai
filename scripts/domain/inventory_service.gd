## InventoryService — guarded mutations over the existing sole InventoryState.
## API: add/remove/clear/sort/discard; begin_transfer/finish_transfer;
## add_reserved/remove_reserved; is_busy. No new persistent state or item owner.
class_name InventoryService
extends RefCounted

static var _active: Dictionary[int, RefCounted] = {}

static func is_busy(inventory: InventoryState) -> bool:
	return inventory!=null and _active.has(inventory.get_instance_id())

static func begin_transfer(inventory: InventoryState, token: RefCounted) -> bool:
	if inventory==null or token==null or is_busy(inventory): return false
	_active[inventory.get_instance_id()] = token
	return true

static func finish_transfer(inventory: InventoryState, token: RefCounted) -> bool:
	if not _owns(inventory,token): return false
	_active.erase(inventory.get_instance_id())
	return true

static func add(inventory: InventoryState, id: StringName, quantity: int, reason: StringName) -> int:
	var token: RefCounted = RefCounted.new()
	if reason.is_empty() or not begin_transfer(inventory,token): return 0
	var added: int = add_reserved(inventory,token,id,quantity,reason)
	finish_transfer(inventory,token)
	return added

static func remove(inventory: InventoryState, id: StringName, quantity: int, reason: StringName) -> bool:
	var token: RefCounted = RefCounted.new()
	if reason.is_empty() or not begin_transfer(inventory,token): return false
	var removed: bool = remove_reserved(inventory,token,id,quantity,reason)
	finish_transfer(inventory,token)
	return removed

static func add_reserved(inventory: InventoryState, token: RefCounted, id: StringName, quantity: int, reason: StringName) -> int:
	if reason.is_empty() or not _owns(inventory,token) or id.is_empty() or quantity<=0 or quantity>InventoryState.MAX_JSON_INTEGER: return 0
	# Partial/custom adapter counts remain visible to their settlement owner.
	var added: int = inventory.add_item(id,quantity)
	if added>0: Log.debug(&"InventoryService","add %s x%d reason=%s" % [id,added,reason])
	return added

static func remove_reserved(inventory: InventoryState, token: RefCounted, id: StringName, quantity: int, reason: StringName) -> bool:
	if reason.is_empty() or not _owns(inventory,token) or id.is_empty() or quantity<=0 or quantity>InventoryState.MAX_JSON_INTEGER: return false
	var removed: bool = inventory.remove_item(id,quantity)
	if removed: Log.debug(&"InventoryService","remove %s x%d reason=%s" % [id,quantity,reason])
	return removed

static func clear(inventory: InventoryState, reason: StringName) -> bool:
	var token: RefCounted = RefCounted.new()
	if reason.is_empty() or not begin_transfer(inventory,token): return false
	var entries: int = inventory.get_slots().size()
	inventory.clear()
	Log.debug(&"InventoryService","clear entries=%d reason=%s" % [entries,reason])
	finish_transfer(inventory,token)
	return true

static func sort(inventory: InventoryState, reason: StringName) -> Array[int]:
	var token: RefCounted = RefCounted.new()
	if reason.is_empty() or not begin_transfer(inventory,token): return []
	var order: Array[int] = inventory.sort_slots()
	Log.debug(&"InventoryService","sort reason=%s" % reason)
	finish_transfer(inventory,token)
	return order

static func discard(inventory: InventoryState, index: int, id: StringName, expected_quantity: int, revision: int, quantity: int, reason: StringName) -> bool:
	var token: RefCounted = RefCounted.new()
	if reason.is_empty() or not begin_transfer(inventory,token): return false
	var removed: bool = inventory.discard_from_slot(index,id,expected_quantity,revision,quantity)
	if removed: Log.debug(&"InventoryService","discard %s x%d reason=%s" % [id,quantity,reason])
	finish_transfer(inventory,token)
	return removed

static func _owns(inventory: InventoryState, token: RefCounted) -> bool:
	return inventory!=null and token!=null and _active.get(inventory.get_instance_id())==token
