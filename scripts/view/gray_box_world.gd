## GrayBoxWorld — minimal 3D test world for the MVP.
## API:
##   func pick_cell(screen_position: Vector2) -> Variant
##   static func is_player_near_interactable(player_position: Vector3, interactable_position: Vector3, reach: float) -> bool
class_name GrayBoxWorld
extends Node3D

const BED_INTERACTION_REACH: float = 2.5
const SHIPPING_BIN_REACH: float = 2.5

signal shipping_bin_interacted()

@onready var camera: Camera3D = %Camera
@onready var player: Player = $Player
@onready var camera_rig: CameraRig = %CameraRig
@onready var bed_marker: Marker3D = %BedMarker
@onready var shipping_bin_marker: Marker3D = %ShippingBinMarker
@onready var interaction_prompt: InteractionPrompt = $InteractionLayer/InteractionPrompt
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon
@onready var house_light: OmniLight3D = $House/HouseLight
var _day_night_profile: Resource = preload("res://data/day_night_profile.tres")
var _weather_darkness: float = 0.0

func _ready() -> void:
	camera.rotation_degrees = Vector3(-35.0, 45.0, 0.0)
	player.camera = camera
	camera_rig.set_target(player)
	GameClock.sleep_started.connect(_on_sleep_started)
	GameClock.sleep_finished.connect(_on_sleep_finished)
	GameClock.time_changed.connect(_on_time_changed)
	Events.weather_changed.connect(_on_weather_changed)
	_update_interaction_prompt()
	_apply_day_night(GameClock.minute)

func _process(_delta: float) -> void:
	_update_interaction_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if GameClock.is_sleeping():
		return
	if shipping_bin_marker != null and is_player_near_interactable(player.global_position, shipping_bin_marker.global_position, SHIPPING_BIN_REACH):
		shipping_bin_interacted.emit()
		return
	if not GameClock.can_sleep():
		return
	if not is_player_near_interactable(player.global_position, bed_marker.global_position, BED_INTERACTION_REACH):
		return
	if GameClock.try_sleep():
		_on_sleep_started()

func _update_interaction_prompt() -> void:
	if GameClock.is_sleeping():
		interaction_prompt.show_prompt(tr("UI_SLEEP_PENDING"))
		return
	if shipping_bin_marker != null and is_player_near_interactable(player.global_position, shipping_bin_marker.global_position, SHIPPING_BIN_REACH):
		interaction_prompt.show_prompt(tr("UI_PROMPT_SELL"))
		return
	if is_player_near_interactable(player.global_position, bed_marker.global_position, BED_INTERACTION_REACH) and GameClock.can_sleep():
		interaction_prompt.show_prompt(tr("UI_SLEEP_HINT"))
		return
	interaction_prompt.hide_prompt()

func _on_sleep_started() -> void:
	player.movement_enabled = false
	interaction_prompt.show_prompt(tr("UI_SLEEP_PENDING"))

func _on_sleep_finished(_day_index: int) -> void:
	player.movement_enabled = true
	_update_interaction_prompt()

func _on_time_changed(_day_index: int, minute: int) -> void:
	_apply_day_night(minute)

func _apply_day_night(minute: int) -> void:
	var lighting: Dictionary = _day_night_profile.call("sample", minute)
	if lighting.is_empty():
		return
	sun.light_color = lighting["sun_color"] as Color
	sun.light_energy = float(lighting["sun_energy"])
	sun.rotation_degrees = Vector3(float(lighting["sun_angle"]), -30.0, 0.0)
	moon.light_energy = float(lighting["moon_energy"])
	world_environment.environment.ambient_light_color = lighting["ambient_color"] as Color
	world_environment.environment.ambient_light_energy = float(lighting["ambient_energy"]) * (1.0 - _weather_darkness)
	world_environment.environment.background_color = (lighting["sky_color"] as Color).lerp(
		Color(0.18, 0.20, 0.24, 1.0),
		_weather_darkness
	)
	house_light.visible = minute >= 1080 or minute < 360
	house_light.light_energy = 0.65 if house_light.visible else 0.0

func get_day_night_lighting(minute: int) -> Dictionary:
	return _day_night_profile.call("sample", minute)

func _on_weather_changed(weather_id: StringName) -> void:
	var profile: Resource = preload("res://data/weather_profile.tres")
	var entry: Dictionary = profile.call("get_entry", weather_id)
	_weather_darkness = float(entry.get("darkness", 0.0))
	_apply_day_night(GameClock.minute)
	if bool(entry.get("storm", false)):
		var flash_tween: Tween = create_tween()
		flash_tween.tween_property(world_environment.environment, "ambient_light_energy", 1.0, 0.05)
		flash_tween.tween_property(world_environment.environment, "ambient_light_energy", 0.25, 0.12)

static func is_player_near_interactable(
	player_position: Vector3,
	interactable_position: Vector3,
	reach: float
) -> bool:
	if reach < 0.0:
		return false
	var player_flat: Vector3 = Vector3(player_position.x, 0.0, player_position.z)
	var interactable_flat: Vector3 = Vector3(interactable_position.x, 0.0, interactable_position.z)
	return player_flat.distance_squared_to(interactable_flat) <= reach * reach

func pick_cell(screen_position: Vector2) -> Variant:
	var ray_origin: Vector3 = camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = camera.project_ray_normal(screen_position)
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(ray_origin, ray_direction)
	if hit == null:
		return null
	return GridMath.world_to_cell(hit as Vector3)
