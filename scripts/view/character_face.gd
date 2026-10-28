## CharacterFace — view-only chibi eyes, mouth and expressions mounted beneath a head pivot.
## API:
##   func configure(profile: Dictionary = {}) -> void
##   func set_emotion(emotion_id: StringName) -> bool
##   func set_blinking(value: bool) -> void
##   func set_talk_phase(phase: float) -> void
class_name CharacterFace
extends Node3D

const EMOTIONS: Array[String] = ["normal", "happy", "surprised", "sad", "sleep", "talk"]

var _left_eye: MeshInstance3D
var _right_eye: MeshInstance3D
var _mouth: MeshInstance3D
var _left_cheek: MeshInstance3D
var _right_cheek: MeshInstance3D
var _emotion: StringName = &"normal"
var _blinking: bool = false
var _talk_phase: float = 0.0

func configure(profile: Dictionary = {}) -> void:
	for child: Node in get_children():
		child.queue_free()
	# The fixed camera looks down onto the characters. Features stay just above
	# the head surface (rather than floating ahead of it) and sit high enough to
	# read under hair and a raised hat brim.
	_left_eye = _part("EyeLeft", Vector3(-0.16, 0.115, 0.255), Vector3(0.080, 0.110, 0.028), _profile_color(profile, "eye_color", Color("443a32")), false)
	_right_eye = _part("EyeRight", Vector3(0.16, 0.115, 0.255), Vector3(0.080, 0.110, 0.028), _profile_color(profile, "eye_color", Color("443a32")), false)
	_mouth = _part("Mouth", Vector3(0.0, -0.050, 0.263), Vector3(0.115, 0.046, 0.023), _profile_color(profile, "mouth_color", Color("9a5c5a")), false)
	_left_cheek = _part("CheekLeft", Vector3(-0.275, -0.020, 0.245), Vector3(0.095, 0.042, 0.015), _profile_color(profile, "blush_color", Color("efa3a2")), true)
	_right_cheek = _part("CheekRight", Vector3(0.275, -0.020, 0.245), Vector3(0.095, 0.042, 0.015), _profile_color(profile, "blush_color", Color("efa3a2")), true)
	set_emotion(_emotion)

func set_emotion(emotion_id: StringName) -> bool:
	if not EMOTIONS.has(String(emotion_id)):
		return false
	_emotion = emotion_id
	if _left_eye == null or _right_eye == null or _mouth == null:
		return true
	_left_eye.rotation = Vector3.ZERO
	_right_eye.rotation = Vector3.ZERO
	_left_eye.scale = Vector3.ONE
	_right_eye.scale = Vector3.ONE
	_mouth.scale = Vector3.ONE
	_mouth.position = Vector3(0.0, -0.050, 0.263)
	_left_cheek.visible = emotion_id != &"sleep"
	_right_cheek.visible = emotion_id != &"sleep"
	match emotion_id:
		&"happy":
			_left_eye.scale.y = 0.42
			_right_eye.scale.y = 0.42
			_mouth.scale = Vector3(1.25, 1.45, 1.0)
			_mouth.position.y -= 0.012
		&"surprised":
			_left_eye.scale = Vector3(1.20, 1.30, 1.0)
			_right_eye.scale = Vector3(1.20, 1.30, 1.0)
			_mouth.scale = Vector3(0.82, 2.10, 1.0)
			_left_cheek.visible = false
			_right_cheek.visible = false
		&"sad":
			_left_eye.rotation.z = deg_to_rad(14.0)
			right_eye_rotation(-14.0)
			_mouth.scale = Vector3(1.15, 0.55, 1.0)
			_mouth.position.y += 0.025
		&"sleep":
			_left_eye.scale.y = 0.18
			_right_eye.scale.y = 0.18
			_mouth.scale = Vector3(0.70, 0.55, 1.0)
		&"talk":
			_apply_talk_phase()
	if _blinking and emotion_id != &"sleep":
		_left_eye.scale.y *= 0.12
		_right_eye.scale.y *= 0.12
	return true

func set_blinking(value: bool) -> void:
	if _blinking == value:
		return
	_blinking = value
	set_emotion(_emotion)

func set_talk_phase(phase: float) -> void:
	_talk_phase = clampf(phase, 0.0, 1.0)
	if _emotion == &"talk" and not _blinking:
		_apply_talk_phase()

func get_emotion() -> StringName:
	return _emotion

func _apply_talk_phase() -> void:
	if _mouth == null:
		return
	_mouth.scale = Vector3(0.92, lerpf(0.75, 1.85, _talk_phase), 1.0)
	_mouth.position.y = -0.050 - _talk_phase * 0.016

func right_eye_rotation(degrees: float) -> void:
	if _right_eye != null:
		_right_eye.rotation.z = deg_to_rad(degrees)

func _part(part_name: String, origin: Vector3, dimensions: Vector3, color: Color, translucent: bool) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = part_name
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 10
	mesh.rings = 5
	node.mesh = mesh
	node.position = origin
	node.scale = dimensions
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	if translucent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	node.material_override = material
	add_child(node)
	return node

func _profile_color(profile: Dictionary, key: String, fallback: Color) -> Color:
	var value: Variant = profile.get(key, fallback)
	return value as Color if value is Color else fallback
