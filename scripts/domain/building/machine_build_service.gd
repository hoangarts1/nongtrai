## MachineBuildService — build-mode commands for placed machines.
## API:
##   func configure(state: MachinePlacementState, operations: MachineOperationService) -> void
##   func place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary
##   func can_place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary
##   func can_remove(cell: Vector2i) -> Dictionary
##   func can_move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary
##   func rotate(cell: Vector2i, rotation: int) -> Dictionary
##   func move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary
##   func remove(cell: Vector2i) -> Dictionary
class_name MachineBuildService
extends RefCounted

var placement_state: MachinePlacementState
var _operations: MachineOperationService

func configure(state: MachinePlacementState, operations: MachineOperationService) -> void:
	placement_state = state
	_operations = operations

func place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary:
	var preview: Dictionary = can_place(machine_id, cell, rotation)
	if not bool(preview.ok):
		return preview
	return _commit(placement_state.place.bind(machine_id, cell, rotation), [cell])

func can_place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary:
	var preview: Dictionary = _preview(cell)
	if not bool(preview.ok):
		return preview
	if DataRegistry.get_machine(machine_id) == null:
		return _failure(&"unknown_machine")
	if not MachinePlacementState.VALID_ROTATIONS.has(rotation):
		return _failure(&"invalid_rotation")
	if placement_state.machine_inventory.get_quantity(machine_id) <= 0:
		return _failure(&"machine_not_owned")
	if not placement_state.occupancy.can_place(cell, MachinePlacementState.MACHINE_SIZE, rotation):
		return _failure(&"cell_unavailable")
	return {"ok": true, "reason": &"editable"}

func can_remove(cell: Vector2i) -> Dictionary:
	var preview: Dictionary = _preview(cell)
	if not bool(preview.ok):
		return preview
	return _failure(&"no_machine") if placement_state.get_placement(cell).is_empty() else preview

func rotate(cell: Vector2i, rotation: int) -> Dictionary:
	var preview: Dictionary = _preview(cell, false)
	if not bool(preview.ok):
		return preview
	return placement_state.rotate(cell, rotation)

func move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary:
	var preview: Dictionary = can_move(cell, target_cell, rotation)
	if not bool(preview.ok):
		return preview
	if cell == target_cell:
		return rotate(cell, rotation)
	return _commit(placement_state.move.bind(cell, target_cell, rotation), [cell, target_cell])

func can_move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary:
	var source: Dictionary = _preview(cell, cell != target_cell)
	if not bool(source.ok):
		return source
	var placement: Dictionary = placement_state.get_placement(cell)
	if placement.is_empty():
		return _failure(&"no_machine")
	if DataRegistry.get_machine(StringName(placement.machine_id)) == null:
		return _failure(&"unknown_machine")
	if not placement_state.occupancy.is_occupied(cell):
		return _failure(&"occupancy_error")
	if not MachinePlacementState.VALID_ROTATIONS.has(rotation):
		return _failure(&"invalid_rotation")
	if cell == target_cell:
		return source
	var target: Dictionary = _preview(target_cell)
	if not bool(target.ok):
		return target
	# The current1x1 footprint cannot overlap a different source cell.
	if not placement_state.occupancy.can_place(target_cell, MachinePlacementState.MACHINE_SIZE, rotation):
		return _failure(&"cell_unavailable")
	return target

func remove(cell: Vector2i) -> Dictionary:
	var preview: Dictionary = can_remove(cell)
	if not bool(preview.ok):
		return preview
	return _commit(placement_state.remove.bind(cell), [cell])

func _preview(cell: Vector2i, require_idle: bool = true) -> Dictionary:
	if placement_state == null or _operations == null or placement_state.machine_inventory == null or placement_state.occupancy == null:
		return _failure(&"invalid_state")
	return _operations.can_edit_placement(cell, require_idle)

func _commit(command: Callable, cleanup: Array[Vector2i]) -> Dictionary:
	var placements_before: Dictionary = placement_state.serialize()
	var owned_before: Dictionary = placement_state.machine_inventory.serialize()
	var jobs_before: Dictionary = _operations.serialize()
	var result: Dictionary = command.call()
	if not bool(result.ok):
		return result
	for cell: Vector2i in cleanup:
		var cleared: Dictionary = _operations.forget_idle_job(cell)
		if not bool(cleared.ok):
			# Keep rejection atomic even if a collaborator refuses post-edit cleanup.
			placement_state.machine_inventory.deserialize(owned_before)
			placement_state.deserialize(placements_before)
			_operations.deserialize(jobs_before)
			return cleared
	return result

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
