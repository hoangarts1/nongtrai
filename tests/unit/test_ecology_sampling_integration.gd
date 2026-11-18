extends GutTest

const CONFIG: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
var _season: StringName
var _farm: FarmGridState
var _land: LandOwnershipState
var _metrics: Dictionary = {}

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"summer"
	_farm = FarmGridState.new()
	_land = LandOwnershipState.new()
	_land.configure(LAND)
	_metrics = {"tree_cover": 0.0, "water_clarity": 41.25, "biodiversity": 0.0}

func after_each() -> void:
	GameClock.season = _season
	_farm = null
	_land = null

func _plant(cell: Vector2i, id: StringName) -> void:
	assert_true(_farm.till_cell(cell))
	assert_true(_farm.plant_crop(cell, id))

func _sample() -> Dictionary:
	return EcologySampler.sample(CONFIG, _farm.serialize(), DataRegistry.get_all_crops(), _land.get_owned_regions(), _metrics)

func _care(days: int) -> void:
	# Fixture drives the existing pure farm transition; no new runtime day path.
	for day: int in range(days):
		_farm.water_all_crops()
		_farm.advance_day()

func test_real_plant_mature_harvest_repeat_wither_and_revive_snapshots() -> void:
	var cell: Vector2i = Vector2i.ZERO
	_plant(cell, &"orange")
	assert_eq(_sample().counts, {"mature_fruit_trees": 0, "healthy_plants": 1, "species": 1})
	var target: int = _farm.get_growth_target(cell)
	_care(target - 1)
	assert_eq(_sample().counts.mature_fruit_trees, 0)
	_care(1)
	assert_true(_farm.can_harvest(cell))
	assert_eq(_sample().counts.mature_fruit_trees, 1)
	assert_true(_farm.harvest_cell(cell).success)
	assert_true(_farm.get_plot(cell).regrowing)
	assert_eq(_farm.get_plot(cell).growth_days, 0)
	assert_eq(_sample().counts.mature_fruit_trees, 1)
	_farm.advance_day()
	_farm.advance_day()
	assert_true(_farm.get_plot(cell).withered)
	assert_eq(_sample().counts.healthy_plants, 0)
	assert_true(_farm.water_cell(cell))
	assert_eq(_sample().counts.mature_fruit_trees, 1)
	assert_eq(_sample().counts.species, 1)

func test_real_owned_regions_unlock_without_deleting_unowned_farm_data() -> void:
	_plant(Vector2i.ZERO, &"summer_corn")
	_plant(Vector2i(6, 0), &"corn")
	_plant(Vector2i(7, 0), &"banana")
	assert_eq(_sample().counts, {"mature_fruit_trees": 0, "healthy_plants": 1, "species": 1})
	var farm_before: Dictionary = _farm.serialize()
	assert_true(_land.grant_next(_land.next_parcel_id()))
	assert_eq(_sample().counts, {"mature_fruit_trees": 0, "healthy_plants": 3, "species": 2})
	assert_eq(_farm.serialize(), farm_before)
	var restored: FarmGridState = FarmGridState.new()
	restored.deserialize(JSON.parse_string(JSON.stringify(farm_before)))
	var result: Dictionary = EcologySampler.sample(CONFIG, restored.serialize(), DataRegistry.get_all_crops(), _land.get_owned_regions(), _metrics)
	assert_eq(result, _sample(), "Actual farm wire round-trip keeps sampling")

func test_real_single_harvest_removes_species_and_bridge_advances_only_explicit_ecology_day() -> void:
	_plant(Vector2i.ZERO, &"corn")
	var ecology: EcologyState = EcologyState.new()
	assert_true(ecology.configure(PROFILE))
	assert_true(ecology.deserialize({"day_index": 0, "metrics": _metrics, "triggered": []}))
	var saved_clock: Dictionary = GameClock.serialize()
	var farm_before: Dictionary = _farm.serialize()
	var land_before: Dictionary = _land.serialize()
	var state_before: Dictionary = ecology.serialize()
	var sample: Dictionary = _sample()
	assert_eq(ecology.serialize(), state_before, "Sampling alone never advances ecology")
	assert_eq(_farm.serialize(), farm_before)
	assert_eq(_land.serialize(), land_before)
	assert_eq(GameClock.serialize(), saved_clock)
	assert_true(ecology.advance_day(1, sample.targets).ok)
	assert_eq(ecology.get_metrics().water_clarity, 41.25)
	assert_eq(ecology.get_metrics().biodiversity, 1.25)
	assert_eq(ecology.get_day_index(), 1)
	assert_false(ecology.advance_day(1, sample.targets).ok)
	_care(_farm.get_growth_target(Vector2i.ZERO))
	assert_true(_farm.harvest_cell(Vector2i.ZERO).success)
	assert_eq(_sample().counts.species, 0)
	assert_eq(ecology.get_day_index(), 1, "Farm transitions do not register a live ecology hook")
