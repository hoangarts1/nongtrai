## MachineInventory — unlimited owned machine counts, separate from item slots.
## API:
##   func add_machine(machine_id: StringName, quantity: int = 1) -> bool
##   func remove_machine(machine_id: StringName, quantity: int = 1) -> bool
##   func get_quantity(machine_id: StringName) -> int
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name MachineInventory
extends RefCounted

var _machines: Dictionary = {}

func add_machine(machine_id: StringName, quantity: int = 1) -> bool:
	if machine_id.is_empty() or quantity <= 0:
		return false
	_machines[machine_id] = get_quantity(machine_id) + quantity
	return true

func remove_machine(machine_id: StringName, quantity: int = 1) -> bool:
	if quantity <= 0 or get_quantity(machine_id) < quantity:
		return false
	var remaining: int = get_quantity(machine_id) - quantity
	if remaining == 0:
		_machines.erase(machine_id)
	else:
		_machines[machine_id] = remaining
	return true

func get_quantity(machine_id: StringName) -> int:
	return maxi(0, int(_machines.get(machine_id, 0)))

func serialize() -> Dictionary:
	var machines: Array[Dictionary] = []
	for machine_id: StringName in _machines:
		var quantity: int = get_quantity(machine_id)
		if quantity > 0:
			machines.append({"machine_id": String(machine_id), "quantity": quantity})
	return {"machines": machines}

func deserialize(data: Dictionary) -> void:
	var raw: Variant = data.get("machines", [])
	if not raw is Array:
		push_warning("MachineInventory: malformed machines retained previous inventory")
		return
	var restored: Dictionary = {}
	for value: Variant in raw:
		if not value is Dictionary:
			push_warning("MachineInventory: invalid machine row ignored")
			continue
		var raw_id: Variant = value.get("machine_id", "")
		var raw_quantity: Variant = value.get("quantity", 0)
		if not (raw_id is String or raw_id is StringName) or not (raw_quantity is int or raw_quantity is float):
			push_warning("MachineInventory: invalid machine row ignored")
			continue
		var quantity: int = int(raw_quantity)
		if quantity <= 0 or float(quantity) != float(raw_quantity):
			push_warning("MachineInventory: invalid quantity ignored")
			continue
		var machine_id: StringName = StringName(raw_id)
		restored[machine_id] = int(restored.get(machine_id, 0)) + quantity
	_machines = restored
