extends GutTest
const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
var _season: StringName
var _watches: Array[Dictionary] = []

class RejectFarm extends FarmGridState:
	var before_rejection: Callable
	func water_cell(_cell: Vector2i) -> bool:
		if before_rejection.is_valid():
			before_rejection.call()
		return false

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"spring"

func after_each() -> void:
	for entry: Dictionary in _watches:
		var farm: FarmGridState = entry.farm
		farm.plot_changed.disconnect(entry.callback)
	_watches.clear()
	GameClock.season = _season

func _watch(farm: FarmGridState, callback: Callable) -> void:
	farm.plot_changed.connect(callback)
	_watches.append({"farm":farm,"callback":callback})

func _state(charges: int = 20) -> WateringCanState:
	var state: WateringCanState = WateringCanState.new()
	state.configure(CONFIG)
	state.deserialize({"capacity":20,"charges":charges})
	return state

func _plant(farm: FarmGridState, cell: Vector2i = Vector2i.ZERO) -> void:
	assert_true(farm.till_cell(cell))
	assert_true(farm.plant_crop(cell,&"turnip"))

func _service(state: WateringCanState, farm: FarmGridState) -> WateringService:
	var service: WateringService = WateringService.new()
	service.configure(CONFIG,state,farm)
	return service

func test_preview_invalid_empty_repeated_and_capacity_boundary_use_only_actual_water() -> void:
	var state: WateringCanState = _state()
	var farm: FarmGridState = FarmGridState.new()
	var service: WateringService = _service(state,farm)
	assert_eq(WateringService.new().water(Vector2i.ZERO).reason,&"invalid_service")
	assert_eq(service.water(Vector2i.ZERO).reason,&"no_crop")
	assert_true(farm.till_cell(Vector2i(-1,0)))
	assert_eq(service.water(Vector2i(-1,0)).reason,&"no_crop")
	for index: int in range(21):
		_plant(farm,Vector2i(index,0))
	var before: Dictionary = {"farm":farm.serialize(),"can":state.serialize(),"clock":GameClock.serialize()}
	assert_true(service.can_water(Vector2i.ZERO).ok)
	assert_eq({"farm":farm.serialize(),"can":state.serialize(),"clock":GameClock.serialize()},before)
	for index: int in range(20):
		assert_true(service.water(Vector2i(index,0)).ok)
		assert_eq(state.get_charges(),19-index)
		assert_eq(service.water(Vector2i(index,0)).reason,&"already_watered")
	assert_eq(service.water(Vector2i(20,0)).reason,&"water_empty")
	assert_false(farm.get_plot(Vector2i(20,0)).watered)
	assert_true(state.refill())
	assert_true(service.water(Vector2i(20,0)).ok)
	assert_eq(state.get_charges(),19)

func test_actual_wither_recovery_and_free_bulk_day_watering_stay_unchanged() -> void:
	var state: WateringCanState = _state()
	var farm: FarmGridState = FarmGridState.new()
	_plant(farm)
	farm.advance_day()
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO).withered)
	assert_true(_service(state,farm).water(Vector2i.ZERO).ok)
	var plot: Dictionary = farm.get_plot(Vector2i.ZERO)
	assert_true(plot.watered)
	assert_false(plot.withered)
	assert_eq(plot.withered_days,0)
	assert_eq(plot.consecutive_dry_days,0)
	assert_eq(state.get_charges(),19)
	var rainy: FarmGridState = FarmGridState.new()
	_plant(rainy)
	rainy.advance_day()
	rainy.advance_day()
	rainy.water_all_crops()
	assert_false(rainy.get_plot(Vector2i.ZERO).withered)
	DaySimulator.new().simulate_day(rainy)
	assert_eq(state.get_charges(),19,"Rain/direct bulk/day paths do not own manual charges")

func test_rejected_farm_refunds_only_reservation_and_preserves_independent_refill_or_upgrade() -> void:
	var state: WateringCanState = _state(5)
	var farm: RejectFarm = RejectFarm.new()
	_plant(farm)
	var service: WateringService = _service(state,farm)
	var before: Dictionary = farm.serialize()
	assert_eq(service.water(Vector2i.ZERO).reason,&"watering_rejected")
	assert_eq(state.get_charges(),5)
	assert_eq(farm.serialize(),before)
	farm.before_rejection = func() -> void: state.try_consume_one(state.get_charges())
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.get_charges(),4,"Only this debit refunded; other consumption preserved")
	farm.before_rejection = func() -> void: state.try_upgrade(20,40)
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.serialize(),{"capacity":40,"charges":4})
	farm.before_rejection = func() -> void:
		state.refill()
		state.try_consume_one(state.get_charges())
	assert_false(service.water(Vector2i.ZERO).ok)
	assert_eq(state.serialize(),{"capacity":40,"charges":39},"Refill supersedes the old debit; later use cannot be refunded away")
	farm.before_rejection = Callable()

func test_actual_farm_signal_reentry_and_service_reconfiguration_keep_original_owners() -> void:
	var state: WateringCanState = _state()
	var farm: FarmGridState = FarmGridState.new()
	_plant(farm)
	_plant(farm,Vector2i.ONE)
	var service: WateringService = _service(state,farm)
	var other: WateringService = _service(state,farm)
	var separate_state: WateringCanState = _state()
	var separate_farm: FarmGridState = FarmGridState.new()
	_plant(separate_farm)
	var replies: Array[StringName] = []
	_watch(farm,func(cell: Vector2i) -> void:
		if cell!=Vector2i.ZERO:
			return
		replies.append(service.water(Vector2i.ONE).reason)
		replies.append(other.water(Vector2i.ZERO).reason)
		service.configure(CONFIG,separate_state,separate_farm)
	)
	assert_true(service.water(Vector2i.ZERO).ok)
	assert_eq(replies,[&"watering_busy",&"already_watered"])
	assert_eq(state.get_charges(),19)
	assert_true(farm.get_plot(Vector2i.ZERO).watered)
	assert_false(farm.get_plot(Vector2i.ONE).watered)
	assert_eq(separate_state.get_charges(),20)
	assert_false(separate_farm.get_plot(Vector2i.ZERO).watered)
