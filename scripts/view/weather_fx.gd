## WeatherFx — placeholder rain and storm presentation driven by WeatherState.
extends Node3D

var _rain: GPUParticles3D
var _weather: Object

func _ready() -> void:
	_rain = GPUParticles3D.new()
	_rain.name = "RainParticles"
	_rain.amount = 120
	_rain.lifetime = 0.8
	_rain.visibility_aabb = AABB(Vector3(-12.0, -1.0, -12.0), Vector3(24.0, 14.0, 24.0))
	var particle_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0.0, -1.0, 0.0)
	particle_material.initial_velocity_min = 8.0
	particle_material.initial_velocity_max = 12.0
	particle_material.gravity = Vector3.ZERO
	_rain.process_material = particle_material
	var drop: BoxMesh = BoxMesh.new()
	drop.size = Vector3(0.015, 0.35, 0.015)
	var drop_material: StandardMaterial3D = StandardMaterial3D.new()
	drop_material.albedo_color = Color(0.45, 0.65, 1.0, 0.7)
	drop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drop.material = drop_material
	_rain.draw_pass_1 = drop
	_rain.position = Vector3(6.0, 7.0, 6.0)
	_rain.visible = false
	add_child(_rain)

func configure(weather: Object) -> void:
	_weather = weather
	if not Events.weather_changed.is_connected(_on_weather_changed):
		Events.weather_changed.connect(_on_weather_changed)
	_on_weather_changed(StringName(_weather.get("today")))

func _on_weather_changed(weather_id: StringName) -> void:
	if _rain == null:
		return
	var rainy: bool = weather_id == &"rain" or weather_id == &"storm"
	_rain.visible = rainy
