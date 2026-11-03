extends GutTest

var _season: StringName
var _crop: CropData
var _water_need: int
var _threshold: int

func before_each() -> void:
	_season = GameClock.season
	GameClock.season = &"spring"
	_crop = DataRegistry.get_crop(&"turnip") as CropData
	_water_need = _crop.water_need
	_threshold = _crop.max_consecutive_dry_days

func after_each() -> void:
	_crop.water_need = _water_need
	_crop.max_consecutive_dry_days = _threshold
	GameClock.season = _season

func _planted() -> FarmGridState:
	var farm: FarmGridState = FarmGridState.new()
	farm.till_cell(Vector2i.ZERO)
	farm.plant_crop(Vector2i.ZERO, &"turnip")
	return farm

func test_second_consecutive_dry_day_withers_once_and_cannot_revive_or_yield() -> void:
	var farm: FarmGridState = _planted()
	var simulator: DaySimulator = DaySimulator.new()
	assert_eq(farm.get_dry_days_remaining(Vector2i.ZERO),2)
	simulator.simulate_day(farm)
	assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],1)
	assert_eq(farm.get_dry_days_remaining(Vector2i.ZERO),1)
	assert_false(farm.get_plot(Vector2i.ZERO)["withered"])
	assert_eq(farm.get_plot(Vector2i.ZERO)["growth_days"],0)
	watch_signals(farm)
	simulator.simulate_day(farm)
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	assert_eq(farm.get_dry_days_remaining(Vector2i.ZERO),0)
	var snapshot: Dictionary = farm.serialize()
	for day: int in range(3):
		simulator.simulate_day(farm)
		farm.water_all_crops()
		assert_false(farm.water_cell(Vector2i.ZERO))
		assert_false(farm.can_harvest(Vector2i.ZERO))
		assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])
		assert_eq(farm.serialize(),snapshot)
	assert_signal_emit_count(farm,"plot_changed",1,"Withered state transitions once")
	assert_true(farm.clear_withered(Vector2i.ZERO))
	assert_true(farm.till_cell(Vector2i.ZERO))
	assert_true(farm.plant_crop(Vector2i.ZERO,&"turnip"))
	assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],0)

func test_manual_and_rain_watering_reset_dry_streak_without_free_growth() -> void:
	for rain: bool in [false,true]:
		var farm: FarmGridState = _planted()
		farm.advance_day()
		if rain:
			farm.water_all_crops()
		else:
			assert_true(farm.water_cell(Vector2i.ZERO))
		assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],0)
		assert_eq(farm.get_plot(Vector2i.ZERO)["growth_days"],0)
		assert_false(farm.water_cell(Vector2i.ZERO),"Repeated care cannot grow a crop")
		farm.advance_day()
		assert_eq(farm.get_plot(Vector2i.ZERO)["growth_days"],1)
		assert_false(farm.get_plot(Vector2i.ZERO)["watered"])
		farm.advance_day()
		assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],1)
		assert_false(farm.get_plot(Vector2i.ZERO)["withered"])

func test_ripe_crop_still_needs_care_and_withered_maturity_does_not_bypass_guard() -> void:
	var farm: FarmGridState = _planted()
	for day: int in range(_crop.growth_days):
		farm.water_cell(Vector2i.ZERO)
		farm.advance_day()
	assert_true(farm.can_harvest(Vector2i.ZERO))
	farm.advance_day()
	assert_true(farm.can_harvest(Vector2i.ZERO))
	farm.advance_day()
	assert_false(farm.can_harvest(Vector2i.ZERO))
	assert_eq(farm.get_harvest_payload(Vector2i.ZERO)["quantity"],0)
	assert_gte(farm.get_plot(Vector2i.ZERO)["growth_days"],_crop.growth_days)

func test_threshold_is_resource_owned_and_water_free_crop_never_withers_from_dryness() -> void:
	_crop.max_consecutive_dry_days = 3
	var farm: FarmGridState = _planted()
	for day: int in range(2):
		farm.advance_day()
		assert_false(farm.get_plot(Vector2i.ZERO)["withered"])
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	_crop.water_need = 0
	_crop.max_consecutive_dry_days = 0
	farm = _planted()
	for day: int in range(8):
		farm.advance_day()
	assert_true(farm.can_harvest(Vector2i.ZERO))
	assert_eq(farm.get_plot(Vector2i.ZERO)["consecutive_dry_days"],0)
	assert_eq(farm.get_dry_days_remaining(Vector2i.ZERO),0)
	assert_false(farm.get_plot(Vector2i.ZERO)["withered"])

func test_out_of_season_wither_is_terminal_and_full_inventory_keeps_harvest() -> void:
	var farm: FarmGridState = _planted()
	for day: int in range(_crop.growth_days):
		farm.water_cell(Vector2i.ZERO)
		farm.advance_day()
	var inventory: InventoryState = InventoryState.new(1)
	inventory.add_item(&"turnip",(DataRegistry.get_item(&"turnip") as ItemData).max_stack)
	var before: Dictionary = farm.serialize()
	assert_false(inventory.can_add_item(&"turnip",_crop.yield_qty))
	assert_eq(farm.serialize(),before)
	GameClock.season = &"winter"
	farm.mark_out_of_season()
	assert_false(farm.can_harvest(Vector2i.ZERO))
	GameClock.season = &"spring"
	farm.water_all_crops()
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	assert_false(farm.harvest_cell(Vector2i.ZERO)["success"])

func test_validator_rejects_missing_care_threshold_without_changing_balance_rules() -> void:
	assert_true(DataValidator.validate_crop_references(DataRegistry.get_all_crops(),DataRegistry.get_all_items()).is_empty())
	_crop.max_consecutive_dry_days = 0
	assert_string_contains("\n".join(DataValidator.validate_crop_references([_crop],DataRegistry.get_all_items())),"max_consecutive_dry_days")
	_crop.water_need = 0
	assert_true(DataValidator.validate_crop_references([_crop],DataRegistry.get_all_items()).is_empty())
