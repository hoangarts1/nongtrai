## DataRegistry — runtime item and crop data lookup.
extends Node

var _items: Dictionary = {}
var _crops: Dictionary = {}
var _tools: Dictionary = {}
var _seasons: Dictionary = {}

func _ready() -> void:
	for item_data: Resource in [
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
	for tool_data: Resource in [
		preload("res://data/tools/hoe.tres"),
		preload("res://data/tools/watering_can.tres")
	]:
		_tools[tool_data.get("tool_id")] = tool_data
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

func get_tool(tool_id: StringName) -> Resource:
	return _tools.get(tool_id) as Resource

func get_season(season_id: StringName) -> Resource:
	return _seasons.get(season_id) as Resource
