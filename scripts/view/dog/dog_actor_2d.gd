## DogActor2D - grid-ground visual interpolation; never writes DogState.
## API: configure(state,grid,config,profile), begin_step(cell), advance(delta,playing), reset_position().
class_name DogActor2D
extends Node2D
signal arrived(cell: Vector2i)
var avatar: DogAvatar2D
var caption: Label
var _owner: DogState
var _grid: IsometricGrid
var _config: DogConfig
var _target: Vector2i
var _moving: bool = false
var _default_caption: String = ""

func configure(state: DogState, grid: IsometricGrid, config: DogConfig, profile: DogVisualProfile) -> bool:
	if state == null or state.serialize().is_empty() or grid == null or config == null or not config.validation_errors().is_empty() or profile == null or not profile.validation_errors().is_empty(): return false
	if _owner != null and _owner.changed.is_connected(_changed): _owner.changed.disconnect(_changed)
	_owner = state
	_grid = grid
	_config = config.frozen_copy()
	if avatar == null:
		avatar = DogAvatar2D.new()
		avatar.name = "Avatar"
		add_child(avatar)
		caption = Label.new()
		caption.name = "Name"
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(caption)
	avatar.configure(profile)
	caption.position = profile.name_offset
	caption.size = profile.name_size
	_owner.changed.connect(_changed)
	set_process(false)
	reset_position()
	_changed(_owner.get_cell(), _owner.get_name())
	return true

func set_unnamed_caption(text: String) -> void:
	_default_caption = text
	if _owner != null: _changed(_owner.get_cell(), _owner.get_name())

func _changed(_cell: Vector2i, dog_name: String) -> void:
	caption.text = dog_name if not dog_name.is_empty() else _default_caption
	caption.visible = not caption.text.is_empty()

func reset_position() -> void:
	if _owner == null: return
	_moving = false
	_target = _owner.get_cell()
	global_position = _grid.cell_to_global(_target)
	avatar.set_motion(false)

func begin_step(cell: Vector2i) -> bool:
	if _owner == null or _moving or DogFollowRules.distance(_owner.get_cell(), cell) != 1: return false
	_target = cell
	_moving = true
	avatar.set_motion(true, _grid.cell_to_global(cell) - global_position)
	return true

func is_moving() -> bool: return _moving

func advance(delta: float, playing: bool = true) -> void:
	if _owner == null or not playing or not is_finite(delta) or delta <= 0.0: return
	avatar.advance(delta, playing)
	if not _moving: return
	var destination: Vector2 = _grid.cell_to_global(_target)
	var edge: float = _grid.cell_to_global(_owner.get_cell()).distance_to(destination)
	global_position = global_position.move_toward(destination, edge * _config.move_speed * delta)
	if global_position.is_equal_approx(destination):
		_moving = false
		avatar.set_motion(false)
		arrived.emit(_target)

func _exit_tree() -> void:
	if _owner != null and _owner.changed.is_connected(_changed): _owner.changed.disconnect(_changed)
