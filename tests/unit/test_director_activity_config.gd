extends GutTest

const SHIPPED: DirectorActivityConfig = preload("res://data/director_activity_config.tres")

func test_shipped_window_and_counter_sources_match_actual_registered_signals() -> void:
	assert_eq(SHIPPED.window_days, 7)
	assert_eq(SHIPPED.activity_ids.size(), 6)
	assert_eq(DataValidator.validate_director_activity(SHIPPED), PackedStringArray())
	for id: String in SHIPPED.activity_ids:
		assert_true(Events.has_signal(StringName(id)), id)
		if id in ["crop_harvested", "item_purchased", "item_sold"]:
			var quantity_found: bool = false
			for definition: Dictionary in Events.get_signal_list():
				if String(definition.name) == id:
					for argument: Dictionary in definition.args:
						if String(argument.name) == "quantity" and int(argument.type) == TYPE_INT:
							quantity_found = true
			assert_true(quantity_found, "Source quantity has an actual typed producer contract")

func test_null_invalid_window_and_incomplete_duplicate_or_unknown_ids_fail() -> void:
	assert_false(DataValidator.validate_director_activity(null).is_empty())
	for days: int in [-1, 0, 6, 15, 2147483647]:
		var config: DirectorActivityConfig = SHIPPED.duplicate(true) as DirectorActivityConfig
		config.window_days = days
		assert_false(config.validation_errors().is_empty())
	for ids: PackedStringArray in [PackedStringArray(), PackedStringArray(["wood_chopped"]), PackedStringArray(["plot_tilled", "plot_tilled", "plot_watered", "crop_harvested", "item_purchased", "item_sold"]), PackedStringArray(["Plot_tilled", "crop_planted", "plot_watered", "crop_harvested", "item_purchased", "item_sold"])]:
		var config: DirectorActivityConfig = SHIPPED.duplicate(true) as DirectorActivityConfig
		config.activity_ids = ids
		assert_false(config.validation_errors().is_empty())
	assert_eq(SHIPPED.validation_errors(), PackedStringArray())

func test_all_supported_window_lengths_validate_without_silently_adjusting_data() -> void:
	for days: int in range(7, 15):
		var config: DirectorActivityConfig = SHIPPED.duplicate(true) as DirectorActivityConfig
		config.window_days = days
		assert_eq(config.validation_errors(), PackedStringArray())
		assert_eq(config.window_days, days)
