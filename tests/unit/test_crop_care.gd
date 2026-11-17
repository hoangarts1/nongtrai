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

func test_missed_stage_transition_day_withers_current_stage() -> void:
	var farm: FarmGridState = _planted()
	farm.advance_day()
	assert_false(farm.get_plot(Vector2i.ZERO)["withered"])
	farm.advance_day()
	var plot: Dictionary = farm.get_plot(Vector2i.ZERO)
	assert_true(plot["withered"])
	assert_eq(plot["growth_days"],0)
	assert_eq(plot["withered_days"],1)

func test_manual_and_rain_watering_restore_withered_crop() -> void:
	for rain: bool in [false, true]:
		var farm: FarmGridState = _planted()
		farm.advance_day()
		farm.advance_day()
		assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
		if rain:
			farm.water_all_crops()
		else:
			assert_true(farm.water_cell(Vector2i.ZERO))
		assert_false(farm.get_plot(Vector2i.ZERO)["withered"])
		assert_eq(farm.get_plot(Vector2i.ZERO)["withered_days"],0)
		farm.advance_day()
		assert_eq(farm.get_plot(Vector2i.ZERO)["crop_id"],&"turnip")

func test_second_consecutive_withered_day_kills_crop() -> void:
	var farm: FarmGridState = _planted()
	farm.advance_day()
	farm.advance_day()
	assert_true(farm.get_plot(Vector2i.ZERO)["withered"])
	farm.advance_day()
	var plot: Dictionary = farm.get_plot(Vector2i.ZERO)
	assert_eq(plot["crop_id"],&"")
	assert_true(plot["tilled"])
	assert_false(plot["withered"])

func test_withered_crop_does_not_grow_or_harvest() -> void:
	var farm: FarmGridState = _planted()
	farm.advance_day()
	farm.advance_day()
	var before: int = farm.get_plot(Vector2i.ZERO)["growth_days"]
	assert_false(farm.can_harvest(Vector2i.ZERO))
	farm.advance_day()
	assert_eq(farm.get_plot(Vector2i.ZERO)["growth_days"],before)

func test_shovel_clears_withered_crop_and_preserves_tilled_plot() -> void:
	var farm: FarmGridState = _planted()
	farm.advance_day()
	farm.advance_day()
	assert_true(ToolAction.apply(&"shovel",farm,Vector2i.ZERO,&""))
	assert_true(farm.get_plot(Vector2i.ZERO)["tilled"])
	assert_eq(farm.get_plot(Vector2i.ZERO)["crop_id"],&"")
	assert_true(farm.plant_crop(Vector2i.ZERO,&"turnip"))

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
	assert_false(farm.get_plot(Vector2i.ZERO)["withered"])

func test_validator_rejects_missing_care_threshold_without_changing_balance_rules() -> void:
	assert_true(DataValidator.validate_crop_references(DataRegistry.get_all_crops(),DataRegistry.get_all_items()).is_empty())
	_crop.max_consecutive_dry_days = 0
	assert_string_contains("\n".join(DataValidator.validate_crop_references([_crop],DataRegistry.get_all_items())),"max_consecutive_dry_days")
	_crop.water_need = 0
	assert_true(DataValidator.validate_crop_references([_crop],DataRegistry.get_all_items()).is_empty())
