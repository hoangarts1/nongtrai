## GrayBoxWorld — minimal 3D test world for the MVP.
## API:
##   func pick_cell(screen_position: Vector2) -> Variant
extends Node3D

@onready var camera: Camera3D = %Camera
@onready var player: Player = $Player
@onready var camera_rig: CameraRig = %CameraRig

func _ready() -> void:
	camera.rotation_degrees = Vector3(-35.0, 45.0, 0.0)
	player.camera = camera
	camera_rig.set_target(player)

func pick_cell(screen_position: Vector2) -> Variant:
	var ray_origin: Vector3 = camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = camera.project_ray_normal(screen_position)
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(ray_origin, ray_direction)
	if hit == null:
		return null
	return GridMath.world_to_cell(hit as Vector3)
