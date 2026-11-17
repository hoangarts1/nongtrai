extends GutTest
var recipe: RecipeData
var machine: MachineData
var input: ItemData
var output: ItemData

func before_each() -> void:
	input = ItemData.new()
	input.item_id = &"fixture_wheat"
	input.sell_price = 10
	output = ItemData.new()
	output.item_id = &"fixture_flour"
	output.sell_price = 30
	recipe = RecipeData.new()
	recipe.recipe_id = &"fixture_recipe"
	recipe.inputs = [{"item_id":input.item_id,"quantity":2}]
	recipe.outputs = [{"item_id":output.item_id,"quantity":1}]
	recipe.machine_ids = PackedStringArray(["fixture_mill"])
	recipe.unlock_house_level = 1
	machine = MachineData.new()
	machine.machine_id = &"fixture_mill"
	machine.recipe_ids = PackedStringArray(["fixture_recipe"])

func _errors() -> PackedStringArray:
	return DataValidator.validate_recipe_catalog([recipe],[machine],[input,output])

func test_complete_registered_catalog_enumeration_and_purity() -> void:
	var recipes: Array[Resource] = DataRegistry.get_all_recipes()
	var machines: Array[Resource] = DataRegistry.get_all_machines()
	var items: Array[Resource] = DataRegistry.get_all_items()
	assert_eq(recipes.size(),7)
	assert_eq(machines.size(),7)
	var before: String = _snapshot(recipes,machines,items)
	assert_eq(DataValidator.validate_recipe_catalog(recipes,machines,items),PackedStringArray())
	assert_eq(_snapshot(recipes,machines,items),before)
	recipes.clear()
	machines.clear()
	assert_eq(DataRegistry.get_all_recipes().size(),7,"Enumeration returns a detached array")
	assert_eq(DataRegistry.get_all_machines().size(),7)

func test_missing_wrong_and_duplicate_resource_id_types_reject() -> void:
	assert_false(DataValidator.validate_recipe_catalog([],[],[]).is_empty())
	assert_false(DataValidator.validate_recipe_catalog([null],[machine],[input,output]).is_empty())
	assert_false(DataValidator.validate_recipe_catalog([input],[machine],[input,output]).is_empty())
	assert_string_contains("\n".join(DataValidator.validate_recipe_catalog([recipe,recipe],[machine],[input,output])),"duplicate recipe")
	assert_string_contains("\n".join(DataValidator.validate_recipe_catalog([recipe],[machine,machine],[input,output])),"duplicate machine")
	assert_string_contains("\n".join(DataValidator.validate_recipe_catalog([recipe],[machine],[input,input,output])),"duplicate item")

func test_ids_must_be_nonempty_ascii_snake_case() -> void:
	for id: StringName in [&"",&"BadId",&"bad-id",&"bad id",&"bad__id",&"bad_",&"1bad",&"cà_rốt"]:
		recipe.recipe_id = id
		assert_false(_errors().is_empty(),String(id))

func test_quantities_require_positive_bounded_ints_and_real_ids() -> void:
	for quantity: Variant in [null,true,"1",1.0,0,-1,2147483648]:
		recipe.inputs[0]["quantity"] = quantity
		assert_string_contains("\n".join(_errors()),"integer quantity")
	recipe.inputs[0]["quantity"] = 2
	for id: Variant in [null,17,&"absent_input",&"BAD"]:
		recipe.inputs[0]["item_id"] = id
		assert_false(_errors().is_empty())
	recipe.inputs[0]["item_id"] = input.item_id
	recipe.outputs[0]["quantity"] = 0
	assert_string_contains("\n".join(_errors()),"outputs")

func test_empty_duplicate_entries_and_unsupported_output_multiplicity() -> void:
	recipe.inputs = []
	assert_string_contains("\n".join(_errors()),"must not be empty")
	recipe.inputs = [{"item_id":input.item_id,"quantity":1},{"item_id":input.item_id,"quantity":1}]
	assert_string_contains("\n".join(_errors()),"duplicate item")
	recipe.inputs.resize(1)
	recipe.outputs.append({"item_id":input.item_id,"quantity":1})
	assert_string_contains("\n".join(_errors()),"exactly one runtime output")
	recipe.outputs = []
	assert_false(_errors().is_empty())

func test_machine_and_recipe_links_must_resolve_both_directions() -> void:
	recipe.machine_ids = PackedStringArray(["unknown_machine"])
	assert_string_contains("\n".join(_errors()),"unknown machine")
	recipe.machine_ids = PackedStringArray(["fixture_mill","fixture_mill"])
	assert_string_contains("\n".join(_errors()),"duplicate machine")
	recipe.machine_ids = PackedStringArray(["fixture_mill"])
	machine.recipe_ids = PackedStringArray(["unknown_recipe"])
	assert_string_contains("\n".join(_errors()),"reciprocal")
	assert_string_contains("\n".join(_errors()),"unknown recipe")
	machine.recipe_ids = PackedStringArray(["fixture_recipe","fixture_recipe"])
	assert_string_contains("\n".join(_errors()),"duplicate recipe")
	machine.recipe_ids = PackedStringArray(["fixture_recipe"])
	recipe.machine_ids = PackedStringArray()
	assert_string_contains("\n".join(_errors()),"reciprocal")

func test_slot_duration_unlock_stack_and_price_validation() -> void:
	for days: int in [0,-1,2147483648]:
		recipe.duration_days = days
		assert_string_contains("\n".join(_errors()),"duration/unlock")
	recipe.duration_days = 1
	recipe.unlock_house_level = 0
	assert_string_contains("\n".join(_errors()),"duration/unlock")
	recipe.unlock_house_level = 1
	machine.input_slots = 0
	assert_string_contains("\n".join(_errors()),"slot")
	machine.input_slots = 1
	machine.output_slots = 0
	assert_false(_errors().is_empty())
	machine.output_slots = 1
	input.sell_price = -1
	assert_string_contains("\n".join(_errors()),"price")
	input.sell_price = 10
	input.max_stack = 0
	assert_false(_errors().is_empty())

func _snapshot(recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> String:
	var rows: Array = []
	for value: Resource in recipes:
		rows.append([value.recipe_id,value.inputs.duplicate(true),value.outputs.duplicate(true),value.duration_days,value.unlock_house_level,value.machine_ids])
	for value: Resource in machines:
		rows.append([value.machine_id,value.recipe_ids,value.input_slots,value.output_slots,value.unlock_house_level])
	for value: Resource in items:
		rows.append([value.item_id,value.buy_price,value.sell_price,value.max_stack])
	return var_to_str(rows)

func test_distinct_valid_inputs_still_need_actual_machine_slot_capacity() -> void:
	var second: ItemData = ItemData.new()
	second.item_id = &"fixture_second"
	recipe.inputs.append({"item_id":second.item_id,"quantity":1})
	assert_string_contains("\n".join(DataValidator.validate_recipe_catalog([recipe],[machine],[input,output,second])),"exceeds machine slot capacity")
	machine.input_slots = 2
	assert_eq(DataValidator.validate_recipe_catalog([recipe],[machine],[input,output,second]),PackedStringArray())
