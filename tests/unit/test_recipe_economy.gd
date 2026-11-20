extends GutTest
const SHIPPED: RecipeEconomyConfig = preload("res://data/recipe_economy_config.tres")
var config: RecipeEconomyConfig
var recipe: RecipeData
var machine: MachineData
var input: ItemData
var output: ItemData
var items: Array[Resource]

func before_each() -> void:
	config = SHIPPED.duplicate(true) as RecipeEconomyConfig
	input = ItemData.new()
	input.item_id = &"fixture_input"
	input.sell_price = 10
	output = ItemData.new()
	output.item_id = &"fixture_output"
	output.sell_price = 30
	items = [input,output]
	recipe = RecipeData.new()
	recipe.recipe_id = &"fixture_recipe"
	recipe.inputs = [{"item_id":input.item_id,"quantity":2}]
	recipe.outputs = [{"item_id":output.item_id,"quantity":1}]
	recipe.machine_ids = PackedStringArray(["fixture_machine"])
	recipe.unlock_house_level = 1
	machine = MachineData.new()
	machine.machine_id = &"fixture_machine"
	machine.recipe_ids = PackedStringArray(["fixture_recipe"])

func _errors() -> PackedStringArray:
	return DataValidator.validate_recipe_economy(config,[recipe],[machine],items)

func test_shipped_terms_and_unpriced_products_remain_unchanged() -> void:
	assert_eq(config.game_hours_per_day,24)
	assert_eq(config.max_value_added_per_game_hour_by_unlock_level,{1:15,2:40,3:120})
	var before: Dictionary = {}
	for item: Resource in DataRegistry.get_all_items():
		before[item.item_id] = [item.sell_price,item.buy_price]
	assert_eq(DataValidator.validate_recipe_economy(SHIPPED,DataRegistry.get_all_recipes(),DataRegistry.get_all_machines(),DataRegistry.get_all_items()),PackedStringArray())
	for value: Resource in DataRegistry.get_all_recipes():
		var product: Resource = DataRegistry.get_item(StringName(value.outputs[0].item_id))
		assert_eq(product.sell_price,0)
		assert_eq(product.buy_price,0)
	for item: Resource in DataRegistry.get_all_items():
		assert_eq([item.sell_price,item.buy_price],before[item.item_id])
	assert_eq((preload("res://data/crop_economy_config.tres") as CropEconomyConfig).max_profit_per_plot_day,80)
	assert_eq(SaveService.CURRENT_VERSION,18)
	assert_eq((DataRegistry.get_item(&"chicken_feed") as ItemData).buy_price,20)
	assert_eq((DataRegistry.get_item(&"egg") as ItemData).sell_price,30)
	assert_eq((DataRegistry.get_item(&"autumn_wheat") as ItemData).sell_price,42)

func test_exact_hourly_boundary_passes_and_one_coin_over_fails_at_every_tier() -> void:
	for tier: int in [1,2,3]:
		recipe.unlock_house_level = tier
		for days: int in [1,2,5]:
			recipe.duration_days = days
			output.sell_price = 20+int(config.max_value_added_per_game_hour_by_unlock_level[tier])*days*24
			assert_eq(_errors(),PackedStringArray())
			output.sell_price += 1
			assert_string_contains("\n".join(_errors()),"exceeds value-added cap")

func test_actual_24_hour_duration_and_sell_opportunity_cost_are_used() -> void:
	input.buy_price = 999
	input.sell_price = 10
	output.sell_price = 380
	assert_eq(_errors(),PackedStringArray(),"20 opportunity cost +15*24 is permitted")
	output.sell_price = 381
	assert_string_contains("\n".join(_errors()),"exceeds value-added cap")
	recipe.duration_days = 2
	assert_eq(_errors(),PackedStringArray(),"A two-day recipe has twice the allowed value")

func test_nonpositive_value_added_is_allowed_without_inventing_price() -> void:
	for value: int in [0,1,20]:
		output.sell_price = value
		assert_eq(_errors(),PackedStringArray())
		assert_eq(output.sell_price,value)

func test_multiple_inputs_are_summed_before_comparing_cap() -> void:
	var second: ItemData = ItemData.new()
	second.item_id = &"second_input"
	second.sell_price = 20
	items.append(second)
	recipe.inputs.append({"item_id":second.item_id,"quantity":3})
	machine.input_slots = 2
	output.sell_price = 440
	assert_eq(_errors(),PackedStringArray(),"80 inputs +360 cap")
	output.sell_price = 441
	assert_string_contains("\n".join(_errors()),"exceeds value-added cap")

func test_malformed_config_or_unmapped_tier_is_not_a_free_cap() -> void:
	assert_false(DataValidator.validate_recipe_economy(null,[recipe],[machine],items).is_empty())
	config.max_value_added_per_game_hour_by_unlock_level.erase(2)
	assert_false(_errors().is_empty())
	config = SHIPPED.duplicate(true) as RecipeEconomyConfig
	config.max_value_added_per_game_hour_by_unlock_level[1] = 15.0
	assert_false(_errors().is_empty())
	config = SHIPPED.duplicate(true) as RecipeEconomyConfig
	config.max_value_added_per_game_hour_by_unlock_level[true] = 4
	assert_false(_errors().is_empty())
	config = SHIPPED.duplicate(true) as RecipeEconomyConfig
	config.game_hours_per_day = 0
	assert_false(_errors().is_empty())
	config = SHIPPED.duplicate(true) as RecipeEconomyConfig
	recipe.unlock_house_level = 4
	assert_string_contains("\n".join(_errors()),"no configured cap")

func test_checked_cost_sum_and_ceiling_overflow_fail_explicitly() -> void:
	input.sell_price = RecipeEconomyConfig.MAX_RULE_INTEGER
	recipe.inputs[0]["quantity"] = RecipeEconomyConfig.MAX_RULE_INTEGER
	machine.input_slots = 3
	for index: int in [1,2]:
		var extra: ItemData = ItemData.new()
		extra.item_id = StringName("input_%d" % index)
		extra.sell_price = RecipeEconomyConfig.MAX_RULE_INTEGER
		items.append(extra)
		recipe.inputs.append({"item_id":extra.item_id,"quantity":RecipeEconomyConfig.MAX_RULE_INTEGER})
	assert_string_contains("\n".join(_errors()),"arithmetic_overflow")
	recipe.inputs.resize(1)
	input.sell_price = 10
	recipe.inputs[0]["quantity"] = 2
	recipe.duration_days = RecipeEconomyConfig.MAX_RULE_INTEGER
	config.max_value_added_per_game_hour_by_unlock_level[1] = RecipeEconomyConfig.MAX_RULE_INTEGER
	assert_string_contains("\n".join(_errors()),"arithmetic_overflow")

func test_invalid_prices_or_quantities_fail_before_economy_math() -> void:
	output.sell_price = -1
	assert_string_contains("\n".join(_errors()),"price")
	output.sell_price = 30
	recipe.outputs[0]["quantity"] = 1.5
	assert_string_contains("\n".join(_errors()),"integer quantity")
