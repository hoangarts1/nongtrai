## InventoryState — slot-limited, stackable inventory domain state.
## API:
##   func add_item(item_id: StringName, quantity: int) -> int
##   func remove_item(item_id: StringName, quantity: int) -> bool
##   func has_item(item_id: StringName, quantity: int = 1) -> bool
##   func get_quantity(item_id: StringName) -> int
##   func clear() -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name InventoryState
extends RefCounted

signal inventory_changed(slots: Array[Dictionary])
signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)

var capacity: int
var _slots: Array[Dictionary] = []

func _init(max_slots: int = 12) -> void:
	capacity = maxi(1, max_slots)

func add_item(item_id: StringName, quantity: int) -> int:
	if quantity <= 0 or DataRegistry.get_item(item_id) == null:
		return 0
	var item_data: Resource = DataRegistry.get_item(item_id)
	var remaining: int = quantity
	for slot: Dictionary in _slots:
		if slot["item_id"] == item_id and int(slot["quantity"]) < int(item_data.get("max_stack")):
			var added: int = mini(remaining, int(item_data.get("max_stack")) - int(slot["quantity"]))
			slot["quantity"] = int(slot["quantity"]) + added
			remaining -= added
			if remaining == 0:
				break
	while remaining > 0 and _slots.size() < capacity:
		var stack_quantity: int = mini(remaining, int(item_data.get("max_stack")))
		_slots.append({"item_id": item_id, "quantity": stack_quantity})
		remaining -= stack_quantity
	var added_total: int = quantity - remaining
	if added_total > 0:
		_emit_changed()
		item_added.emit(item_id, added_total)
		Events.item_added.emit(item_id, added_total)
	return added_total

func remove_item(item_id: StringName, quantity: int) -> bool:
	if quantity <= 0 or not has_item(item_id, quantity):
		return false
	var remaining: int = quantity
	for index: int in range(_slots.size() - 1, -1, -1):
		var slot: Dictionary = _slots[index]
		if slot["item_id"] != item_id:
			continue
		var removed: int = mini(remaining, int(slot["quantity"]))
		slot["quantity"] = int(slot["quantity"]) - removed
		remaining -= removed
		if int(slot["quantity"]) == 0:
			_slots.remove_at(index)
		if remaining == 0:
			break
	_emit_changed()
	item_removed.emit(item_id, quantity)
	Events.item_removed.emit(item_id, quantity)
	return true

func has_item(item_id: StringName, quantity: int = 1) -> bool:
	return quantity > 0 and get_quantity(item_id) >= quantity

func get_quantity(item_id: StringName) -> int:
	var total: int = 0
	for slot: Dictionary in _slots:
		if slot["item_id"] == item_id:
			total += int(slot["quantity"])
	return total

func get_slots() -> Array[Dictionary]:
	return _slots.duplicate(true)

func clear() -> void:
	if _slots.is_empty():
		return
	_slots.clear()
	_emit_changed()

func serialize() -> Dictionary:
	return {"capacity": capacity, "slots": get_slots()}

func deserialize(data: Dictionary) -> void:
	_slots.clear()
	capacity = maxi(1, int(data.get("capacity", capacity)))
	for raw_slot: Dictionary in data.get("slots", []):
		var item_id: StringName = StringName(raw_slot.get("item_id", ""))
		var quantity: int = int(raw_slot.get("quantity", 0))
		if quantity > 0 and DataRegistry.get_item(item_id) != null and _slots.size() < capacity:
			_slots.append({"item_id": item_id, "quantity": quantity})
	_emit_changed()

func _emit_changed() -> void:
	inventory_changed.emit(get_slots())
