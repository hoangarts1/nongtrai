## WeatherState — seeded current weather and saved forecasts.
## API:
##   func advance_day(day_index: int) -> void
##   func force_weather(weather_id: StringName) -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name WeatherState
extends RefCounted

signal weather_changed(weather_id: StringName)
signal forecast_updated(forecast: Array[StringName])

var world_seed: int = 0
var today: StringName = &"sunny"
var forecast: Array[StringName] = []
var _profile: Resource

func configure(profile: Resource, seed: int = 0) -> void:
	_profile = profile
	world_seed = seed
	if forecast.is_empty():
		forecast = _roll_forecast(1, 3)

func advance_day(day_index: int) -> void:
	if forecast.is_empty():
		forecast = _roll_forecast(day_index, 3)
	today = forecast.pop_front()
	var next: Array[StringName] = _roll_forecast(day_index + forecast.size() + 1, 1)
	forecast.append_array(next)
	weather_changed.emit(today)
	forecast_updated.emit(forecast)
	Events.weather_changed.emit(today)
	Events.forecast_updated.emit(forecast)

func force_weather(weather_id: StringName) -> void:
	if _profile == null or _profile.call("get_entry", weather_id).is_empty():
		return
	today = weather_id
	weather_changed.emit(today)
	Events.weather_changed.emit(today)

func is_rainy() -> bool:
	var entry: Dictionary = _profile.call("get_entry", today) if _profile != null else {}
	return bool(entry.get("rain", false))

func is_stormy() -> bool:
	var entry: Dictionary = _profile.call("get_entry", today) if _profile != null else {}
	return bool(entry.get("storm", false))

func get_entry() -> Dictionary:
	return _profile.call("get_entry", today) if _profile != null else {}

func serialize() -> Dictionary:
	return {
		"world_seed": world_seed,
		"today": String(today),
		"forecast": _string_array(forecast)
	}

func deserialize(data: Dictionary) -> void:
	world_seed = int(data.get("world_seed", 0))
	today = StringName(data.get("today", "sunny"))
	forecast.clear()
	for item: Variant in data.get("forecast", []):
		forecast.append(StringName(item))
	if _profile != null and forecast.is_empty():
		forecast = _roll_forecast(1, 3)
	weather_changed.emit(today)
	forecast_updated.emit(forecast)
	Events.weather_changed.emit(today)
	Events.forecast_updated.emit(forecast)

func _roll_forecast(start_day: int, count: int) -> Array[StringName]:
	var result: Array[StringName] = []
	if _profile == null:
		return result
	for offset: int in range(count):
		result.append(_roll_weather(start_day + offset))
	return result

func _roll_weather(day: int) -> StringName:
	var entries: Array[Dictionary] = _profile.get("entries")
	var total: int = 0
	for entry: Dictionary in entries:
		total += maxi(0, int(entry.get("probability", 0)))
	if total <= 0:
		return &"sunny"
	var value: int = posmod(world_seed * 1103515245 + day * 12345 + 6789, total)
	for entry: Dictionary in entries:
		value -= maxi(0, int(entry.get("probability", 0)))
		if value < 0:
			return StringName(entry.get("id", "sunny"))
	return &"sunny"

func _string_array(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value: StringName in values:
		result.append(String(value))
	return result
