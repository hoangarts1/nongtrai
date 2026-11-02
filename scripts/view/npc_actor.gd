## NpcActor — 2D route interpolation; logical cells remain in NpcSocialState.
class_name NpcActor
extends Node2D

var state: NpcSocialState
var data: NpcData
var name_label: Label
var avatar: PlaceholderAvatar2D
var grid: IsometricGrid

func configure(social: NpcSocialState, npc: NpcData) -> void:
	state = social
	data = npc
	reset_position()
	avatar = PlaceholderAvatar2D.new()
	avatar.name = "Avatar"
	add_child(avatar)
	var catalog: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
	var appearance: Resource = catalog.call("get_npc_appearance", data.npc_id)
	if appearance != null:
		avatar.configure_profile(appearance.call("to_builder_dictionary"))
	else:
		avatar.configure(data.color, data.is_merchant)
	name_label = Label.new()
	name_label.position = Vector2(-70,-70)
	name_label.size = Vector2(140,32)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.theme = preload("res://scenes/main/ui_theme.tres")
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = tr(String(data.display_name_key))
	add_child(name_label)

func _process(delta: float) -> void:
	if state == null or grid == null:
		return
	var path: Array = state.paths.get(data.npc_id, [])
	var motion: Vector2 = Vector2.ZERO
	if not path.is_empty() and not GameClock.paused:
		var target: Vector2 = grid.cell_to_global(path[0])
		var edge_length: float = grid.cell_to_global(Vector2i.RIGHT).distance_to(grid.cell_to_global(Vector2i.ZERO))
		var previous: Vector2 = global_position
		global_position = global_position.move_toward(target, data.move_speed * edge_length * delta)
		motion = global_position - previous
		if global_position.is_equal_approx(target):
			state.advance_step(data.npc_id)
	if avatar != null:
		avatar.set_motion(motion)
	visible = not state.is_indoors(data.npc_id)

func reset_position() -> void:
	if grid != null:
		global_position = grid.cell_to_global(state.cells[data.npc_id])
	visible = not state.is_indoors(data.npc_id)

func play_talk() -> void:
	if avatar != null:
		avatar.play_talk()

func show_emotion(emotion_id: StringName) -> bool:
	return avatar != null and avatar.show_emotion_bubble(emotion_id)
