## FarmGridState — till, plant, water and harvest farm plots.
## API:
##   func till_cell(cell: Vector2i) -> bool
##   func plant_crop(cell: Vector2i, crop_id: StringName) -> bool
##   func water_cell(cell: Vector2i) -> bool
##   func advance_day() -> void
##   func can_harvest(cell: Vector2i) -> bool
##   func harvest_cell(cell: Vector2i) -> Dictionary
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name FarmGridState
extends RefCounted

signal plot_changed(cell: Vector2i)

var _plots: Dictionary = {}

func get_plot(cell: Vector2i) -> Dictionary:
	return (_plots.get(cell, {}) as Dictionary).duplicate(true)

func reset() -> void:
	_plots.clear()
	plot_changed.emit(Vector2i())

func till_cell(cell: Vector2i) -> bool:
	var plot: Dictionary = _plots.get(cell, {})
	if plot.is_empty():
		plot = {
			"tilled": false,
			"crop_id": &"",
			"growth_days": 0,
			"watered": false
		}
	if bool(plot.get("tilled", false)):
		return false
	plot["tilled"] = true
	_plots[cell] = plot
	plot_changed.emit(cell)
	Events.plot_changed.emit(cell)
	Events.plot_tilled.emit(cell)
	return true

func plant_crop(cell: Vector2i, crop_id: StringName) -> bool:
	var crop_data: Resource = DataRegistry.get_crop(crop_id)
	if crop_data == null:
		return false
	var plot: Dictionary = _plots.get(cell, {})
	if plot.is_empty() or not bool(plot.get("tilled", false)):
		return false
	if not StringName(plot.get("crop_id", &"")).is_empty():
		return false
	plot["crop_id"] = crop_id
	plot["growth_days"] = 0
	plot["watered"] = false
	_plots[cell] = plot
	plot_changed.emit(cell)
	Events.crop_planted.emit(cell, crop_id)
	return true

func water_cell(cell: Vector2i) -> bool:
	var plot: Dictionary = _plots.get(cell, {})
	if plot.is_empty() or not bool(plot.get("tilled", false)):
		return false
	var crop_id: StringName = plot.get("crop_id", &"")
	if crop_id == &"":
		return false
	if bool(plot.get("watered", false)):
		return false
	plot["watered"] = true
	_plots[cell] = plot
	plot_changed.emit(cell)
	Events.plot_watered.emit(cell)
	return true

func water_all_crops() -> void:
	for cell: Vector2i in _plots.keys():
		var plot: Dictionary = _plots[cell]
		if not StringName(plot.get("crop_id", &"")).is_empty() and not bool(plot.get("watered", false)):
			water_cell(cell)

func advance_day() -> void:
	for cell: Vector2i in _plots.keys():
		var plot: Dictionary = _plots[cell]
		if not bool(plot.get("tilled", false)):
			continue
		var crop_id: StringName = plot.get("crop_id", &"")
		if crop_id == &"":
			continue
		var crop_data: Resource = DataRegistry.get_crop(crop_id)
		if crop_data == null:
			continue
		if bool(plot.get("watered", false)):
			plot["growth_days"] = int(plot.get("growth_days", 0)) + 1
		plot["watered"] = false
		_plots[cell] = plot
		plot_changed.emit(cell)

func can_harvest(cell: Vector2i) -> bool:
	var plot: Dictionary = _plots.get(cell, {})
	if plot.is_empty():
		return false
	var crop_id: StringName = plot.get("crop_id", &"")
	if crop_id == &"":
		return false
	var crop_data: Resource = DataRegistry.get_crop(crop_id)
	if crop_data == null:
		return false
	return int(plot.get("growth_days", 0)) >= int(crop_data.get("growth_days"))

func get_growth_remaining(cell: Vector2i) -> int:
	var plot: Dictionary = _plots.get(cell, {})
	var crop_id: StringName = plot.get("crop_id", &"")
	if crop_id.is_empty():
		return 0
	var crop_data: Resource = DataRegistry.get_crop(crop_id)
	if crop_data == null:
		return 0
	return maxi(0, int(crop_data.get("growth_days")) - int(plot.get("growth_days", 0)))

func get_harvest_payload(cell: Vector2i) -> Dictionary:
	if not can_harvest(cell):
		return {"success": false, "crop_id": &"", "product_item": &"", "quantity": 0}
	var plot: Dictionary = _plots.get(cell, {})
	var crop_id: StringName = plot.get("crop_id", &"")
	var crop_data: Resource = DataRegistry.get_crop(crop_id)
	return {
		"success": true,
		"crop_id": crop_id,
		"product_item": StringName(crop_data.get("product_item")),
		"quantity": int(crop_data.get("yield_qty"))
	}

func harvest_cell(cell: Vector2i) -> Dictionary:
	var payload: Dictionary = get_harvest_payload(cell)
	if not bool(payload.get("success", false)):
		return payload
	var crop_id: StringName = payload.get("crop_id", &"")
	var quantity: int = int(payload.get("quantity", 0))
	_plots.erase(cell)
	plot_changed.emit(cell)
	Events.crop_harvested.emit(cell, crop_id, quantity, 1)
	return payload

func serialize() -> Dictionary:
	var entries: Array[Dictionary] = []
	for cell: Vector2i in _plots.keys():
		var plot: Dictionary = _plots[cell]
		entries.append({
			"cell_x": cell.x,
			"cell_y": cell.y,
			"tilled": bool(plot.get("tilled", false)),
			"crop_id": String(plot.get("crop_id", &"")),
			"growth_days": int(plot.get("growth_days", 0)),
			"watered": bool(plot.get("watered", false))
		})
	return {"plots": entries}

func deserialize(data: Dictionary) -> void:
	_plots.clear()
	for entry: Dictionary in data.get("plots", []):
		var cell: Vector2i = Vector2i(
			int(entry.get("cell_x", 0)),
			int(entry.get("cell_y", 0))
		)
		var crop_id: StringName = StringName(entry.get("crop_id", ""))
		var plot: Dictionary = {
			"tilled": bool(entry.get("tilled", false)),
			"crop_id": crop_id,
			"growth_days": int(entry.get("growth_days", 0)),
			"watered": bool(entry.get("watered", false))
		}
		if plot["tilled"] or not StringName(plot["crop_id"]).is_empty():
			_plots[cell] = plot
	plot_changed.emit(Vector2i())
