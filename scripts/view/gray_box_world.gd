## GrayBoxWorld — minimal 3D test world for the MVP.
## API:
##   func pick_cell(screen_position: Vector2) -> Variant
##   static func is_player_near_interactable(player_position: Vector3, interactable_position: Vector3, reach: float) -> bool
class_name GrayBoxWorld
extends Node3D

const BED_INTERACTION_REACH: float = 2.5

@onready var camera: Camera3D = %Camera
@onready var player: Player = $Player
@onready var camera_rig: CameraRig = %CameraRig
@onready var bed_marker: Marker3D = %BedMarker
@onready var interaction_prompt: InteractionPrompt = $InteractionLayer/InteractionPrompt
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon
@onready var house_light: OmniLight3D = $House/HouseLight
var _day_night_profile: Resource = preload("res://data/day_night_profile.tres")

func _ready() -> void:
	camera.rotation_degrees = Vector3(-35.0, 45.0, 0.0)
	player.camera = camera
	camera_rig.set_target(player)
	GameClock.sleep_started.connect(_on_sleep_started)
	GameClock.sleep_finished.connect(_on_sleep_finished)
	GameClock.time_changed.connect(_on_time_changed)
	_update_bed_prompt()
	_apply_day_night(GameClock.minute)

func _process(_delta: float) -> void:
	_update_bed_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if GameClock.is_sleeping():
		return
	if not GameClock.can_sleep():
		return
	if not is_player_near_interactable(player.global_position, bed_marker.global_position, BED_INTERACTION_REACH):
		return
	if GameClock.try_sleep():
		_on_sleep_started()

func _update_bed_prompt() -> void:
	if GameClock.is_sleeping():
		interaction_prompt.show_prompt("Đang ngủ...")
		return
	if not is_player_near_interactable(player.global_position, bed_marker.global_position, BED_INTERACTION_REACH):
		interaction_prompt.hide_prompt()
	elif GameClock.can_sleep():
		interaction_prompt.show_prompt("[E] Ngủ")
	else:
		interaction_prompt.hide_prompt()

func _on_sleep_started() -> void:
	player.movement_enabled = false
	interaction_prompt.show_prompt("Đang ngủ...")

func _on_sleep_finished(_day_index: int) -> void:
	player.movement_enabled = true
	_update_bed_prompt()

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
	world_environment.environment.ambient_light_energy = float(lighting["ambient_energy"])
	world_environment.environment.background_color = lighting["sky_color"] as Color
	house_light.visible = minute >= 1080 or minute < 360
	house_light.light_energy = 0.65 if house_light.visible else 0.0

func get_day_night_lighting(minute: int) -> Dictionary:
	return _day_night_profile.call("sample", minute)

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
