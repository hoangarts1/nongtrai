## Player — screen-relative 2D movement; logical cells are resolved through the world's grid adapter.
## API:
##   static func screen_direction(input_vector: Vector2) -> Vector2
##   func get_cell() -> Vector2i
##   func move_to_cell(cell: Vector2i) -> void
class_name Player
extends CharacterBody2D

@export var camera: Camera2D
@export var config: PlayerConfig
@export var map_min: Vector2 = Vector2.ZERO
@export var map_max: Vector2 = Vector2.ZERO
var movement_enabled: bool = true
var grid: IsometricGrid

func _ready() -> void:
	if config == null:
		config = preload("res://data/player_2d_config.tres")
	if camera == null:
		camera = get_node_or_null("Camera") as Camera2D

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		return
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var speed: float = config.sprint_speed if Input.is_action_pressed("sprint") else config.walk_speed
	velocity = screen_direction(input_vector) * speed
	var previous: Vector2 = global_position
	move_and_slide()
	if grid != null:
		var cell: Vector2i = get_cell()
		if cell.x < map_min.x or cell.y < map_min.y or cell.x > map_max.x or cell.y > map_max.y:
			global_position = previous
	var visual: PlaceholderAvatar2D = get_node_or_null("Visual") as PlaceholderAvatar2D
	if visual != null:
		visual.set_motion(velocity)

static func screen_direction(input_vector: Vector2) -> Vector2:
	var direction: Vector2 = input_vector.limit_length(1.0)
	direction.y *= 0.5
	return direction

func get_cell() -> Vector2i:
	return grid.global_to_cell(global_position) if grid != null else Vector2i.ZERO

func move_to_cell(cell: Vector2i) -> void:
	if grid != null:
		global_position = grid.cell_to_global(cell)
		velocity = Vector2.ZERO
