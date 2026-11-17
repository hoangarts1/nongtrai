## RecipeEconomyRules — exact opportunity-value/hour ceiling, without pricing mutations.
## API:
##   static func validate(config: RecipeEconomyConfig, recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray
class_name RecipeEconomyRules
extends RefCounted
const MAX_INTEGER: int = 9223372036854775807

static func validate(config: RecipeEconomyConfig, recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
	if config==null:
		return PackedStringArray(["recipe economy config is missing"])
	var errors: PackedStringArray = config.validation_errors()
	errors.append_array(RecipeCatalogRules.validate(recipes,machines,items))
	if not errors.is_empty():
		return errors
	var by_id: Dictionary = {}
	for value: Resource in items:
		var item: ItemData = value as ItemData
		by_id[item.item_id] = item
	for value: Resource in recipes:
		var recipe: RecipeData = value as RecipeData
		var raw_cap: Variant = config.max_value_added_per_game_hour_by_unlock_level.get(recipe.unlock_house_level)
		if not raw_cap is int:
			errors.append("recipe %s has no configured cap for unlock tier %d" % [recipe.recipe_id,recipe.unlock_house_level])
			continue
		var cost: int = _value(recipe.inputs,by_id)
		var output: int = _value(recipe.outputs,by_id)
		var hours: int = multiply(recipe.duration_days,config.game_hours_per_day)
		var ceiling: int = multiply(int(raw_cap),hours) if hours>=0 else -1
		if cost<0 or output<0 or ceiling<0:
			errors.append("recipe %s arithmetic_overflow in value/ceiling" % recipe.recipe_id)
		elif output-cost>ceiling:
			errors.append("recipe %s exceeds value-added cap: net=%d maximum=%d tier=%d hours=%d" % [recipe.recipe_id,output-cost,ceiling,recipe.unlock_house_level,hours])
	return errors

static func _value(entries: Array[Dictionary], items: Dictionary) -> int:
	var total: int = 0
	for entry: Dictionary in entries:
		var item: ItemData = items[StringName(entry.item_id)] as ItemData
		var value: int = multiply(item.sell_price,int(entry.quantity))
		if value<0 or total>MAX_INTEGER-value:
			return -1
		total += value
	return total

static func multiply(left: int, right: int) -> int:
	if left<0 or right<0:
		return -1
	@warning_ignore("integer_division")
	if right>0 and left>MAX_INTEGER/right:
		return -1
	return left*right
