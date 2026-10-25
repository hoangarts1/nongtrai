## DataRegistry — runtime item and crop data lookup.
extends Node

var _items: Dictionary = {}
var _crops: Dictionary = {}

func _ready() -> void:
	for item_data: Resource in [
		preload("res://data/items/turnip_seed.tres"),
		preload("res://data/items/turnip.tres")
	]:
		_items[item_data.get("item_id")] = item_data
	for crop_data: Resource in [
		preload("res://data/crops/turnip.tres")
	]:
		_crops[crop_data.get("crop_id")] = crop_data

func get_item(item_id: StringName) -> Resource:
	return _items.get(item_id) as Resource

func get_crop(crop_id: StringName) -> Resource:
	return _crops.get(crop_id) as Resource
