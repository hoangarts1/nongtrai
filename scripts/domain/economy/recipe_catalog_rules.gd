## RecipeCatalogRules — pure catalog/reference/runtime-shape validation.
## API:
##   static func validate(recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray
class_name RecipeCatalogRules
extends RefCounted
const MAX_RULE_INTEGER: int = RecipeEconomyConfig.MAX_RULE_INTEGER

static func validate(recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
	var errors: Array[String] = []
	var item_map: Dictionary = _index(items,&"item",errors)
	var machine_map: Dictionary = _index(machines,&"machine",errors)
	var recipe_map: Dictionary = _index(recipes,&"recipe",errors)
	if recipes.is_empty() or machines.is_empty() or items.is_empty():
		errors.append("recipe catalog requires nonempty recipes/machines/items")
	for value: Variant in item_map.values():
		var item: ItemData = value as ItemData
		if item.max_stack<=0 or item.max_stack>MAX_RULE_INTEGER or item.sell_price<0 or item.sell_price>MAX_RULE_INTEGER or item.buy_price<0 or item.buy_price>MAX_RULE_INTEGER:
			errors.append("recipe item %s has invalid stack/price" % item.item_id)
	for value: Variant in recipe_map.values():
		var recipe: RecipeData = value as RecipeData
		var context: String = "recipe %s" % recipe.recipe_id
		if recipe.duration_days<=0 or recipe.duration_days>MAX_RULE_INTEGER or recipe.unlock_house_level<=0 or recipe.unlock_house_level>MAX_RULE_INTEGER:
			errors.append(context+" has invalid duration/unlock tier")
		_entries(recipe.inputs,item_map,context+" inputs",errors)
		_entries(recipe.outputs,item_map,context+" outputs",errors)
		if recipe.outputs.size()!=1:
			errors.append(context+" requires exactly one runtime output")
		if recipe.machine_ids.is_empty():
			errors.append(context+" has no machines")
		var seen: Dictionary = {}
		for machine_id: String in recipe.machine_ids:
			if seen.has(machine_id):
				errors.append(context+" has duplicate machine "+machine_id)
			seen[machine_id] = true
			var machine: MachineData = machine_map.get(StringName(machine_id)) as MachineData
			if machine==null:
				errors.append(context+" references unknown machine "+machine_id)
			elif not machine.accepts_recipe(recipe.recipe_id):
				errors.append(context+" missing reciprocal machine recipe link")
			elif recipe.inputs.size()>machine.input_slots or recipe.outputs.size()>machine.output_slots:
				errors.append(context+" exceeds machine slot capacity")
	for value: Variant in machine_map.values():
		var machine: MachineData = value as MachineData
		var context: String = "machine %s" % machine.machine_id
		if machine.input_slots<=0 or machine.input_slots>MAX_RULE_INTEGER or machine.output_slots<=0 or machine.output_slots>MAX_RULE_INTEGER or machine.unlock_house_level<0 or machine.unlock_house_level>MAX_RULE_INTEGER or machine.recipe_ids.is_empty():
			errors.append(context+" has invalid slots/unlock/recipes")
		var seen: Dictionary = {}
		for recipe_id: String in machine.recipe_ids:
			if seen.has(recipe_id):
				errors.append(context+" has duplicate recipe "+recipe_id)
			seen[recipe_id] = true
			var recipe: RecipeData = recipe_map.get(StringName(recipe_id)) as RecipeData
			if recipe==null:
				errors.append(context+" references unknown recipe "+recipe_id)
			elif not recipe.has_machine(machine.machine_id):
				errors.append(context+" missing reciprocal recipe machine link")
	return PackedStringArray(errors)

static func _index(resources: Array[Resource], kind: StringName, errors: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for resource: Resource in resources:
		if not ((kind==&"item" and resource is ItemData) or (kind==&"machine" and resource is MachineData) or (kind==&"recipe" and resource is RecipeData)):
			errors.append("recipe catalog missing/wrong %s Resource" % kind)
			continue
		var id: StringName = StringName(resource.get(String(kind)+"_id"))
		if not valid_id(id):
			errors.append("recipe catalog invalid snake_case %s id: %s" % [kind,id])
		elif result.has(id):
			errors.append("recipe catalog duplicate %s id: %s" % [kind,id])
		else:
			result[id] = resource
	return result

static func valid_id(value: Variant) -> bool:
	if not value is String and not value is StringName:
		return false
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(String(value))!=null

static func _entries(entries: Array[Dictionary], items: Dictionary, context: String, errors: Array[String]) -> void:
	if entries.is_empty():
		errors.append(context+" must not be empty")
	var seen: Dictionary = {}
	for row: Dictionary in entries:
		var raw_id: Variant = row.get("item_id")
		if not valid_id(raw_id):
			errors.append(context+" has invalid item id")
			continue
		var id: StringName = StringName(raw_id)
		if not items.has(id):
			errors.append(context+" references unknown item "+String(id))
		if seen.has(id):
			errors.append(context+" has duplicate item "+String(id))
		seen[id] = true
		var quantity: Variant = row.get("quantity")
		if not quantity is int or quantity<=0 or quantity>MAX_RULE_INTEGER:
			errors.append(context+" requires positive bounded integer quantity")
