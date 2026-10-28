## NpcActor — placeholder and route interpolation; logical cells live in NpcSocialState.
class_name NpcActor
extends Node3D

const CHARACTER_CATALOG_PATH: String = "res://data/art/characters/chibi_character_catalog.tres"

var state: NpcSocialState
var data: NpcData
var name_label: Label3D
var avatar: ChibiAvatar

func configure(social: NpcSocialState, npc: NpcData) -> void:
	state = social
	data = npc
	position = GridMath.cell_to_world(state.cells[data.npc_id])
	avatar = ChibiAvatar.new()
	avatar.name = "Avatar"
	add_child(avatar)
	var profile: Dictionary = _catalog_profile(data.npc_id)
	if profile.is_empty():
		avatar.configure(data.color, data.is_merchant)
	else:
		avatar.configure_profile(profile)
	name_label = Label3D.new()
	name_label.position.y = 2.1
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.no_depth_test = true
	name_label.font = preload("res://scenes/main/ui_theme.tres").default_font
	name_label.font_size = 64
	name_label.pixel_size = 0.008
	name_label.outline_size = 10
	name_label.text = tr(String(data.display_name_key))
	add_child(name_label)

func _process(delta: float) -> void:
	if state == null:
		return
	var path: Array = state.paths.get(data.npc_id, [])
	if not path.is_empty() and not GameClock.paused:
		var target: Vector3 = GridMath.cell_to_world(path[0])
		position = position.move_toward(target, data.move_speed * delta)
		if position.is_equal_approx(target):
			state.advance_step(data.npc_id)
	visible = not state.is_indoors(data.npc_id)

func reset_position() -> void:
	position = GridMath.cell_to_world(state.cells[data.npc_id])
	visible = not state.is_indoors(data.npc_id)

func play_talk() -> void:
	if avatar != null:
		avatar.play_talk()

func show_emotion(emotion_id: StringName) -> bool:
	return avatar != null and avatar.show_emotion_bubble(emotion_id)

func _catalog_profile(npc_id: StringName) -> Dictionary:
	var catalog: Resource = load(CHARACTER_CATALOG_PATH) as Resource
	if catalog == null or not catalog.has_method(&"get_npc_appearance"):
		return {}
	var appearance: Variant = catalog.call(&"get_npc_appearance", npc_id)
	return _appearance_dictionary(appearance)

func _appearance_dictionary(appearance: Variant) -> Dictionary:
	if appearance is Dictionary:
		return (appearance as Dictionary).duplicate(true)
	if appearance is Resource and (appearance as Resource).has_method(&"to_builder_dictionary"):
		var data_profile: Variant = (appearance as Resource).call(&"to_builder_dictionary")
		if data_profile is Dictionary:
			return (data_profile as Dictionary).duplicate(true)
	return {}
