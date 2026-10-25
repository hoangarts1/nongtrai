## Player — camera-relative CharacterBody3D controller for the gray-box MVP.
## API:
##   static func camera_relative_direction(input: Vector2, camera_basis: Basis) -> Vector3
class_name Player
extends CharacterBody3D

@export var camera: Camera3D
@export var config: PlayerConfig
@export var map_min: Vector2 = Vector2(-10.5, -10.5)
@export var map_max: Vector2 = Vector2(10.5, 10.5)
var movement_enabled: bool = true

func _ready() -> void:
	if config == null:
		config = PlayerConfig.new()

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector3.ZERO
		return
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_basis: Basis = Basis.IDENTITY
	if camera != null:
		movement_basis = camera.global_transform.basis
	var direction: Vector3 = camera_relative_direction(input_vector, movement_basis)
	var speed: float = config.sprint_speed if Input.is_action_pressed("sprint") else config.walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	global_position.x = clampf(global_position.x, map_min.x, map_max.x)
	global_position.z = clampf(global_position.z, map_min.y, map_max.y)

static func camera_relative_direction(input_vector: Vector2, camera_basis: Basis) -> Vector3:
	if input_vector.length_squared() == 0.0:
		return Vector3.ZERO
	var forward: Vector3 = Vector3(-camera_basis.z.x, 0.0, -camera_basis.z.z).normalized()
	var right: Vector3 = Vector3(camera_basis.x.x, 0.0, camera_basis.x.z).normalized()
	return (right * input_vector.x + forward * -input_vector.y).normalized()
