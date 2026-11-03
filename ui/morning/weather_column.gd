## LifeMorningWeather — actual today/forecast, never rolls weather.
class_name LifeMorningWeather
extends VBoxContainer

var heading: Label
var today: Label
var tip: Label
var forecast_title: Label
var symbol: LifeDayWeatherSymbol
var forecast_row: HBoxContainer
var scroll: ScrollContainer

func _ready() -> void:
	heading = LifeTitleParts.label(self,&"NEWS_WEATHER",&"LifeDayHeading")
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	var content: VBoxContainer = LifeHudParts.column(scroll)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card: PanelContainer = PanelContainer.new()
	card.theme_type_variation = &"LifeDayForecast"
	content.add_child(card)
	var body: VBoxContainer = LifeHudParts.column(card)
	symbol = LifeDayWeatherSymbol.new()
	body.add_child(symbol)
	today = LifeTitleParts.label(body,&"",&"LifeDayTitle")
	today.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip = LifeTitleParts.label(body,&"")
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	forecast_title = LifeTitleParts.label(content,&"NEWS_FORECAST",&"LifeText16")
	forecast_row = HBoxContainer.new()
	content.add_child(forecast_row)

func display(weather: StringName, forecast: Array[StringName], day: int) -> void:
	heading.text = tr("NEWS_WEATHER")
	today.text = tr("WEATHER_"+String(weather).to_upper()) if not weather.is_empty() else tr("END_FORECAST_UNKNOWN")
	symbol.display(weather)
	tip.text = tr("NEWS_RAIN_TIP" if weather in [&"rain",&"storm"] else "NEWS_DRY_TIP")
	forecast_title.text = tr("NEWS_FORECAST") if not forecast.is_empty() else tr("END_FORECAST_UNKNOWN")
	for child: Node in forecast_row.get_children():
		forecast_row.remove_child(child)
		child.queue_free()
	for index: int in range(forecast.size()):
		var column: VBoxContainer = LifeHudParts.column(forecast_row)
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var icon: LifeDayWeatherSymbol = LifeDayWeatherSymbol.new()
		column.add_child(icon)
		icon.display(forecast[index])
		var label: Label = LifeTitleParts.label(column,&"",&"LifeText16")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = tr("HUD_WEEKDAY_%d" % posmod(day+index+1,7))
		column.tooltip_text = tr("WEATHER_"+String(forecast[index]).to_upper())
