## WateringService - manual watering adapter; no runtime/source/reach authorization.
## API:
##   func configure(config: WateringCanConfig, state: WateringCanState, farm: FarmGridState) -> void
##   func can_water(cell: Vector2i) -> Dictionary
##   func set_effect_terms(terms:Dictionary)->bool; get_charge_cost()->int
##   func water(cell:Vector2i,expected_quote:Dictionary={})->Dictionary
class_name WateringService
extends RefCounted

var _config: WateringCanConfig
var _state: WateringCanState
var _farm: FarmGridState
var _watering: bool = false
var _effect_terms: Dictionary = {}
var _terms_revision: int = 0

func configure(config: WateringCanConfig, state: WateringCanState, farm: FarmGridState) -> void:
	_config = config
	_state = state
	_farm = farm
	_effect_terms = {}
	_terms_revision += 1

func set_effect_terms(terms: Dictionary) -> bool:
	if _watering or not DirectorEffectTermsCodec.water(_config, terms).ok:
		return false
	if not DirectorSnapshot._same(_effect_terms, terms):
		_effect_terms = DirectorHistoryRules.copy_json(terms)
		_terms_revision += 1
	return true

func get_charge_cost() -> int:
	var checked: Dictionary = DirectorEffectTermsCodec.water(_config, _effect_terms)
	return int(checked.charge_cost) if checked.ok else 0

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
	var cost: int = get_charge_cost()
	if cost<=0:
		return _failure(&"invalid_modifier")
	if _state.get_charges()<=0:
		return _failure(&"water_empty")
	if _state.get_charges()<cost:
		return _failure(&"water_insufficient")
	return {"ok":true,"reason":&"available","charges":_state.get_charges(),"charge_cost":cost,"refill_revision":_state.get_refill_revision(),"terms_revision":_terms_revision}

func water(cell: Vector2i, expected_quote: Dictionary = {}) -> Dictionary:
	var ready: Dictionary = can_water(cell)
	if not bool(ready.ok):
		return ready
	if not expected_quote.is_empty() and not DirectorSnapshot._same(ready, expected_quote):
		return _failure(&"stale_quote")
	var state: WateringCanState = _state
	var farm: FarmGridState = _farm
	var refill_revision: int = int(ready.refill_revision)
	var cost: int = int(ready.charge_cost)
	_watering = true
	if not state.try_consume_charges(cost, int(ready.charges), refill_revision):
		_watering = false
		return _failure(&"stale_charges")
	if not farm.water_cell(cell):
		# Preserve independent changes; never overwrite a farm/can snapshot.
		state.refund_charges(cost, refill_revision)
		_watering = false
		return _failure(&"watering_rejected")
	_watering = false
	return {"ok":true,"reason":&"watered","charges":state.get_charges(),"charge_cost":cost}

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
