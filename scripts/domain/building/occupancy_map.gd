## OccupancyMap — logical occupied cells and locked parcel checks.
## API:
##   func can_place(origin: Vector2i, size: Vector2i, rotation: int) -> bool
##   func occupy(origin: Vector2i, size: Vector2i, rotation: int) -> bool
##   func release(origin: Vector2i, size: Vector2i, rotation: int) -> bool
class_name OccupancyMap
extends RefCounted

const VALID_ROTATIONS: Array[int] = [0, 90, 180, 270]

var _locked_cells: Dictionary = {}
var _occupied_cells: Dictionary = {}

func configure(parcel_data: LandParcelData) -> void:
	_locked_cells.clear()
	if parcel_data == null:
		return
	for cell: Vector2i in parcel_data.locked_cells:
		_locked_cells[cell] = true

func can_place(origin: Vector2i, size: Vector2i, rotation: int) -> bool:
	if not VALID_ROTATIONS.has(rotation) or size.x <= 0 or size.y <= 0:
		return false
	for cell: Vector2i in _footprint(origin, size, rotation):
		if _locked_cells.has(cell) or _occupied_cells.has(cell):
			return false
	return true

func occupy(origin: Vector2i, size: Vector2i, rotation: int) -> bool:
	if not can_place(origin, size, rotation):
		return false
	for cell: Vector2i in _footprint(origin, size, rotation):
		_occupied_cells[cell] = true
	return true

func release(origin: Vector2i, size: Vector2i, rotation: int) -> bool:
	var cells: Array[Vector2i] = _footprint(origin, size, rotation)
	for cell: Vector2i in cells:
		if not _occupied_cells.has(cell):
			return false
	for cell: Vector2i in cells:
		_occupied_cells.erase(cell)
	return true

func is_occupied(cell: Vector2i) -> bool:
	return _occupied_cells.has(cell)

func _footprint(origin: Vector2i, size: Vector2i, rotation: int) -> Array[Vector2i]:
	return GridMath.footprint_cells(origin, size, rotation / 90)
