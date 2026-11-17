## DataRegistry — runtime item and crop data lookup.
## API:
##   func get_all_machines() -> Array[Resource]
##   func get_all_recipes() -> Array[Resource]
extends Node

var _items: Dictionary = {}
var _crops: Dictionary = {}
var _tools: Dictionary = {}
var _seasons: Dictionary = {}
var _quests: Dictionary = {}
var _machines: Dictionary = {}
var _recipes: Dictionary = {}

func _ready() -> void:
	for quest_data: Resource in [
		preload("res://data/quests/quest_turnip_delivery.tres")
	]:
		_quests[quest_data.get("quest_id")] = quest_data
	for item_data: Resource in [
		preload("res://data/items/chicken_feed.tres"),
		preload("res://data/items/egg.tres"),
		preload("res://data/items/temp_carrot_meal.tres"),
		preload("res://data/items/temp_wheat_flour.tres"),
		preload("res://data/items/temp_roasted_coffee.tres"),
		preload("res://data/items/temp_corn_bread.tres"),
		preload("res://data/items/temp_dried_chili.tres"),
		preload("res://data/items/temp_pickled_cabbage.tres"),
		preload("res://data/items/temp_orange_juice.tres"),
		preload("res://data/items/turnip_seed.tres"),
		preload("res://data/items/turnip.tres"),
		preload("res://data/items/spring_carrot_seed.tres"),
		preload("res://data/items/spring_carrot.tres"),
		preload("res://data/items/spring_pea_seed.tres"),
		preload("res://data/items/spring_pea.tres"),
		preload("res://data/items/summer_tomato_seed.tres"),
		preload("res://data/items/summer_tomato.tres"),
		preload("res://data/items/summer_corn_seed.tres"),
		preload("res://data/items/summer_corn.tres"),
		preload("res://data/items/autumn_wheat_seed.tres"),
		preload("res://data/items/autumn_wheat.tres"),
		preload("res://data/items/autumn_pumpkin_seed.tres"),
		preload("res://data/items/autumn_pumpkin.tres"),
		preload("res://data/items/winter_radish_seed.tres"),
		preload("res://data/items/winter_radish.tres"),
		preload("res://data/items/winter_cabbage_seed.tres"),
		preload("res://data/items/winter_cabbage.tres")
	]:
		_items[item_data.get("item_id")] = item_data
	for crop_data: Resource in [
		preload("res://data/crops/turnip.tres"),
		preload("res://data/crops/spring_carrot.tres"),
		preload("res://data/crops/spring_pea.tres"),
		preload("res://data/crops/summer_tomato.tres"),
		preload("res://data/crops/summer_corn.tres"),
		preload("res://data/crops/autumn_pumpkin.tres"),
		preload("res://data/crops/autumn_wheat.tres"),
		preload("res://data/crops/winter_cabbage.tres"),
		preload("res://data/crops/winter_radish.tres")
	]:
		_crops[crop_data.get("crop_id")] = crop_data
	var supplied_catalog: Resource = preload("res://data/crops/supplied_crop_catalog.tres") as Resource
	for crop_value: Variant in supplied_catalog.get("crops"):
		var crop_data: CropData = crop_value as CropData
		if crop_data == null:
			continue
		_crops[crop_data.crop_id] = crop_data
		_register_supplied_items(crop_data)
	for tool_data: Resource in [
		preload("res://data/tools/hoe.tres"),
		preload("res://data/tools/shovel.tres"),
		preload("res://data/tools/watering_can.tres")
	]:
		_tools[tool_data.get("tool_id")] = tool_data
	for machine_data: Resource in [
		preload("res://data/machines/stove.tres"),
		preload("res://data/machines/mill.tres"),
		preload("res://data/machines/press.tres"),
		preload("res://data/machines/barrel.tres"),
		preload("res://data/machines/oven.tres"),
		preload("res://data/machines/dryer.tres"),
		preload("res://data/machines/roaster.tres")
	]:
		_machines[machine_data.get("machine_id")] = machine_data
	for recipe_data: Resource in [
		preload("res://data/recipes/stove_carrot_meal.tres"),
		preload("res://data/recipes/mill_wheat_flour.tres"),
		preload("res://data/recipes/press_orange_juice.tres"),
		preload("res://data/recipes/barrel_pickled_cabbage.tres"),
		preload("res://data/recipes/oven_corn_bread.tres"),
		preload("res://data/recipes/dryer_dried_chili.tres"),
		preload("res://data/recipes/roaster_coffee.tres")
	]:
		_recipes[recipe_data.get("recipe_id")] = recipe_data
	for season_data: Resource in [
		preload("res://data/seasons/spring.tres"),
		preload("res://data/seasons/summer.tres"),
		preload("res://data/seasons/autumn.tres"),
		preload("res://data/seasons/winter.tres")
	]:
		_seasons[season_data.get("season_id")] = season_data

func get_item(item_id: StringName) -> Resource:
	return _items.get(item_id) as Resource

func get_crop(crop_id: StringName) -> Resource:
	return _crops.get(crop_id) as Resource

func get_crop_for_seed(seed_item_id: StringName) -> Resource:
	for crop_data: Resource in _crops.values():
		if crop_data != null and crop_data.get("seed_item") == seed_item_id:
			return crop_data
	return null

func get_all_items() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(_items.values())
	return result

func get_all_crops() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(_crops.values())
	return result

func get_seed_items() -> Array[Resource]:
	var result: Array[Resource] = []
	for crop_data: Resource in _crops.values():
		if crop_data == null:
			continue
		var seed_id: StringName = crop_data.get("seed_item")
		var item: Resource = get_item(seed_id)
		if item != null and not result.has(item):
			result.append(item)
	return result

func _register_supplied_items(crop_data: CropData) -> void:
	var planting_item: ItemData = ItemData.new()
	planting_item.item_id = crop_data.seed_item
	planting_item.display_name_key = StringName("ITEM_%s" % String(crop_data.seed_item).to_upper())
	planting_item.category = &"seed"
	planting_item.description_key = &"INV_DESC_SEED"
	planting_item.max_stack = 99
	planting_item.buy_price = crop_data.planting_item_buy_price
	planting_item.sell_price = maxi(1, crop_data.planting_item_buy_price / 2)
	planting_item.icon_path = "res://assets/crops/%s/%s_seed.png" % [crop_data.crop_id, crop_data.crop_id]
	_items[planting_item.item_id] = planting_item
	var produce: ItemData = ItemData.new()
	produce.item_id = crop_data.product_item
	produce.display_name_key = crop_data.display_name_key
	produce.category = &"produce"
	produce.max_stack = 99
	produce.sell_price = crop_data.produce_sell_price
	produce.icon_path = ""
	_items[produce.item_id] = produce

func get_tool(tool_id: StringName) -> Resource:
	return _tools.get(tool_id) as Resource

func get_machine(machine_id: StringName) -> MachineData:
	return _machines.get(machine_id) as MachineData

func get_recipe(recipe_id: StringName) -> RecipeData:
	return _recipes.get(recipe_id) as RecipeData

func get_recipes_for_machine(machine_id: StringName) -> Array[Resource]:
	var result: Array[Resource] = []
	for recipe: Resource in _recipes.values():
		if recipe != null and recipe.has_machine(machine_id):
			result.append(recipe)
	return result

func get_season(season_id: StringName) -> Resource:
	return _seasons.get(season_id) as Resource

func get_starter_seed_for_season(season_id: StringName) -> StringName:
	var s_data: Resource = get_season(season_id)
	if s_data != null:
		var seed_id: Variant = s_data.get("starter_seed")
		if seed_id != null and not StringName(seed_id).is_empty():
			var crop: Resource = get_crop_for_seed(StringName(seed_id))
			if crop != null:
				var seasons: PackedStringArray = crop.get("seasons")
				if seasons.is_empty() or seasons.has(String(season_id)):
					return StringName(seed_id)
	for crop: Resource in get_all_crops():
		if crop == null:
			continue
		var seasons: PackedStringArray = crop.get("seasons")
		if seasons.is_empty() or seasons.has(String(season_id)):
			return StringName(crop.get("seed_item"))
	return &"turnip_seed"

func get_quest(quest_id: StringName) -> Resource:
	return _quests.get(quest_id) as Resource

func get_all_quests() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(_quests.values())
	return result

func get_all_machines() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(_machines.values())
	return result

func get_all_recipes() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(_recipes.values())
	return result
