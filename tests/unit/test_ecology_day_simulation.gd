extends GutTest

const COOP: ChickenCoopConfig = preload("res://data/chicken_coop_config.tres")
const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")

class MachineSpy extends RefCounted:
	var trail: Array[String] = []
	var coop: ChickenCoopState
	var animal_day_seen: int = -1
	func advance_day() -> void:
		animal_day_seen = int(coop.serialize().current_day)
		trail.append("machine")

func test_order_is_farm_then_animals_then_machines_then_reserved_ecology() -> void:
	var farm: FarmGridState = FarmGridState.new()
	var coop: ChickenCoopState = ChickenCoopState.new()
	coop.configure(COOP, 0, 0)
	var machine: MachineSpy = MachineSpy.new()
	machine.coop = coop
	var ecology: EcologyState = EcologyState.new()
	assert_true(ecology.configure(PROFILE))
	var reservation: Dictionary = ecology.begin_day(1)
	var farm_step: Callable = func(owner: FarmGridState) -> void:
		machine.trail.append("farm")
		owner.advance_day()
	var ecology_step: Callable = func() -> void:
		assert_eq(machine.trail, ["farm", "machine"])
		assert_eq(machine.animal_day_seen, 1)
		assert_eq(int(coop.serialize().current_day), 1)
		assert_true(ecology.finish_day(reservation.token, {"tree_cover": 100, "water_clarity": 0, "biodiversity": 0}).ok)
		machine.trail.append("ecology")
	DaySimulator.new().simulate_day(farm, coop, machine, 0, farm_step, ecology_step)
	assert_eq(machine.trail, ["farm", "machine", "ecology"])
	assert_eq(ecology.get_metrics().tree_cover, 10.0)
	assert_eq(ecology.get_day_index(), 1)

func test_invalid_animal_day_stops_every_callback_before_farm_or_ecology() -> void:
	var farm: FarmGridState = FarmGridState.new()
	var coop: ChickenCoopState = ChickenCoopState.new()
	coop.configure(COOP, 3, 0)
	var calls: Array[String] = []
	DaySimulator.new().simulate_day(farm, coop, null, 0, func(_farm: FarmGridState) -> void: calls.append("farm"), func() -> void: calls.append("ecology"))
	assert_eq(calls, [])
	assert_eq(int(coop.serialize().current_day), 3)

func test_existing_optional_callback_and_positional_callers_keep_their_behavior() -> void:
	var farm: FarmGridState = FarmGridState.new()
	var calls: Array[int] = [0]
	DaySimulator.new().simulate_day(farm)
	DaySimulator.new().simulate_day(farm, null, null, -1, func(_owner: FarmGridState) -> void: calls[0] += 1)
	assert_eq(calls[0], 1)
	assert_eq(farm.serialize(), {"plots": []})
