## WeatherHud — localized current weather and next-day forecast.
extends Label

var _weather: Object

func configure(weather: Object) -> void:
	_weather = weather
	if not Events.weather_changed.is_connected(_refresh):
		Events.weather_changed.connect(_refresh)
	if not Events.forecast_updated.is_connected(_on_forecast_updated):
		Events.forecast_updated.connect(_on_forecast_updated)
	_refresh(StringName(_weather.get("today")))

func _refresh(_weather_id: StringName) -> void:
	if _weather == null:
		return
	var forecast: Array = _weather.get("forecast")
	var today: StringName = StringName(_weather.get("today"))
	var forecast_name: String = String(forecast[0]) if not forecast.is_empty() else ""
	text = tr("UI_WEATHER_CURRENT") % [_weather_name(today), _weather_name(StringName(forecast_name))]

func _on_forecast_updated(_forecast: Array[StringName]) -> void:
	_refresh(_weather.today)

func _weather_name(weather_id: StringName) -> String:
	return tr("WEATHER_" + String(weather_id).to_upper())
