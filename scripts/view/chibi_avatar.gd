## ChibiAvatar — view-only C1 character rig, animation clips, face and emotion presentation.
## API:
##   func configure(outfit: Color, with_hat: bool = true) -> void
##   func configure_profile(profile: Dictionary, customization: Dictionary = {}) -> void
##   func apply_customization(customization: Dictionary) -> void
##   func set_emotion(emotion_id: StringName) -> bool
##   func show_emotion_bubble(emotion_id: StringName, duration: float = 1.25) -> bool
##   func play_tool(tool_id: StringName = &"hoe") -> void
##   func play_sleep() -> void
##   func play_talk(duration: float = 0.85) -> void
class_name ChibiAvatar
extends Node3D

const MODEL_BUILDER_PATH: String = "res://tools/art/chibi/chibi_character_builder.gd"

var _model: Node3D
var _rig: Node3D
var _face: CharacterFace
var _bubble: EmotionBubble
var _animation_player: AnimationPlayer
var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _tool_prop: Node3D
var _profile: Dictionary = {}
var _customization: Dictionary = {}
var _last_position: Vector3
var _elapsed: float = 0.0
var _blink_timer: float = 3.8
var _blink_remaining: float = 0.0
var _action_remaining: float = 0.0
var _current_animation: StringName = &""

func configure(outfit: Color, with_hat: bool = true) -> void:
	configure_profile(_fallback_profile(outfit, with_hat))

func configure_profile(profile: Dictionary, customization: Dictionary = {}) -> void:
	_profile = profile.duplicate(true)
	_customization = customization.duplicate(true)
	_rebuild()

func apply_customization(customization: Dictionary) -> void:
	configure_profile(_profile, customization)

func set_emotion(emotion_id: StringName) -> bool:
	return _face != null and _face.set_emotion(emotion_id)

func show_emotion_bubble(emotion_id: StringName, duration: float = 1.25) -> bool:
	return _bubble != null and _bubble.show_emotion(emotion_id, duration)


func play_tool(tool_id: StringName = &"hoe") -> void:
	_set_tool_kind(tool_id)
	_set_tool_visible(true)
	_action_remaining = 0.62
	_play_animation(&"Tool")

func play_sleep() -> void:
	_action_remaining = 999999.0
	set_emotion(&"sleep")
	show_emotion_bubble(&"sleep", 1.8)
	_play_animation(&"Sleep")

func play_talk(duration: float = 0.85) -> void:
	_action_remaining = maxf(duration, 0.05)
	set_emotion(&"talk")
	_play_animation(&"Talk")

func stop_action() -> void:
	_action_remaining = 0.0
	_set_tool_visible(false)
	set_emotion(&"normal")

func get_model() -> Node3D:
	return _model

func get_face() -> CharacterFace:
	return _face

func get_animation_player() -> AnimationPlayer:
	return _animation_player

func set_facing_direction(direction: Vector3) -> void:
	if _rig == null:
		return
	var flat: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.000001:
		return
	var step: float = PI / 4.0
	var angle: float = atan2(flat.x, flat.z)
	_rig.rotation.y = roundf(angle / step) * step

func _process(delta: float) -> void:
	if _model == null or _animation_player == null:
		return
	var displacement: Vector3 = global_position - _last_position
	var moving: bool = displacement.length_squared() > 0.00001
	if moving:
		set_facing_direction(displacement)
	_last_position = global_position
	if GameClock.paused:
		return
	_elapsed += delta
	_update_blink(delta)
	if _action_remaining > 0.0:
		_action_remaining = maxf(_action_remaining - delta, 0.0)
		if _face != null and _face.get_emotion() == &"talk":
			_face.set_talk_phase((sin(_elapsed * 17.0) + 1.0) * 0.5)
		if _action_remaining <= 0.0:
			_set_tool_visible(false)
			if _face != null and _face.get_emotion() != &"normal":
				_face.set_emotion(&"normal")
	else:
		_play_animation(&"Walk" if moving else &"Idle")
	_animation_player.advance(delta)

func _rebuild() -> void:
	_clear_old_children()
	_model = _build_model(_profile, _customization)
	_model.name = "Model"
	add_child(_model)
	_rig = _ensure_pivot("Rig", _model)
	_ensure_pivot("Body", _rig)
	var head: Node3D = _ensure_pivot("Head", _rig)
	_left_arm = _ensure_pivot("ArmLeft", _rig)
	_right_arm = _ensure_pivot("ArmRight", _rig)
	_left_leg = _ensure_pivot("LegLeft", _rig)
	_right_leg = _ensure_pivot("LegRight", _rig)
	_ensure_pivot("Accessory", _rig)
	var previous_face: Node = head.get_node_or_null("Face")
	if previous_face != null:
		previous_face.free()
	_face = CharacterFace.new()
	_face.name = "Face"
	_face.configure(_merged_profile())
	head.add_child(_face)
	_bubble = EmotionBubble.new()
	_bubble.name = "EmotionBubble"
	_bubble.position = Vector3(0.0, 1.60, 0.0)
	_model.add_child(_bubble)
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AnimationPlayer"
	_animation_player.root_node = NodePath("..")
	_animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	add_child(_animation_player)
	_build_animations()
	_add_held_tool()
	_set_tool_visible(false)
	_last_position = global_position
	_elapsed = 0.0
	_blink_timer = 3.8
	_blink_remaining = 0.0
	_action_remaining = 0.0
	_current_animation = &""
	_play_animation(&"Idle")

func _clear_old_children() -> void:
	for child: Node in get_children():
		child.free()
	_model = null
	_rig = null
	_face = null
	_bubble = null
	_animation_player = null
	_left_arm = null
	_right_arm = null
	_left_leg = null
	_right_leg = null
	_tool_prop = null

func _build_model(profile: Dictionary, customization: Dictionary) -> Node3D:
	var script: Script = load(MODEL_BUILDER_PATH) as Script
	if script != null and script.has_method(&"build_character"):
		var generated: Variant = script.call(&"build_character", profile, customization)
		if generated is Node3D:
			return generated as Node3D
	return _fallback_model(_merged_profile())

func _merged_profile() -> Dictionary:
	var merged: Dictionary = _profile.duplicate(true)
	for key: Variant in _customization:
		merged[key] = _customization[key]
	return merged

func _ensure_pivot(pivot_name: String, parent: Node3D) -> Node3D:
	var found: Node3D = parent.find_child(pivot_name, true, false) as Node3D
	if found != null:
		return found
	var pivot: Node3D = Node3D.new()
	pivot.name = pivot_name
	parent.add_child(pivot)
	return pivot

func _build_animations() -> void:
	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation(&"Idle", _make_animation(1.45, 0.05, 0.00, 0.025, true))
	library.add_animation(&"Walk", _make_animation(0.56, 0.42, 0.52, 0.045, true))
	library.add_animation(&"Run", _make_animation(0.42, 0.60, 0.68, 0.060, true))
	library.add_animation(&"Tool", _make_animation(0.62, 1.06, 0.18, 0.040, false))
	library.add_animation(&"Sleep", _make_animation(1.20, 0.00, 0.00, 0.010, true))
	library.add_animation(&"Talk", _make_animation(0.45, 0.16, 0.06, 0.018, true))
	_animation_player.add_animation_library(&"", library)

func _make_animation(length: float, arm_amount: float, leg_amount: float, bounce: float, loops: bool) -> Animation:
	var animation: Animation = Animation.new()
	animation.length = length
	animation.loop_mode = Animation.LOOP_LINEAR if loops else Animation.LOOP_NONE
	_rotation_track(animation, NodePath("Model/Rig/ArmLeft:rotation"), Vector3.ZERO, Vector3(arm_amount, 0.0, 0.0), Vector3.ZERO, length)
	_rotation_track(animation, NodePath("Model/Rig/ArmRight:rotation"), Vector3.ZERO, Vector3(-arm_amount, 0.0, 0.0), Vector3.ZERO, length)
	_rotation_track(animation, NodePath("Model/Rig/LegLeft:rotation"), Vector3.ZERO, Vector3(-leg_amount, 0.0, 0.0), Vector3.ZERO, length)
	_rotation_track(animation, NodePath("Model/Rig/LegRight:rotation"), Vector3.ZERO, Vector3(leg_amount, 0.0, 0.0), Vector3.ZERO, length)
	_position_track(animation, NodePath("Model/Rig:position"), Vector3.ZERO, Vector3(0.0, bounce, 0.0), Vector3.ZERO, length)
	return animation

func _rotation_track(animation: Animation, path: NodePath, start: Vector3, middle: Vector3, finish: Vector3, length: float) -> void:
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, path)
	animation.track_insert_key(track, 0.0, start)
	animation.track_insert_key(track, length * 0.5, middle)
	animation.track_insert_key(track, length, finish)

func _position_track(animation: Animation, path: NodePath, start: Vector3, middle: Vector3, finish: Vector3, length: float) -> void:
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, path)
	animation.track_insert_key(track, 0.0, start)
	animation.track_insert_key(track, length * 0.5, middle)
	animation.track_insert_key(track, length, finish)

func _play_animation(animation_name: StringName) -> void:
	if _animation_player == null or _current_animation == animation_name:
		return
	_current_animation = animation_name
	_animation_player.play(animation_name)
	_animation_player.advance(0.0)

func _update_blink(delta: float) -> void:
	if _face == null:
		return
	if _blink_remaining > 0.0:
		_blink_remaining -= delta
		if _blink_remaining <= 0.0:
			_face.set_blinking(false)
		return
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_face.set_blinking(true)
		_blink_remaining = 0.12
		_blink_timer = 4.2

func _add_held_tool() -> void:
	if _right_arm == null:
		return
	_tool_prop = Node3D.new()
	_tool_prop.name = "ToolProp"
	_tool_prop.position = Vector3(0.0, -0.24, 0.08)
	_tool_prop.rotation_degrees = Vector3(18.0, 0.0, -28.0)
	_right_arm.add_child(_tool_prop)
	_set_tool_kind(&"hoe")

func _set_tool_kind(tool_id: StringName) -> void:
	if _tool_prop == null:
		return
	for child: Node in _tool_prop.get_children():
		child.free()
	match tool_id:
		&"water", &"watering_can":
			_tool_sphere("Can", Vector3(0.0, 0.0, 0.0), Vector3(0.23, 0.20, 0.20), &"water")
			_tool_cylinder("Handle", Vector3(0.0, 0.15, 0.0), 0.030, 0.22, &"wood")
			_tool_cylinder("Spout", Vector3(0.16, 0.01, 0.0), 0.035, 0.26, &"water", Vector3(0.0, 0.0, -PI * 0.5))
		&"seed":
			_tool_sphere("SeedBag", Vector3(0.0, 0.0, 0.0), Vector3(0.20, 0.24, 0.10), &"ui_accent")
			_tool_box("SeedLabel", Vector3(0.0, 0.02, 0.105), Vector3(0.10, 0.10, 0.018), &"sunlight")
		&"harvest":
			_tool_cylinder("Handle", Vector3(0.0, 0.0, 0.0), 0.030, 0.46, &"wood")
			_tool_box("SickleBlade", Vector3(0.11, -0.17, 0.0), Vector3(0.22, 0.06, 0.035), &"stone")
		_:
			_tool_cylinder("Handle", Vector3(0.0, 0.0, 0.0), 0.030, 0.48, &"wood")
			_tool_box("HoeHead", Vector3(0.0, -0.22, 0.0), Vector3(0.24, 0.07, 0.065), &"stone")

func _tool_sphere(part_name: String, origin: Vector3, dimensions: Vector3, role: StringName) -> void:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 10
	mesh.rings = 5
	_tool_mesh(part_name, mesh, origin, dimensions, role)

func _tool_cylinder(part_name: String, origin: Vector3, radius: float, height: float, role: StringName, rotation_value: Vector3 = Vector3.ZERO) -> void:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	var part: MeshInstance3D = _tool_mesh(part_name, mesh, origin, Vector3.ONE, role)
	part.rotation = rotation_value

func _tool_box(part_name: String, origin: Vector3, dimensions: Vector3, role: StringName) -> void:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	_tool_mesh(part_name, mesh, origin, Vector3.ONE, role)

func _tool_mesh(part_name: String, mesh: Mesh, origin: Vector3, dimensions: Vector3, role: StringName) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = origin
	part.scale = dimensions
	part.material_override = ChibiMaterialFactory.create_material(&"toon", role)
	_tool_prop.add_child(part)
	return part

func _set_tool_visible(value: bool) -> void:
	if _tool_prop != null:
		_tool_prop.visible = value

func _fallback_profile(outfit: Color, with_hat: bool) -> Dictionary:
	return {
		"character_id": &"fallback",
		"skin_color": Color("f4ccac"),
		"hair_color": Color("78573f"),
		"outfit_color": outfit,
		"accent_color": Color("ebcd8e"),
		"shoe_color": Color("73583f"),
		"eye_color": Color("443a32"),
		"cheek_color": Color("e7a29b"),
		"hair_style": &"round",
		"accessory": &"straw_hat" if with_hat else &"none"
	}

func _fallback_model(profile: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "FallbackCharacterModel"
	var rig: Node3D = Node3D.new()
	rig.name = "Rig"
	root.add_child(rig)
	var body: Node3D = _fallback_pivot(rig, "Body", Vector3(0.0, 0.57, 0.0))
	_fallback_part(body, "BodyMesh", Vector3.ZERO, Vector3(0.42, 0.50, 0.30), _color(profile, "outfit_color", Color("a7bd88")))
	var head: Node3D = _fallback_pivot(rig, "Head", Vector3(0.0, 1.12, 0.0))
	_fallback_part(head, "HeadMesh", Vector3.ZERO, Vector3(0.62, 0.58, 0.52), _color(profile, "skin_color", Color("f4ccac")))
	for side: float in [-1.0, 1.0]:
		var side_name: String = "Left" if side < 0.0 else "Right"
		var arm: Node3D = _fallback_pivot(rig, "Arm%s" % side_name, Vector3(side * 0.32, 0.70, 0.0))
		_fallback_part(arm, "ArmMesh", Vector3(0.0, -0.14, 0.0), Vector3(0.13, 0.30, 0.14), _color(profile, "skin_color", Color("f4ccac")))
		var leg: Node3D = _fallback_pivot(rig, "Leg%s" % side_name, Vector3(side * 0.14, 0.28, 0.0))
		_fallback_part(leg, "LegMesh", Vector3.ZERO, Vector3(0.19, 0.36, 0.22), _color(profile, "shoe_color", Color("73583f")))
	var accessory: Node3D = _fallback_pivot(rig, "Accessory", Vector3(0.0, 1.48, 0.0))
	if StringName(profile.get("accessory", &"none")) != &"none":
		_fallback_part(accessory, "AccessoryMesh", Vector3.ZERO, Vector3(0.65, 0.18, 0.55), _color(profile, "accent_color", Color("ebcd8e")))
	return root

func _fallback_pivot(parent: Node3D, pivot_name: String, origin: Vector3) -> Node3D:
	var pivot: Node3D = Node3D.new()
	pivot.name = pivot_name
	pivot.position = origin
	parent.add_child(pivot)
	return pivot

func _fallback_part(parent: Node3D, part_name: String, origin: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = part_name
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 10
	mesh.rings = 5
	part.mesh = mesh
	part.position = origin
	part.scale = dimensions
	part.material_override = ChibiMaterialFactory.create_material(&"toon", &"ui_accent")
	var material: ShaderMaterial = part.material_override as ShaderMaterial
	if material != null:
		material.set_shader_parameter(&"base_color", color)
	parent.add_child(part)
	return part

func _color(profile: Dictionary, key: String, fallback: Color) -> Color:
	var value: Variant = profile.get(key, fallback)
	return value as Color if value is Color else fallback
