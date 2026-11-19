extends GutTest

const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const EFFECTS: Script = preload("res://tests/unit/test_director_effect_projection.gd")
var _season: StringName

class RejectFarm extends FarmGridState:
	var callback: Callable
	func water_cell(_cell: Vector2i) -> bool:
		if callback.is_valid():
			callback.call()
		return false

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"spring"

func after_each() -> void:
	GameClock.season = _season

func _state(charges: int = 5) -> WateringCanState:
	var result: WateringCanState = WateringCanState.new()
	result.configure(CONFIG)
	result.deserialize({"capacity": 20, "charges": charges})
	return result

func _plant(farm: FarmGridState, cell: Vector2i = Vector2i.ZERO) -> void:
	assert_true(farm.till_cell(cell))
	assert_true(farm.plant_crop(cell, &"turnip"))

func _terms() -> Dictionary:
	var owner: DirectorState = EFFECTS.active_dust()
	return DirectorEffectProjector.project(EFFECTS.PROFILE, owner.serialize(), EFFECTS.observation(owner)).water

func _service(state: WateringCanState, farm: FarmGridState) -> WateringService:
	var service: WateringService = WateringService.new()
	service.configure(CONFIG, state, farm)
	assert_true(service.set_effect_terms(_terms()))
	return service

func test_two_charge_debit_is_atomic_insufficient_rejects_before_farm_and_rain_stays_free() -> void:
	var state: WateringCanState = _state(1)
	var farm: FarmGridState = FarmGridState.new()
	_plant(farm)
	var service: WateringService = _service(state, farm)
	var before: Dictionary = farm.serialize()
	assert_eq(service.get_charge_cost(), 2)
	assert_eq(service.water(Vector2i.ZERO).reason, &"water_insufficient")
	assert_eq(state.get_charges(), 1)
	assert_eq(farm.serialize(), before)
	assert_true(state.refill())
	assert_true(service.water(Vector2i.ZERO).ok)
	assert_eq(state.get_charges(), 18)
	assert_eq(service.water(Vector2i.ZERO).reason, &"already_watered")
	farm.water_all_crops()
	DaySimulator.new().simulate_day(farm)
	assert_eq(state.get_charges(), 18)

func test_bulk_primitives_reject_overflow_stale_revision_and_preserve_upgrade_and_one_apis() -> void:
	var state: WateringCanState = _state()
	for amount: int in [0, -1, 6, 9223372036854775807]:
		assert_false(state.try_consume_charges(amount, 5))
	assert_false(state.try_consume_charges(2, 4))
	var revision: int = state.get_refill_revision()
	assert_true(state.try_consume_charges(2, 5, revision))
	assert_eq(state.get_charges(), 3)
	assert_true(state.try_upgrade(20, 40))
	assert_true(state.refund_charges(2, revision))
	assert_eq(state.get_charges(), 5)
	assert_true(state.try_consume_one(5))
	assert_true(state.refund_one(revision))
	assert_true(state.refill())
	assert_false(state.refund_charges(2, revision))
	assert_false(state.try_consume_charges(2, 40, revision))
	for amount: int in [0, -1, 9223372036854775807]:
		assert_false(state.refund_charges(amount))
	assert_eq(state.serialize(), {"capacity": 40, "charges": 40})

func test_rejected_command_refunds_only_own_two_charges_across_independent_use_refill_load_upgrade() -> void:
	var state: WateringCanState = _state()
	var farm: RejectFarm = RejectFarm.new()
	_plant(farm)
	var service: WateringService = _service(state, farm)
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.get_charges(), 5)
	farm.callback = func() -> void: state.try_consume_one(state.get_charges())
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.get_charges(), 4)
	farm.callback = func() -> void: state.try_upgrade(20, 40)
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.serialize(), {"capacity": 40, "charges": 4})
	farm.callback = func() -> void:
		state.refill()
		state.try_consume_one(state.get_charges())
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.get_charges(), 39)
	farm.callback = func() -> void: state.deserialize({"capacity": 20, "charges": 7})
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.serialize(), {"capacity": 20, "charges": 7})
	farm.callback = Callable()

func test_quotes_and_signal_reentry_capture_original_cost_and_owners() -> void:
	var state: WateringCanState = _state()
	var farm: FarmGridState = FarmGridState.new()
	_plant(farm)
	_plant(farm, Vector2i.ONE)
	var service: WateringService = _service(state, farm)
	var quote: Dictionary = service.can_water(Vector2i.ZERO)
	assert_true(service.set_effect_terms({}))
	assert_eq(service.water(Vector2i.ZERO, quote).reason, &"stale_quote")
	assert_eq(state.get_charges(), 5)
	assert_true(service.set_effect_terms(_terms()))
	quote = service.can_water(Vector2i.ZERO)
	assert_true(state.refill())
	assert_eq(service.water(Vector2i.ZERO, quote).reason, &"stale_quote")
	var replies: Array = []
	var callback: Callable = func(cell: Vector2i) -> void:
		if cell == Vector2i.ZERO:
			replies.append(service.water(Vector2i.ONE).reason)
			replies.append(service.set_effect_terms({}))
	farm.plot_changed.connect(callback)
	assert_true(service.water(Vector2i.ZERO).ok)
	farm.plot_changed.disconnect(callback)
	assert_eq(replies, [&"watering_busy", false])
	assert_eq(state.get_charges(), 18)
	assert_false(farm.get_plot(Vector2i.ONE).watered)
