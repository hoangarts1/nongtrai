## Standalone recipe gate; fixtures clone data in memory and may only cause failure.
extends SceneTree
const CONFIG: RecipeEconomyConfig = preload("res://data/recipe_economy_config.tres")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var registry: Node = root.get_node_or_null("DataRegistry")
	if registry==null:
		print("[recipe_economy] FAIL: registry unavailable")
		quit(1)
		return
	var items: Array[Resource] = registry.call("get_all_items")
	var machines: Array[Resource] = registry.call("get_all_machines")
	var recipes: Array[Resource] = registry.call("get_all_recipes")
	var fixture: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--fixture="):
			fixture = argument.trim_prefix("--fixture=")
		else:
			print("[recipe_economy] FAIL: unknown argument")
			quit(2)
			return
	var original_errors: PackedStringArray = DataValidator.validate_recipe_economy(CONFIG,recipes,machines,items)
	if not original_errors.is_empty():
		for message: String in original_errors:
			print("[recipe_economy] FAIL: "+message)
		quit(1)
		return
	if not fixture.is_empty():
		if not fixture in ["over-cap","invalid-reference"]:
			print("[recipe_economy] FAIL: unknown fixture")
			quit(2)
			return
		items = _clones(items)
		machines = _clones(machines)
		recipes = _clones(recipes)
		if not _inject(fixture,recipes,items):
			print("[recipe_economy] FAIL: fixture could not be constructed")
			quit(2)
			return
	var errors: PackedStringArray = DataValidator.validate_recipe_economy(CONFIG,recipes,machines,items)
	if not errors.is_empty():
		for message: String in errors:
			print("[recipe_economy] FAIL: "+message)
		quit(1)
		return
	var unpriced: int = 0
	for resource: Resource in recipes:
		var recipe: RecipeData = resource as RecipeData
		for entry: Dictionary in recipe.outputs:
			if _item(items,StringName(entry.item_id)).sell_price==0:
				unpriced += 1
	print("[recipe_economy] PASS: recipes=%d machines=%d zero_sale_outputs=%d (not priced for sale)" % [recipes.size(),machines.size(),unpriced])
	quit(0)

func _clones(resources: Array[Resource]) -> Array[Resource]:
	var result: Array[Resource] = []
	for resource: Resource in resources:
		result.append(resource.duplicate(true))
	return result

func _item(items: Array[Resource], id: StringName) -> ItemData:
	for resource: Resource in items:
		var item: ItemData = resource as ItemData
		if item!=null and item.item_id==id:
			return item
	return null

func _inject(fixture: String, recipes: Array[Resource], items: Array[Resource]) -> bool:
	if recipes.is_empty():
		return false
	var recipe: RecipeData = recipes[0] as RecipeData
	if fixture=="invalid-reference":
		recipe.inputs[0]["item_id"] = &"missing_recipe_input"
		return true
	var cost: int = 0
	for entry: Dictionary in recipe.inputs:
		cost += _item(items,StringName(entry.item_id)).sell_price*int(entry.quantity)
	var cap: int = int(CONFIG.max_value_added_per_game_hour_by_unlock_level[recipe.unlock_house_level])
	var output: ItemData = _item(items,StringName(recipe.outputs[0].item_id))
	recipe.outputs[0]["quantity"] = 1
	var ceiling: int = RecipeEconomyRules.multiply(cap,RecipeEconomyRules.multiply(recipe.duration_days,CONFIG.game_hours_per_day))
	if ceiling<0 or ceiling>=RecipeEconomyConfig.MAX_RULE_INTEGER or cost>=RecipeEconomyConfig.MAX_RULE_INTEGER-ceiling:
		return false
	output.sell_price = cost+ceiling+1
	return true
