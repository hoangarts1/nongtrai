## LifeHudClockCard — clock/weather readout; the presenter supplies every value.
class_name LifeHudClockCard
extends LifeHudFrame

var date_label: Label
var season_label: Label
var time_label: Label
var forecast_label: Label
var arc: LifeHudClockArc

func _ready() -> void:
	super._ready()
	var paper: PanelContainer = PanelContainer.new()
	paper.theme_type_variation = &"LifeHudPaper"
	add_child(paper)
	var column: VBoxContainer = LifeHudParts.column(paper)
	date_label = LifeHudParts.label(column,&"LifeHudHeading")
	season_label = LifeHudParts.label(column,&"LifeSmall")
	arc = preload("res://ui/hud/clock_arc.tscn").instantiate() as LifeHudClockArc
	column.add_child(arc)
	time_label = LifeHudParts.label(column,&"LifeHudTime")
	forecast_label = LifeHudParts.label(column,&"LifeHudNote")
	for label: Label in [date_label,season_label,time_label,forecast_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func display(day: int, day_in_season: int, year: int, season_text: String, minute: int, weather_id: StringName, forecast: String) -> void:
	if date_label == null:
		return
	date_label.text = tr("HUD_DATE") % [tr("HUD_WEEKDAY_%d" % posmod(day,7)),day_in_season]
	season_label.text = tr("HUD_SEASON_YEAR") % [season_text,year]
	time_label.text = GameClock.format_time(minute)
	forecast_label.text = forecast
	arc.display(minute,weather_id)
