## MachinePlacementState — saved machine placements backed by occupancy and ownership.
## API:
##   func place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary
##   func remove(cell: Vector2i) -> Dictionary
##   func rotate(cell: Vector2i, rotation: int) -> Dictionary
##   func move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name MachinePlacementState
extends RefCounted

const MACHINE_SIZE: Vector2i = Vector2i.ONE
const VALID_ROTATIONS: Array[int] = [0, 90, 180, 270]

var occupancy: OccupancyMap
var machine_inventory: MachineInventory
var _placements: Dictionary = {}
const PARCELS: LandParcelData = preload("res://data/land_parcels.tres")

func configure(parcels: LandParcelData, inventory: MachineInventory) -> void:
	machine_inventory = inventory
	occupancy = OccupancyMap.new()
	occupancy.configure(parcels)

func place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary:
	if occupancy == null or machine_inventory == null:
		return _failure(&"invalid_state")
	if DataRegistry.get_machine(machine_id) == null:
		return _failure(&"unknown_machine")
	if not VALID_ROTATIONS.has(rotation):
		return _failure(&"invalid_rotation")
	if machine_inventory.get_quantity(machine_id) <= 0:
		return _failure(&"machine_not_owned")
	if not occupancy.occupy(cell, MACHINE_SIZE, rotation):
		return _failure(&"cell_unavailable")
	if not machine_inventory.remove_machine(machine_id):
		occupancy.release(cell, MACHINE_SIZE, rotation)
		return _failure(&"machine_not_owned")
	_placements[cell] = {"machine_id": machine_id, "cell": cell, "rotation": rotation}
	return {"ok": true, "reason": &"placed"}

func remove(cell: Vector2i) -> Dictionary:
	if occupancy == null or machine_inventory == null:
		return _failure(&"invalid_state")
	var placement: Dictionary = _placements.get(cell, {})
	if placement.is_empty():
		return _failure(&"no_machine")
	var rotation: int = int(placement.get("rotation", 0))
	if not occupancy.release(cell, MACHINE_SIZE, rotation):
		return _failure(&"occupancy_error")
	var machine_id: StringName = StringName(placement.get("machine_id", ""))
	machine_inventory.add_machine(machine_id)
	_placements.erase(cell)
	return {"ok": true, "reason": &"removed", "machine_id": machine_id}

func rotate(cell: Vector2i, rotation: int) -> Dictionary:
	if occupancy == null or machine_inventory == null:
		return _failure(&"invalid_state")
	if not VALID_ROTATIONS.has(rotation):
		return _failure(&"invalid_rotation")
	var placement: Dictionary = _placements.get(cell, {})
	if placement.is_empty():
		return _failure(&"no_machine")
	var current_rotation: int = int(placement.get("rotation", 0))
	if current_rotation == rotation:
		return {"ok": true, "reason": &"rotated", "rotation": rotation}
	if not occupancy.release(cell, MACHINE_SIZE, current_rotation):
		return _failure(&"occupancy_error")
	if not occupancy.occupy(cell, MACHINE_SIZE, rotation):
		occupancy.occupy(cell, MACHINE_SIZE, current_rotation)
		return _failure(&"cell_unavailable")
	placement["rotation"] = rotation
	_placements[cell] = placement
	return {"ok": true, "reason": &"rotated", "rotation": rotation}

func move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary:
	if occupancy == null or machine_inventory == null:
		return _failure(&"invalid_state")
	if not VALID_ROTATIONS.has(rotation):
		return _failure(&"invalid_rotation")
	var placement: Dictionary = _placements.get(cell, {})
	if placement.is_empty():
		return _failure(&"no_machine")
	if cell == target_cell:
		return rotate(cell, rotation)
	var current_rotation: int = int(placement.get("rotation", 0))
	if not occupancy.release(cell, MACHINE_SIZE, current_rotation):
		return _failure(&"occupancy_error")
	if not occupancy.occupy(target_cell, MACHINE_SIZE, rotation):
		occupancy.occupy(cell, MACHINE_SIZE, current_rotation)
		return _failure(&"cell_unavailable")
	_placements.erase(cell)
	_placements[target_cell] = {
		"machine_id": placement["machine_id"],
		"cell": target_cell,
		"rotation": rotation
	}
	return {"ok": true, "reason": &"moved", "cell": target_cell, "rotation": rotation}

func get_placement(cell: Vector2i) -> Dictionary:
	return (_placements.get(cell, {}) as Dictionary).duplicate(true)

func get_all_placements() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for placement: Dictionary in _placements.values():
		result.append(placement.duplicate(true))
	return result

func serialize() -> Dictionary:
	var placements: Array[Dictionary] = []
	for placement: Dictionary in _placements.values():
		placements.append({
			"machine_id": String(placement["machine_id"]),
			"cell": "%d,%d" % [placement["cell"].x, placement["cell"].y],
			"rotation": int(placement["rotation"])
		})
	return {"placements": placements}

func deserialize(data: Dictionary) -> void:
	if occupancy == null or machine_inventory == null:
		return
	_placements.clear()
	occupancy = OccupancyMap.new()
	occupancy.configure(PARCELS)
	var raw: Variant = data.get("placements", [])
	if not raw is Array:
		return
	for value: Variant in raw:
		if not value is Dictionary:
			continue
		var machine_id: StringName = StringName(value.get("machine_id", ""))
		var cell: Vector2i = _parse_cell(value.get("cell", "0,0"))
		var rotation: int = int(value.get("rotation", 0))
		machine_inventory.add_machine(machine_id)
		if place(machine_id, cell, rotation)["ok"]:
			continue
		push_warning("MachinePlacementState: invalid placement ignored")

func _parse_cell(raw: Variant) -> Vector2i:
	if not raw is String:
		return Vector2i.ZERO
	var parts: PackedStringArray = String(raw).split(",")
	return Vector2i(int(parts[0]), int(parts[1])) if parts.size() == 2 else Vector2i.ZERO

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
