## WateringService - manual watering adapter; no runtime/source/reach authorization.
## API:
##   func configure(config: WateringCanConfig, state: WateringCanState, farm: FarmGridState) -> void
##   func can_water(cell: Vector2i) -> Dictionary
##   func water(cell: Vector2i) -> Dictionary
class_name WateringService
extends RefCounted

var _config: WateringCanConfig
var _state: WateringCanState
var _farm: FarmGridState
var _watering: bool = false

func configure(config: WateringCanConfig, state: WateringCanState, farm: FarmGridState) -> void:
	_config = config
	_state = state
	_farm = farm

func can_water(cell: Vector2i) -> Dictionary:
	if _watering:
		return _failure(&"watering_busy")
	if _state==null or _farm==null or not _state.is_ready_for(_config):
		return _failure(&"invalid_service")
	var plot: Dictionary = _farm.get_plot(cell)
	if not bool(plot.get("tilled",false)) or StringName(plot.get("crop_id",&"")).is_empty():
		return _failure(&"no_crop")
	if bool(plot.get("watered",false)):
		return _failure(&"already_watered")
	if _state.get_charges()<=0:
		return _failure(&"water_empty")
	return {"ok":true,"reason":&"available","charges":_state.get_charges()}

func water(cell: Vector2i) -> Dictionary:
	var ready: Dictionary = can_water(cell)
	if not bool(ready.ok):
		return ready
	var state: WateringCanState = _state
	var farm: FarmGridState = _farm
	var refill_revision: int = state.get_refill_revision()
	_watering = true
	if not state.try_consume_one(int(ready.charges)):
		_watering = false
		return _failure(&"stale_charges")
	if not farm.water_cell(cell):
		# Preserve independent changes; never overwrite a farm/can snapshot.
		state.refund_one(refill_revision)
		_watering = false
		return _failure(&"watering_rejected")
	_watering = false
	return {"ok":true,"reason":&"watered","charges":state.get_charges()}

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
