## WeatherFx — 2D rain and bounded seasonal placeholders; reads existing weather/clock only.
extends Node2D

const CONFIG: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
const CATALOG: Resource = preload("res://data/art/world/chibi_world_catalog.tres")
var _weather: Object
var _rain: Node2D
var _seasonal: Node2D
var _phase: float = 0.0
var _mode: StringName = &""

func _ready() -> void:
	_rain = Node2D.new()
	_rain.name = "RainParticles"
	_rain.visible = false
	add_child(_rain)
	_seasonal = Node2D.new()
	_seasonal.name = "SeasonalEffects"
	add_child(_seasonal)

func configure(weather: Object) -> void:
	_weather = weather
	if not Events.weather_changed.is_connected(_on_weather_changed):
		Events.weather_changed.connect(_on_weather_changed)
	if not GameClock.season_changed.is_connected(_on_season_changed):
		GameClock.season_changed.connect(_on_season_changed)
	if not GameClock.time_changed.is_connected(_on_time_changed):
		GameClock.time_changed.connect(_on_time_changed)
	_refresh()

func _on_weather_changed(_weather_id: StringName) -> void:
	_refresh()

func _on_season_changed(_season: StringName) -> void:
	_refresh()

func _on_time_changed(_day: int, _minute: int) -> void:
	var night: bool = GameClock.minute >= 1080 or GameClock.minute < GameClock.MORNING_MINUTE
	var desired: StringName = StringName("%s_%s%s" % [GameClock.season, "night" if night else "day", "_rain" if _rain != null and _rain.visible else ""])
	if desired != _mode:
		_refresh()

func _refresh() -> void:
	if _weather == null or _rain == null:
		return
	_rain.visible = bool(_weather.call("is_rainy"))
	for child: Node in _seasonal.get_children():
		child.free()
	var night: bool = GameClock.minute >= 1080 or GameClock.minute < 360
	_mode = StringName("%s_%s%s" % [GameClock.season, "night" if night else "day", "_rain" if _rain.visible else ""])
	var effect_name: String = "EnvSpringPetals"
	match GameClock.season:
		&"summer": effect_name = "EnvFireflyAmbient" if night else "EnvButterflyAmbient"
		&"autumn": effect_name = "EnvAutumnLeaves"
		&"winter": effect_name = "EnvWinterSnow"
	var effect: Node2D = Node2D.new()
	effect.name = effect_name
	_seasonal.add_child(effect)
	if _rain.visible:
		var ripples: Node2D = Node2D.new()
		ripples.name = "RainRipples"
		_seasonal.add_child(ripples)
	queue_redraw()

func get_current_mode() -> StringName:
	return _mode

func get_active_effect_count() -> int:
	return _seasonal.get_child_count() if _seasonal != null else 0

func _process(delta: float) -> void:
	if not GameClock.paused:
		_phase += delta
	queue_redraw()

func _draw() -> void:
	if _rain == null:
		return
	var inverse: Transform2D = get_global_transform_with_canvas().affine_inverse()
	var area: Vector2 = get_viewport_rect().size
	if _rain.visible:
		for index: int in range(CONFIG.rain_amount):
			var point: Vector2 = Vector2(fposmod(float(index * 97) - _phase * 80, area.x), fposmod(float(index * 73) + _phase * 370, area.y))
			draw_line(inverse * point,inverse * (point + Vector2(-5,15)),Color(0.7,0.85,1,0.5),1)
	# Tiny deterministic marks are art placeholders, not animals or ecology state.
	var color: Color = CATALOG.call("get_season_effect_color", GameClock.season)
	for index: int in range(8):
		var point: Vector2 = Vector2(fposmod(float(index*131) + _phase*8,area.x),fposmod(float(index*53) + _phase*4,area.y))
		draw_circle(inverse * point, 1.5, Color(color,0.45))
