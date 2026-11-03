extends GutTest

func test_exact_approved_data_table_and_retained_price_gate() -> void:
	var expected: Dictionary = {&"spring_carrot":[3,0,20,35],&"summer_tomato":[5,2,35,72],&"turnip":[4,0,25,45],&"summer_corn":[7,0,35,100]}
	for id: StringName in expected:
		var crop: CropData = DataRegistry.get_crop(id) as CropData
		var seed: ItemData = DataRegistry.get_item(crop.seed_item) as ItemData
		var product: ItemData = DataRegistry.get_item(crop.product_item) as ItemData
		assert_eq([crop.growth_days,crop.regrow_days,seed.buy_price,product.sell_price],expected[id])
		assert_eq(crop.yield_qty,2)
		assert_eq(crop.max_consecutive_dry_days,2)
	var config: CropEconomyConfig = preload("res://data/crop_economy_config.tres")
	assert_eq(config.max_profit_per_plot_day,80)
	assert_true(DataValidator.validate_crop_references(DataRegistry.get_all_crops(),DataRegistry.get_all_items()).is_empty())
	assert_true(DataValidator.validate_crop_economy(config,DataRegistry.get_all_crops(),DataRegistry.get_all_items()).is_empty())

func test_integer_profit_gate_rejects_fractional_excess_without_rounding_down() -> void:
	var crop: CropData = CropData.new()
	crop.crop_id = &"test"
	crop.seed_item = &"test_seed"
	crop.product_item = &"test_product"
	crop.yield_qty = 1
	crop.growth_days = 2
	var seed: ItemData = ItemData.new()
	seed.item_id = crop.seed_item
	seed.buy_price = 1
	var product: ItemData = ItemData.new()
	product.item_id = crop.product_item
	product.sell_price = 3
	var config: CropEconomyConfig = CropEconomyConfig.new()
	config.max_profit_per_plot_day = 1
	assert_true(CropEconomyRules.validate(config,[crop],[seed,product]).is_empty())
	product.sell_price = 4
	assert_string_contains("\n".join(CropEconomyRules.validate(config,[crop],[seed,product])),"initial")
	product.sell_price = 3
	crop.regrow_days = 2
	assert_string_contains("\n".join(CropEconomyRules.validate(config,[crop],[seed,product])),"repeat")

func test_repeat_ceiling_exact_boundary_and_invalid_config_or_durations() -> void:
	var crop: CropData = (DataRegistry.get_crop(&"summer_tomato") as CropData).duplicate() as CropData
	var config: CropEconomyConfig = CropEconomyConfig.new()
	config.max_profit_per_plot_day = 72
	assert_true(CropEconomyRules.validate(config,[crop],DataRegistry.get_all_items()).is_empty())
	config.max_profit_per_plot_day = 71
	assert_string_contains("\n".join(CropEconomyRules.validate(config,[crop],DataRegistry.get_all_items())),"repeat")
	config.max_profit_per_plot_day = 80
	crop.growth_days = 0
	assert_false(CropEconomyRules.validate(config,[crop],DataRegistry.get_all_items()).is_empty())
	crop.growth_days = 5
	crop.regrow_days = -1
	assert_false(CropEconomyRules.validate(config,[crop],DataRegistry.get_all_items()).is_empty())
	config.max_profit_per_plot_day = 0
	assert_false(CropEconomyRules.validate(config,[],[]).is_empty())
	assert_false(CropEconomyRules.validate(null,[],[]).is_empty())
	config.max_profit_per_plot_day = 9223372036854775807
	assert_false(CropEconomyRules.validate(config,[],[]).is_empty())

func test_historical_duration_data_is_complete_and_unknown_or_missing_ids_fail() -> void:
	var config: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")
	assert_true(DataValidator.validate_crop_migration(config,DataRegistry.get_all_crops()).is_empty())
	var changed: CropMigrationConfig = config.duplicate(true) as CropMigrationConfig
	changed.previous_growth_days.erase(&"turnip")
	assert_false(DataValidator.validate_crop_migration(changed,DataRegistry.get_all_crops()).is_empty())
	changed = config.duplicate(true) as CropMigrationConfig
	changed.previous_growth_days[&"unknown"] = 2
	assert_false(DataValidator.validate_crop_migration(changed,DataRegistry.get_all_crops()).is_empty())
	changed.previous_growth_days.erase(&"unknown")
	changed.previous_growth_days[&"turnip"] = 1.5
	assert_false(DataValidator.validate_crop_migration(changed,DataRegistry.get_all_crops()).is_empty())
	assert_false(DataValidator.validate_crop_migration(null,[]).is_empty())
