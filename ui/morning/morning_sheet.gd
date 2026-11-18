## LifeMorningSheet — reference05 paper bulletin with fixed native dismissal.
class_name LifeMorningSheet
extends LifeHudFrame

signal dismissed()
var title: Label
var date: Label
var weather: LifeMorningWeather
var garden: LifeMorningGarden
var market: LifeMorningMarket
var tasks: LifeMorningTasks
var ecology: LifeMorningEcologyStrip
var begin_button: Button

func _ready() -> void:
	super._ready()
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	date = LifeTitleParts.label(column,&"",&"LifeSecondaryText")
	date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title = LifeTitleParts.label(column,&"NEWS_TITLE",&"LifeDayTitle")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var rule: HSeparator = HSeparator.new()
	rule.modulate = get_theme_color(&"ink",&"LifeTokens")
	column.add_child(rule)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.theme_type_variation = &"LifeDayColumns"
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(columns)
	weather = preload("res://ui/morning/weather_column.tscn").instantiate() as LifeMorningWeather
	weather.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(weather)
	garden = preload("res://ui/morning/garden_column.tscn").instantiate() as LifeMorningGarden
	garden.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(garden)
	market = preload("res://ui/morning/market_column.tscn").instantiate() as LifeMorningMarket
	market.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(market)
	ecology = preload("res://ui/morning/ecology_strip.tscn").instantiate() as LifeMorningEcologyStrip
	column.add_child(ecology)
	tasks = preload("res://ui/morning/task_strip.tscn").instantiate() as LifeMorningTasks
	column.add_child(tasks)
	var center: CenterContainer = CenterContainer.new()
	column.add_child(center)
	begin_button = LifeTitleParts.button(center,&"NEWS_BEGIN",&"LifePrimary")
	begin_button.custom_minimum_size = Vector2(384,52)
	begin_button.pressed.connect(func() -> void: dismissed.emit())

func _draw() -> void:
	super._draw()
	var ink: Color = get_theme_color(&"ink",&"LifeTokens")
	draw_circle(Vector2(size.x*0.5,10),7,ink,true,-1,true)
	draw_circle(Vector2(size.x*0.5,9),5,get_theme_color(&"red",&"LifeTokens"),true,-1,true)
