## MorningSnapshot — read-only values from existing morning owners.
class_name MorningSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var result: Dictionary = {
		"day":GameClock.day_index,"day_in_season":GameClock.get_day_in_season(),
		"year":GameClock.year,"season":GameClock.season,"weather":main.weather_state.get("today"),
		"forecast":main.weather_state.get("forecast").duplicate(),
		"ready":0,"water":0,"empty":0,"withered":0,"completed":0,"total":main.quest_panel.STEP_KEYS.size()
	}
	for plot: Dictionary in main.farm_state.serialize().plots:
		var id: StringName = StringName(plot.get("crop_id",""))
		if id.is_empty():
			if bool(plot.get("tilled",false)):
				result.empty += 1
		elif bool(plot.get("withered",false)):
			result.withered += 1
		else:
			var cell: Vector2i = Vector2i(int(plot.cell_x),int(plot.cell_y))
			if main.farm_state.can_harvest(cell):
				result.ready += 1
			var crop: CropData = DataRegistry.get_crop(id) as CropData
			if crop != null and crop.water_need > 0 and not bool(plot.get("watered",false)):
				result.water += 1
	var quests: Array[StringName] = []
	for index: int in range(main.quest_panel.STEP_KEYS.size()):
		if main.quest_state.is_step_completed(index):
			result.completed += 1
		else:
			quests.append(main.quest_panel.STEP_KEYS[index])
	result.quests = quests
	var prices: Array[Dictionary] = []
	for item: Resource in DataRegistry.get_all_items():
		if StringName(item.get("category")) == &"produce" and int(item.get("sell_price")) > 0:
			prices.append({"id":StringName(item.get("item_id")),"name_key":StringName(item.get("display_name_key")),"price":int(item.get("sell_price"))})
	prices.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a.id)<String(b.id))
	result.prices = prices
	result.ecology = EcologySnapshot.capture(main)
	return result
