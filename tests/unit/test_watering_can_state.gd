extends GutTest
const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")

func _fresh() -> WateringCanState:
	var state: WateringCanState = WateringCanState.new()
	state.configure(CONFIG)
	return state

func test_shipped_config_invalid_terms_and_unconfigured_state_fail_closed() -> void:
	assert_true(DataValidator.validate_watering_can_config(CONFIG).is_empty())
	assert_eq([CONFIG.base_capacity,CONFIG.upgrade_capacity,CONFIG.upgrade_price],[20,40,200])
	assert_false(DataValidator.validate_watering_can_config(null).is_empty())
	for field: String in ["base_capacity","upgrade_capacity","upgrade_price"]:
		for value: int in [-1,0,9223372036854775807]:
			var invalid: WateringCanConfig = CONFIG.duplicate() as WateringCanConfig
			invalid.set(field,value)
			assert_false(invalid.validation_errors().is_empty())
	var invalid: WateringCanConfig = CONFIG.duplicate() as WateringCanConfig
	invalid.upgrade_capacity = invalid.base_capacity
	assert_false(invalid.validation_errors().is_empty())
	var state: WateringCanState = WateringCanState.new()
	for config: WateringCanConfig in [null,invalid]:
		state.configure(config)
		assert_eq(state.serialize(),{"capacity":0,"charges":0})
		assert_false(state.try_consume_one(0))
		assert_false(state.refund_one())
		assert_false(state.refill())
		assert_false(state.try_upgrade(20,40))
		state.deserialize({"capacity":40,"charges":40})
		assert_eq(state.get_capacity(),0)

func test_fresh_consume_refill_and_refund_tokens_are_integer_bounded() -> void:
	var state: WateringCanState = _fresh()
	assert_eq(state.serialize(),{"capacity":20,"charges":20})
	assert_false(state.refill())
	assert_false(state.refund_one())
	assert_false(state.try_consume_one(19))
	for remaining: int in range(20,0,-1):
		assert_true(state.try_consume_one(remaining))
		assert_eq(state.get_charges(),remaining-1)
	assert_false(state.try_consume_one(0))
	assert_true(state.refund_one())
	assert_eq(state.get_charges(),1)
	var revision: int = state.get_refill_revision()
	assert_true(state.refill())
	assert_eq(state.get_charges(),20)
	assert_gt(state.get_refill_revision(),revision)
	assert_true(state.try_consume_one(20))
	assert_false(state.refund_one(revision),"Refill supersedes an older reservation credit")
	assert_eq(state.get_charges(),19)
	revision = state.get_refill_revision()
	assert_true(state.refund_one(revision))
	assert_eq(state.get_charges(),20)
	assert_false(state.refund_one(revision))

func test_only_known_upgrade_preserves_charges_and_runtime_config_identity() -> void:
	var state: WateringCanState = _fresh()
	state.deserialize({"capacity":20,"charges":7})
	var before: Dictionary = state.serialize()
	for target: int in [0,20,80,-1,9223372036854775807]:
		assert_false(state.try_upgrade(20,target))
	assert_false(state.try_upgrade(19,40))
	assert_eq(state.serialize(),before)
	assert_false(state.is_ready_for(CONFIG.duplicate() as WateringCanConfig))
	assert_true(state.try_upgrade(20,40))
	assert_eq(state.serialize(),{"capacity":40,"charges":7})
	assert_false(state.try_upgrade(40,40))
	assert_true(state.refill())
	assert_eq(state.get_charges(),40)
	state.deserialize({"capacity":20,"charges":0})
	assert_true(state.try_upgrade(20,40))
	assert_eq(state.get_charges(),0,"Upgrade is not a free refill")

func test_real_json_roundtrip_detached_fields_and_corrupt_external_values() -> void:
	var state: WateringCanState = _fresh()
	for capacity: int in [20,40]:
		for charges: int in [0,7,capacity]:
			state.deserialize({"capacity":capacity,"charges":charges})
			var data: Dictionary = state.serialize()
			var loaded: WateringCanState = _fresh()
			loaded.deserialize(JSON.parse_string(JSON.stringify(data)))
			assert_eq(loaded.serialize(),data)
			assert_eq(data.keys().size(),2,"Transient revision/config never enters JSON")
			data.charges = 0
			assert_eq(loaded.get_charges(),charges)
	for value: Variant in [null,true,"7",[],{},-1,1.5,INF,NAN,9223372036854775807]:
		state.deserialize({"capacity":40,"charges":value})
		assert_eq(state.serialize(),{"capacity":40,"charges":0})
	for value: Variant in [null,true,"40",[],{},-1,0,21,80,40.5,INF,NAN,9223372036854775807]:
		state.deserialize({"capacity":value,"charges":40})
		assert_eq(state.serialize(),{"capacity":20,"charges":0})
	state.deserialize({"capacity":40.0,"charges":999.0})
	assert_eq(state.serialize(),{"capacity":40,"charges":40})
	state.deserialize({"capacity":40})
	assert_eq(state.serialize(),{"capacity":40,"charges":0})
	state.deserialize({})
	assert_eq(state.serialize(),{"capacity":20,"charges":0})
	state.configure(CONFIG)
	assert_eq(state.get_charges(),20,"Fresh initialization is distinct from missing saved charges")
