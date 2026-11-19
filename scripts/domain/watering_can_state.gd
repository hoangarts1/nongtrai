## WateringCanState - sole standalone owner; atomic primitives invoke no callbacks.
## API:
##   func configure(config: WateringCanConfig) -> void
##   func is_ready_for(config: WateringCanConfig) -> bool
##   func get_capacity() -> int
##   func get_charges() -> int
##   func try_consume_one(expected_charges: int) -> bool
##   func try_consume_charges(amount:int,expected_charges:int,expected_revision:int=-1)->bool
##   func get_refill_revision() -> int
##   func refund_one(expected_refill_revision: int = -1) -> bool
##   func refund_charges(amount:int,expected_refill_revision:int=-1)->bool
##   func refill() -> bool
##   func try_upgrade(expected_capacity: int, target_capacity: int) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name WateringCanState
extends RefCounted

var _config: WateringCanConfig
var _capacity: int = 0
var _charges: int = 0
# Transient replacement token: refill/load/reset subsumes a pending water debit.
var _refill_revision: int = 0

func configure(config: WateringCanConfig) -> void:
	_refill_revision += 1
	_config = config
	_capacity = config.base_capacity if config!=null and config.validation_errors().is_empty() else 0
	_charges = _capacity

func is_ready_for(config: WateringCanConfig) -> bool:
	return config!=null and config==_config and config.validation_errors().is_empty() and _capacity in [config.base_capacity,config.upgrade_capacity] and _charges>=0 and _charges<=_capacity

func get_capacity() -> int:
	return _capacity if is_ready_for(_config) else 0

func get_charges() -> int:
	return _charges if is_ready_for(_config) else 0

func try_consume_one(expected_charges: int) -> bool:
	return try_consume_charges(1, expected_charges)

func try_consume_charges(amount: int, expected_charges: int, expected_revision: int = -1) -> bool:
	if not is_ready_for(_config) or amount<=0 or expected_charges!=_charges or amount>_charges or (expected_revision>=0 and expected_revision!=_refill_revision):
		return false
	_charges -= amount
	return true

func get_refill_revision() -> int:
	return _refill_revision

func refund_one(expected_refill_revision: int = -1) -> bool:
	return refund_charges(1, expected_refill_revision)

func refund_charges(amount: int, expected_refill_revision: int = -1) -> bool:
	if expected_refill_revision>=0 and expected_refill_revision!=_refill_revision:
		return false
	if not is_ready_for(_config) or amount<=0 or amount>_capacity-_charges:
		return false
	_charges += amount
	return true

func refill() -> bool:
	if not is_ready_for(_config) or _charges==_capacity:
		return false
	_refill_revision += 1
	_charges = _capacity
	return true

func try_upgrade(expected_capacity: int, target_capacity: int) -> bool:
	if not is_ready_for(_config) or expected_capacity!=_capacity or _capacity!=_config.base_capacity or target_capacity!=_config.upgrade_capacity:
		return false
	_capacity = target_capacity
	return true

func serialize() -> Dictionary:
	return {"capacity":get_capacity(),"charges":get_charges()}

func deserialize(data: Dictionary) -> void:
	_refill_revision += 1
	_capacity = 0
	_charges = 0
	if _config==null or not _config.validation_errors().is_empty():
		push_warning("WateringCanState: invalid config; no usable can restored")
		return
	_capacity = _config.base_capacity
	var capacity: int = _json_integer(data.get("capacity",_capacity))
	if capacity not in [_config.base_capacity,_config.upgrade_capacity]:
		push_warning("WateringCanState: unknown/malformed capacity ignored; empty base restored")
		return
	_capacity = capacity
	var charges: int = _json_integer(data.get("charges",0))
	if charges<0:
		push_warning("WateringCanState: malformed charges ignored")
		return
	_charges = mini(charges,_capacity)
	if charges>_capacity:
		push_warning("WateringCanState: over-capacity charges clamped")

static func _json_integer(value: Variant) -> int:
	if value is int:
		return int(value) if value>=0 and value<=WateringCanConfig.MAX_JSON_INTEGER else -1
	if value is float and is_finite(value) and value>=0 and value<=WateringCanConfig.MAX_JSON_INTEGER and value==floorf(value):
		return int(value)
	return -1
