## MachineState — serializable day-based processing job and output buffer.
## API:
##   func start(machine: MachineData, recipe: RecipeData, inventory: InventoryState, house_level: int) -> Dictionary
##   func advance_day() -> bool
##   func take_output() -> Dictionary
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name MachineState
extends RefCounted

const STATUS_IDLE: StringName = &"idle"
const STATUS_WORKING: StringName = &"working"
const STATUS_BLOCKED: StringName = &"blocked"

var machine_id: StringName = &""
var cell: Vector2i = Vector2i.ZERO
var recipe_id: StringName = &""
var days_remaining: int = 0
var status: StringName = STATUS_IDLE
var output_item_id: StringName = &""
var output_quantity: int = 0
var _planned_output_item_id: StringName = &""
var _planned_output_quantity: int = 0

func start(machine: MachineData, recipe: RecipeData, inventory: InventoryState, house_level: int) -> Dictionary:
	if machine == null or recipe == null or inventory == null:
		return _failure(&"invalid_data")
	if InventoryService.is_busy(inventory):
		return _failure(&"machine_busy")
	if status != STATUS_IDLE:
		return _failure(&"machine_busy")
	if not machine.accepts_recipe(recipe.recipe_id) or not recipe.has_machine(machine.machine_id):
		return _failure(&"recipe_not_allowed")
	if house_level < maxi(machine.unlock_house_level, recipe.unlock_house_level):
		return _failure(&"house_level_locked")
	if not output_item_id.is_empty() or output_quantity > 0:
		return _failure(&"output_buffer_full")
	var recipe_outputs: Array[Dictionary] = recipe.output_entries()
	if recipe_outputs.size() != 1:
		return _failure(&"invalid_output")
	var planned_output: Dictionary = recipe_outputs[0]
	var planned_id: StringName = StringName(planned_output.get("item_id", ""))
	var planned_quantity: int = int(planned_output.get("quantity", 0))
	if planned_id.is_empty() or planned_quantity <= 0:
		return _failure(&"invalid_output")
	for entry: Dictionary in recipe.input_entries():
		var item_id: StringName = StringName(entry.get("item_id", ""))
		var quantity: int = int(entry.get("quantity", 0))
		if item_id.is_empty() or quantity <= 0 or not inventory.has_item(item_id, quantity):
			return _failure(&"missing_input")
	for entry: Dictionary in recipe.input_entries():
		InventoryService.remove(inventory,StringName(entry.get("item_id", "")), int(entry.get("quantity", 0)),&"start_recipe")
	machine_id = machine.machine_id
	recipe_id = recipe.recipe_id
	days_remaining = recipe.duration_days
	_planned_output_item_id = planned_id
	_planned_output_quantity = planned_quantity
	status = STATUS_WORKING
	return {"ok": true, "reason": &"started"}

func advance_day() -> bool:
	if status != STATUS_WORKING:
		return false
	if days_remaining > 1:
		days_remaining -= 1
		return true
	if not output_item_id.is_empty() or output_quantity > 0:
		status = STATUS_BLOCKED
		return false
	output_item_id = _planned_output_item_id
	output_quantity = _planned_output_quantity
	days_remaining = 0
	status = STATUS_BLOCKED
	return true

func take_output() -> Dictionary:
	if output_item_id.is_empty() or output_quantity <= 0:
		return {}
	var result: Dictionary = {"item_id": output_item_id, "quantity": output_quantity}
	output_item_id = &""
	output_quantity = 0
	status = STATUS_IDLE
	recipe_id = &""
	days_remaining = 0
	_planned_output_item_id = &""
	_planned_output_quantity = 0
	return result

func serialize() -> Dictionary:
	return {
		"machine_id": String(machine_id),
		"cell": "%d,%d" % [cell.x, cell.y],
		"recipe_id": String(recipe_id),
		"days_remaining": days_remaining,
		"status": String(status),
		"output_item_id": String(output_item_id),
		"output_quantity": output_quantity,
		"planned_output_item_id": String(_planned_output_item_id),
		"planned_output_quantity": _planned_output_quantity
	}

func deserialize(data: Dictionary) -> void:
	machine_id = StringName(data.get("machine_id", ""))
	cell = _parse_cell(data.get("cell", "0,0"))
	recipe_id = StringName(data.get("recipe_id", ""))
	days_remaining = maxi(0, int(data.get("days_remaining", 0)))
	var raw_status: StringName = StringName(data.get("status", STATUS_IDLE))
	status = raw_status if raw_status in [STATUS_IDLE, STATUS_WORKING, STATUS_BLOCKED] else STATUS_IDLE
	output_item_id = StringName(data.get("output_item_id", ""))
	output_quantity = maxi(0, int(data.get("output_quantity", 0)))
	_planned_output_item_id = StringName(data.get("planned_output_item_id", ""))
	_planned_output_quantity = maxi(0, int(data.get("planned_output_quantity", 0)))
	if output_item_id.is_empty() or output_quantity == 0:
		output_item_id = &""
		output_quantity = 0
	if status == STATUS_WORKING and days_remaining == 0:
		status = STATUS_BLOCKED

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}

func _parse_cell(raw: Variant) -> Vector2i:
	if not raw is String:
		return Vector2i.ZERO
	var parts: PackedStringArray = String(raw).split(",")
	if parts.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))
