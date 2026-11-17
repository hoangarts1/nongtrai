extends GutTest
const CONFIG: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const LIMIT: int = ChickenCoopConfig.MAX_JSON_INTEGER

func _fresh(day: int = 0, hens: int = 4, config: ChickenCoopConfig = CONFIG) -> ChickenCoopState:
	var state: ChickenCoopState = ChickenCoopState.new()
	state.configure(config,day,hens)
	return state

func test_resource_terms_invalid_values_and_full_herd_integer_products() -> void:
	assert_true(CONFIG.validation_errors().is_empty())
	assert_eq([CONFIG.hen_capacity,CONFIG.feed_per_hen,CONFIG.eggs_per_fed_hen],[4,1,1])
	assert_false(ChickenCoopConfig.new().validation_errors().is_empty())
	for field: StringName in [&"hen_capacity",&"feed_per_hen",&"eggs_per_fed_hen"]:
		for value: int in [-1,0,LIMIT+1,9223372036854775807]:
			var invalid: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
			invalid.set(field,value)
			assert_false(invalid.validation_errors().is_empty(),String(field))
	var boundary: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	boundary.hen_capacity = 3
	@warning_ignore("integer_division")
	var safe_units: int = LIMIT/3
	boundary.feed_per_hen = safe_units
	boundary.eggs_per_fed_hen = safe_units
	assert_true(boundary.validation_errors().is_empty())
	boundary.feed_per_hen += 1
	assert_false(boundary.validation_errors().is_empty())
	boundary.feed_per_hen = safe_units
	boundary.eggs_per_fed_hen += 1
	assert_false(boundary.validation_errors().is_empty())

func test_invalid_unconfigured_or_out_of_bounds_initialization_cannot_produce() -> void:
	var state: ChickenCoopState = ChickenCoopState.new()
	assert_false(state.feed(0,1).ok)
	assert_false(state.advance_day(0).ok)
	assert_false(state.take_eggs(1).ok)
	state.deserialize({"current_day":0,"hen_count":4,"fed_hens":4,"pending_eggs":4})
	assert_eq(state.serialize(),{"current_day":0,"hen_count":0,"fed_hens":0,"pending_eggs":0})
	for config: ChickenCoopConfig in [null,ChickenCoopConfig.new()]:
		state.configure(config,0,4)
		assert_eq(state.feed(0,1).reason,&"invalid_state")
	for args: Vector2i in [Vector2i(-1,4),Vector2i(0,-1),Vector2i(0,5)]:
		state.configure(CONFIG,args.x,args.y)
		assert_false(state.advance_day(0).ok)
	state.configure(CONFIG,LIMIT+1,4)
	assert_false(state.advance_day(0).ok)
	state.configure(CONFIG,0,0)
	assert_false(state.feed(0,1).ok)
	assert_eq(state.advance_day(0).produced,0)
	assert_eq(state.serialize().hen_count,0)

func test_one_hundred_unfed_days_keep_all_hens_and_prior_eggs() -> void:
	var state: ChickenCoopState = _fresh()
	assert_true(state.feed(0,4).ok)
	assert_eq(state.advance_day(0).produced,4)
	for day: int in range(1,101):
		assert_eq(state.advance_day(day).produced,0)
		assert_eq(state.serialize(),{"current_day":day+1,"hen_count":4,"fed_hens":0,"pending_eggs":4})

func test_partial_feeding_exact_day_progress_and_uncollected_output_accumulates() -> void:
	var state: ChickenCoopState = _fresh(9)
	assert_eq(state.feed(9,2),{"ok":true,"reason":&"fed","fed_hens":2,"feed_units":2})
	assert_eq(state.serialize().pending_eggs,0,"Feed is not immediate production")
	assert_eq(state.advance_day(9).produced,2)
	assert_eq(state.serialize(),{"current_day":10,"hen_count":4,"fed_hens":0,"pending_eggs":2})
	assert_eq(state.feed(10,2).feed_units,2)
	assert_eq(state.feed(10,2).fed_hens,4)
	assert_eq(state.advance_day(10).produced,4)
	assert_eq(state.serialize().pending_eggs,6)
	var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	config.feed_per_hen = 3
	config.eggs_per_fed_hen = 2
	state = _fresh(0,3,config)
	assert_eq(state.feed(0,2).feed_units,6,"Costs come from Resource")
	assert_eq(state.advance_day(0).produced,4,"Yield comes from Resource")
	assert_eq(state.serialize().hen_count,3)

func test_duplicate_stale_skipped_day_and_invalid_feed_commands_are_atomic() -> void:
	var state: ChickenCoopState = _fresh(5)
	state.feed(5,2)
	var before: Dictionary = state.serialize()
	for amount: int in [-1,0,3,4,9223372036854775807]:
		assert_false(state.feed(5,amount).ok)
		assert_eq(state.serialize(),before)
	for day: int in [-1,4,6,LIMIT]:
		assert_eq(state.feed(day,1).reason,&"wrong_day")
		assert_eq(state.advance_day(day).reason,&"wrong_day")
		assert_eq(state.serialize(),before)
	assert_eq(state.advance_day(5).produced,2)
	before = state.serialize()
	assert_false(state.advance_day(5).ok)
	assert_false(state.feed(5,1).ok)
	assert_eq(state.serialize(),before)
	state.feed(6,4)
	before = state.serialize()
	assert_false(state.feed(6,1).ok)
	assert_eq(state.serialize(),before)

func test_trusted_output_extraction_is_exact_once_and_stale_requests_retain_eggs() -> void:
	var state: ChickenCoopState = _fresh()
	state.feed(0,4)
	state.advance_day(0)
	var before: Dictionary = state.serialize()
	for amount: int in [-1,0,1,3,5,LIMIT]:
		assert_eq(state.take_eggs(amount).reason,&"stale_quantity")
		assert_eq(state.serialize(),before)
	assert_eq(state.take_eggs(4),{"ok":true,"reason":&"collected","item_id":&"egg","quantity":4})
	assert_false(state.take_eggs(4).ok)
	assert_eq(state.serialize().pending_eggs,0)
	assert_eq(state.serialize().hen_count,4)

func test_buffer_and_day_overflow_keep_feed_eggs_herd_and_day_unchanged() -> void:
	var config: ChickenCoopConfig = CONFIG.duplicate() as ChickenCoopConfig
	config.hen_capacity = LIMIT
	var state: ChickenCoopState = _fresh(0,LIMIT,config)
	assert_eq(state.feed(0,LIMIT).feed_units,LIMIT)
	assert_eq(state.advance_day(0).produced,LIMIT)
	state.feed(1,1)
	var before: Dictionary = state.serialize()
	assert_eq(state.advance_day(1).reason,&"numeric_overflow")
	assert_eq(state.serialize(),before)
	assert_eq(state.take_eggs(LIMIT).quantity,LIMIT)
	assert_eq(state.advance_day(1).produced,1,"Rejected day retained authorized feed")
	state = _fresh(LIMIT-1)
	assert_true(state.advance_day(LIMIT-1).ok)
	state.feed(LIMIT,4)
	before = state.serialize()
	assert_eq(state.advance_day(LIMIT).reason,&"numeric_overflow")
	assert_eq(state.serialize(),before)
	config = CONFIG.duplicate() as ChickenCoopConfig
	state = _fresh(0,4,config)
	state.feed(0,2)
	before = state.serialize()
	config.eggs_per_fed_hen = LIMIT
	assert_eq(state.advance_day(0).reason,&"invalid_state")
	assert_eq(state.serialize(),before)

func test_partial_feed_buffer_real_json_roundtrip_is_detached_and_canonical() -> void:
	var state: ChickenCoopState = _fresh(3)
	state.feed(3,4)
	state.advance_day(3)
	state.feed(4,2)
	var saved: Dictionary = state.serialize()
	var restored: ChickenCoopState = _fresh(0,0)
	restored.deserialize(JSON.parse_string(JSON.stringify(saved)))
	assert_eq(restored.serialize(),{"current_day":4,"hen_count":4,"fed_hens":2,"pending_eggs":4})
	assert_eq(restored.serialize(),saved)
	assert_eq(saved.keys().size(),4,"No config reference or runtime flag in wire data")
	saved.fed_hens = 4
	saved.pending_eggs = 0
	assert_eq(restored.advance_day(4).produced,2)
	assert_eq(restored.serialize().pending_eggs,6)
	restored.deserialize({"current_day":10.0,"hen_count":3.0,"fed_hens":1.0,"pending_eggs":12.0,"unknown":"ignored"})
	assert_eq(restored.serialize(),{"current_day":10,"hen_count":3,"fed_hens":1,"pending_eggs":12})

func test_malformed_or_missing_fields_reject_entire_snapshot_without_clamping_or_grants() -> void:
	var state: ChickenCoopState = _fresh()
	state.feed(0,4)
	state.advance_day(0)
	state.feed(1,2)
	var before: Dictionary = state.serialize()
	for field: String in ["current_day","hen_count","fed_hens","pending_eggs"]:
		for value: Variant in [null,true,"2",[],{},-1,1.5,INF,NAN,LIMIT+1]:
			var invalid: Dictionary = before.duplicate(true)
			invalid[field] = value
			state.deserialize(invalid)
			assert_eq(state.serialize(),before,field+" rejects malformed input atomically")
		var missing: Dictionary = before.duplicate(true)
		missing.erase(field)
		state.deserialize(missing)
		assert_eq(state.serialize(),before)
	state.deserialize({})
	assert_eq(state.serialize(),before)
	for counts: Vector2i in [Vector2i(5,0),Vector2i(2,3),Vector2i(0,1)]:
		state.deserialize({"current_day":1,"hen_count":counts.x,"fed_hens":counts.y,"pending_eggs":99})
		assert_eq(state.serialize(),before)
	assert_eq(state.advance_day(1).produced,2)
	assert_eq(state.serialize().pending_eggs,6)
