## MachinePresentation — renders placed machines from the supplied manifest with work_a/work_b animation.
## API:
##   func configure(main: Node) -> void
##   func refresh() -> void
class_name MachinePresentation
extends Node

const MANIFEST_PATH: String = "res://assets/machines/machines_manifest.json"
var _main: Node
var _root: Node2D
var _manifest: Dictionary = {}
var _working_sprites: Array[Dictionary] = []
var _anim_timer: float = 0.0
var _use_frame_b: bool = false

func configure(main: Node) -> void:
	_main = main
	_root = Node2D.new()
	_root.name = "Machines"
	_root.y_sort_enabled = true
	_main.world.objects.add_child(_root)
	_load_manifest()
	refresh()

func _process(delta: float) -> void:
	# Status may change during a paused review: synchronize model before animation.
	var active: Array[Dictionary] = []
	for item: Dictionary in _working_sprites:
		var sprite: Sprite2D = item.get("sprite") as Sprite2D
		var state: MachineState = item.get("state") as MachineState
		if not is_instance_valid(sprite) or sprite.is_queued_for_deletion():
			continue
		if state==null or state.status!=MachineState.STATUS_WORKING:
			sprite.texture = item.get("tex_idle") as Texture2D
		else:
			active.append(item)
	_working_sprites = active
	if active.is_empty():
		_anim_timer = 0.0
		_use_frame_b = false
		set_process(false)
		return
	if GameClock.paused:
		return
	_anim_timer += delta
	if _anim_timer < 0.4:
		return
	_anim_timer = fmod(_anim_timer,0.4)
	_use_frame_b = not _use_frame_b
	for item: Dictionary in active:
		var sprite: Sprite2D = item.sprite
		sprite.texture = item.tex_b if _use_frame_b else item.tex_a

func refresh() -> void:
	if _root == null:
		return
	_working_sprites.clear()
	_anim_timer = 0.0
	_use_frame_b = false
	for child: Node in _root.get_children():
		child.queue_free()
	for placement: Dictionary in _main.machine_placements.get_all_placements():
		_add_machine(placement)
	set_process(not _working_sprites.is_empty())

func _add_machine(placement: Dictionary) -> void:
	var machine_id: StringName = placement["machine_id"]
	var cell: Vector2i = placement["cell"]
	var root: Node2D = Node2D.new()
	root.name = "Machine_%s_%d_%d" % [String(machine_id), cell.x, cell.y]
	root.set_meta("cell", cell)
	root.global_position = _main.world.cell_to_global(cell)
	_root.add_child(root)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(sprite)
	var state: MachineState = _main.machine_operations.get_state(cell)
	var working: bool = state != null and state.status == MachineState.STATUS_WORKING
	var entry: Dictionary = _manifest.get("machines", {}).get(String(machine_id), {})
	var files: Array = entry.get("files", [])
	var file_stem: String = String(files[1] if working else files[0]) if files.size() >= 2 else ""
	var visual: Dictionary = {
		"canvas": _manifest.get("canvas_2x", [128, 152]),
		"pivot": _manifest.get("pivot_2x", [64, 120])
	}
	if not file_stem.is_empty():
		var tex_a: Texture2D = load("res://assets/machines/%s/%s.png" % [String(machine_id), file_stem]) as Texture2D
		sprite.texture = tex_a
		if working and files.size() >= 3:
			var tex_b: Texture2D = load("res://assets/machines/%s/%s.png" % [String(machine_id), String(files[2])]) as Texture2D
			var idle: Texture2D = load("res://assets/machines/%s/%s.png" % [String(machine_id),String(files[0])]) as Texture2D
			_working_sprites.append({"sprite":sprite,"state":state,"tex_a":tex_a,"tex_b":tex_b,"tex_idle":idle})
	sprite.position = -Vector2(float(visual["pivot"][0]), float(visual["pivot"][1]))

func _load_manifest() -> void:
	var file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		push_warning("MachinePresentation: manifest unavailable; machines remain invisible.")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_manifest = parsed
