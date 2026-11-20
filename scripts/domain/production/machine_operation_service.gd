## MachineOperationService — owns placed machine jobs and day-based processing.
## API:
##   func start(cell: Vector2i, recipe_id: StringName, house_level: int) -> Dictionary
##   func advance_day() -> void
##   func take_output(cell: Vector2i) -> Dictionary
##   func can_collect_output(cell: Vector2i) -> Dictionary
##   func collect_output_to_inventory(cell: Vector2i) -> Dictionary
##   func can_edit_placement(cell: Vector2i, require_idle: bool = true) -> Dictionary
##   func forget_idle_job(cell: Vector2i) -> Dictionary
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name MachineOperationService
extends RefCounted

var _machines: Dictionary = {}
var _inventory: InventoryState
var _placements: MachinePlacementState
var _collecting: bool = false

func configure(inventory: InventoryState, placements: MachinePlacementState) -> void:
	_inventory = inventory
	_placements = placements

func start(cell: Vector2i, recipe_id: StringName, house_level: int) -> Dictionary:
	if _collecting or InventoryService.is_busy(_inventory):
		return _failure(&"collection_busy")
	if _inventory == null or _placements == null:
		return _failure(&"invalid_state")
	var placement: Dictionary = _placements.get_placement(cell)
	if placement.is_empty():
		return _failure(&"no_machine")
	var machine: MachineData = DataRegistry.get_machine(StringName(placement.get("machine_id", "")))
	var recipe: RecipeData = DataRegistry.get_recipe(recipe_id)
	if machine == null or recipe == null:
		return _failure(&"unknown_recipe")
	var state: MachineState = _get_or_create(cell, StringName(placement.get("machine_id", "")))
	return state.start(machine, recipe, _inventory, house_level)

func advance_day() -> void:
	if _collecting:
		return
	for state: MachineState in _machines.values():
		state.advance_day()

func take_output(cell: Vector2i) -> Dictionary:
	if _collecting:
		return {}
	var state: MachineState = _machines.get(_key(cell))
	if state == null:
		return {}
	return state.take_output()

func can_collect_output(cell: Vector2i) -> Dictionary:
	if _collecting or InventoryService.is_busy(_inventory):
		return _failure(&"collection_busy")
	if _inventory == null or _placements == null:
		return _failure(&"invalid_state")
	var placement: Dictionary = _placements.get_placement(cell)
	if placement.is_empty():
		return _failure(&"no_machine")
	var machine: MachineData = DataRegistry.get_machine(StringName(placement.get("machine_id", "")))
	var state: MachineState = get_state(cell)
	if machine == null or state == null:
		return _failure(&"no_output")
	if state.cell != cell or state.machine_id != machine.machine_id:
		return _failure(&"invalid_state")
	if state.status != MachineState.STATUS_BLOCKED or state.output_item_id.is_empty() or state.output_quantity <= 0:
		return _failure(&"no_output")
	if DataRegistry.get_item(state.output_item_id) == null:
		return _failure(&"unknown_item")
	var recipe: RecipeData = DataRegistry.get_recipe(state.recipe_id)
	if recipe == null or not machine.accepts_recipe(recipe.recipe_id) or not recipe.has_machine(machine.machine_id):
		return _failure(&"invalid_state")
	var outputs: Array[Dictionary] = recipe.output_entries()
	if outputs.size() != 1 or StringName(outputs[0].get("item_id", "")) != state.output_item_id or int(outputs[0].get("quantity", 0)) != state.output_quantity:
		return _failure(&"invalid_state")
	if not _inventory.can_add_item(state.output_item_id, state.output_quantity):
		return _failure(&"inventory_full")
	return {"ok": true, "reason": &"ready", "item_id": state.output_item_id, "quantity": state.output_quantity}

func collect_output_to_inventory(cell: Vector2i) -> Dictionary:
	var preview: Dictionary = can_collect_output(cell)
	if not bool(preview.ok):
		return preview
	var state: MachineState = get_state(cell)
	var inventory_before: Dictionary = _inventory.serialize()
	var machine_before: Dictionary = state.serialize()
	_collecting = true
	# Reserve before item signals: observers see a cleared buffer, never a second payout.
	var output: Dictionary = state.take_output()
	var id: StringName = StringName(output.get("item_id", ""))
	var quantity: int = int(output.get("quantity", 0))
	var added: int = InventoryService.add(_inventory,id, quantity,&"collect_machine")
	if id != StringName(preview.item_id) or quantity != int(preview.quantity) or added != quantity:
		_inventory.deserialize(inventory_before)
		state.deserialize(machine_before)
		_collecting = false
		return _failure(&"transfer_failed")
	_collecting = false
	return {"ok": true, "reason": &"collected", "item_id": id, "quantity": quantity}

func get_state(cell: Vector2i) -> MachineState:
	return _machines.get(_key(cell)) as MachineState

func can_edit_placement(cell: Vector2i, require_idle: bool = true) -> Dictionary:
	if _collecting:
		return _failure(&"collection_busy")
	if _inventory == null or _placements == null:
		return _failure(&"invalid_state")
	var state: MachineState = get_state(cell)
	if state == null:
		return {"ok": true, "reason": &"editable"}
	var machine: MachineData = DataRegistry.get_machine(state.machine_id)
	if state.cell != cell or machine == null:
		return _failure(&"invalid_state")
	var placement: Dictionary = _placements.get_placement(cell)
	if not placement.is_empty() and StringName(placement.machine_id) != state.machine_id:
		return _failure(&"invalid_state")
	if state.status == MachineState.STATUS_IDLE:
		return {"ok": true, "reason": &"editable"} if _empty_idle(state) else _failure(&"invalid_state")
	# A job without its machine cannot be adopted by a new placement.
	if placement.is_empty():
		return _failure(&"invalid_state")
	if require_idle:
		return _failure(&"machine_busy")
	var recipe: RecipeData = DataRegistry.get_recipe(state.recipe_id)
	if recipe == null or not machine.accepts_recipe(recipe.recipe_id) or not recipe.has_machine(machine.machine_id):
		return _failure(&"invalid_state")
	var outputs: Array[Dictionary] = recipe.output_entries()
	var saved: Dictionary = state.serialize()
	if outputs.size() != 1 or String(saved.planned_output_item_id) != String(outputs[0].item_id) or int(saved.planned_output_quantity) != int(outputs[0].quantity):
		return _failure(&"invalid_state")
	var working: bool = state.status == MachineState.STATUS_WORKING and state.days_remaining > 0 and state.output_item_id.is_empty() and state.output_quantity == 0
	var ready: bool = state.status == MachineState.STATUS_BLOCKED and state.days_remaining == 0 and state.output_item_id == StringName(outputs[0].item_id) and state.output_quantity == int(outputs[0].quantity)
	return {"ok": true, "reason": &"editable"} if working or ready else _failure(&"invalid_state")

func forget_idle_job(cell: Vector2i) -> Dictionary:
	if _collecting:
		return _failure(&"collection_busy")
	if _inventory == null or _placements == null:
		return _failure(&"invalid_state")
	var state: MachineState = get_state(cell)
	if state != null:
		if state.cell != cell or DataRegistry.get_machine(state.machine_id) == null or not _empty_idle(state):
			return _failure(&"invalid_state")
		# Placement may already have moved/returned or changed machine type.
		_machines.erase(_key(cell))
	return {"ok": true, "reason": &"forgotten"}

func _empty_idle(state: MachineState) -> bool:
	var saved: Dictionary = state.serialize()
	return state.status == MachineState.STATUS_IDLE and state.recipe_id.is_empty() and state.days_remaining == 0 and state.output_item_id.is_empty() and state.output_quantity == 0 and String(saved.planned_output_item_id).is_empty() and int(saved.planned_output_quantity) == 0

func serialize() -> Dictionary:
	var rows: Array[Dictionary] = []
	for state: MachineState in _machines.values():
		rows.append(state.serialize())
	return {"machines": rows}

func deserialize(data: Dictionary) -> void:
	_machines.clear()
	var raw: Variant = data.get("machines", [])
	if not raw is Array:
		return
	for value: Variant in raw:
		if not value is Dictionary:
			continue
		var state: MachineState = MachineState.new()
		state.deserialize(value)
		_machines[_key(state.cell)] = state

func _get_or_create(cell: Vector2i, machine_id: StringName) -> MachineState:
	var key: String = _key(cell)
	var existing: MachineState = _machines.get(key) as MachineState
	if existing != null:
		return existing
	var created: MachineState = MachineState.new()
	created.cell = cell
	created.machine_id = machine_id
	_machines[key] = created
	return created

func _key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
