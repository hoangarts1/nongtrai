## InventoryState — slot-limited, stackable inventory domain state.
## API:
##   func add_item(item_id: StringName, quantity: int) -> int
##   func remove_item(item_id: StringName, quantity: int) -> bool
##   func has_item(item_id: StringName, quantity: int = 1) -> bool
##   func get_quantity(item_id: StringName) -> int
##   func try_expand_capacity(expected_capacity: int, target_capacity: int) -> bool
##   func clear() -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
##   func sort_slots() -> Array[int]
##   func discard_from_slot(index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool
class_name InventoryState
extends RefCounted

signal inventory_changed(slots: Array[Dictionary])
signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)

var capacity: int
var revision: int = 0
var _slots: Array[Dictionary] = []
const CONFIG: InventoryConfig = preload("res://data/inventory_config.tres")
# External-data integrity bounds, not gameplay stack/capacity upgrades.
const MAX_SAVED_SLOTS: int = BagUpgradeConfig.MAX_CAPACITY
const MAX_JSON_INTEGER: int = 9007199254740991

func _init(max_slots: int = -1) -> void:
	capacity = maxi(1, CONFIG.default_capacity if max_slots < 0 else max_slots)

func try_expand_capacity(expected_capacity: int, target_capacity: int) -> bool:
	if capacity!=expected_capacity or capacity<=0 or capacity<_slots.size() or target_capacity<=capacity or target_capacity>MAX_SAVED_SLOTS:
		return false
	capacity = target_capacity
	_emit_changed()
	return true

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

func can_add_item(item_id: StringName, quantity: int) -> bool:
	if quantity <= 0 or DataRegistry.get_item(item_id) == null:
		return false
	var item_data: Resource = DataRegistry.get_item(item_id)
	var remaining: int = quantity
	for slot: Dictionary in _slots:
		if slot["item_id"] == item_id:
			remaining -= mini(remaining, maxi(0,int(item_data.get("max_stack")) - int(slot["quantity"])))
	if remaining <= 0:
		return true
	var free_slots: int = capacity - _slots.size()
	var stack_max: int = int(item_data.get("max_stack"))
	return free_slots >= ceili(float(remaining) / float(stack_max))

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
	var raw: Variant = data.get("slots",[])
	if not raw is Array or raw.size() > MAX_SAVED_SLOTS:
		push_warning("InventoryState: invalid/oversized slots; previous inventory retained")
		return
	var restored: Array[Dictionary] = []
	var total: int = 0
	for value: Variant in raw:
		if not value is Dictionary:
			push_warning("InventoryState: invalid slot ignored")
			continue
		var id: Variant = value.get("item_id","")
		var quantity: int = _saved_integer(value.get("quantity",0),0)
		if not (id is String or id is StringName) or quantity <= 0 or DataRegistry.get_item(StringName(id)) == null:
			push_warning("InventoryState: invalid/unknown item ignored")
			continue
		if total > MAX_JSON_INTEGER-quantity:
			push_warning("InventoryState: unsafe total; previous inventory retained")
			return
		total += quantity
		restored.append({"item_id":StringName(id),"quantity":quantity})
	var saved_capacity: int = _saved_integer(data.get("capacity",capacity),capacity)
	if saved_capacity <= 0 or saved_capacity > MAX_SAVED_SLOTS:
		saved_capacity = capacity
	# Never truncate valid legacy contents because its capacity field is smaller.
	capacity = maxi(maxi(1,saved_capacity),restored.size())
	_slots = restored
	_emit_changed()

func sort_slots() -> Array[int]:
	var order: Array[int] = []
	for index: int in range(_slots.size()):
		order.append(index)
	order.sort_custom(func(a: int, b: int) -> bool:
		var first: ItemData = DataRegistry.get_item(_slots[a]["item_id"]) as ItemData
		var second: ItemData = DataRegistry.get_item(_slots[b]["item_id"]) as ItemData
		var first_category: int = ItemData.CATEGORIES.find(first.category)
		var second_category: int = ItemData.CATEGORIES.find(second.category)
		if first_category != second_category:
			return first_category < second_category
		if first.item_id != second.item_id:
			return String(first.item_id) < String(second.item_id)
		return a < b
	)
	var sorted: Array[Dictionary] = []
	for index: int in order:
		sorted.append(_slots[index])
	_slots = sorted
	_emit_changed()
	return order

func discard_from_slot(index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool:
	if revision != expected_revision or index < 0 or index >= _slots.size() or quantity <= 0:
		return false
	var slot: Dictionary = _slots[index]
	if StringName(slot["item_id"]) != expected_id or int(slot["quantity"]) != expected_quantity or quantity > expected_quantity:
		return false
	slot["quantity"] = expected_quantity-quantity
	if int(slot["quantity"]) == 0:
		_slots.remove_at(index)
	_emit_changed()
	item_removed.emit(expected_id,quantity)
	Events.item_removed.emit(expected_id,quantity)
	return true

static func _saved_integer(value: Variant, fallback: int) -> int:
	if not value is int and not value is float:
		return fallback
	if not is_finite(float(value)) or absf(float(value)) > MAX_JSON_INTEGER:
		return fallback
	if value is float and value != floorf(value):
		return fallback
	return int(value)

func _emit_changed() -> void:
	revision += 1
	inventory_changed.emit(get_slots())
