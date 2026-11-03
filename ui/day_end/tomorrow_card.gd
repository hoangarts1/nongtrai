## LifeDayTomorrowCard — real forecast and tutorial completion supplied by presenter.
class_name LifeDayTomorrowCard
extends VBoxContainer

var date: Label
var weather: Label
var tip: Label
var quests: Label
var symbol: LifeDayWeatherSymbol

func _ready() -> void:
	LifeTheme.bind(self,&"LifeDayColumn")
	date = LifeDayEndParts.wrapped(self,&"LifeDayHeading")
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"LifeDayForecast"
	add_child(panel)
	var column: VBoxContainer = LifeHudParts.column(panel)
	symbol = LifeDayWeatherSymbol.new()
	column.add_child(symbol)
	weather = LifeDayEndParts.wrapped(column,&"LifeDayWeather")
	tip = LifeDayEndParts.wrapped(column)
	quests = LifeDayEndParts.wrapped(self)

func display(next_date: String, forecast: String, weather_id: StringName, completed: int, total: int) -> void:
	date.text = next_date
	weather.text = forecast
	symbol.display(weather_id)
	tip.text = tr("END_RAIN_TIP" if weather_id in [&"rain",&"storm"] else "END_TOMORROW_TIP")
	quests.text = tr("END_QUEST_PROGRESS") % [completed,total]
