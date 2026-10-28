## EmotionBubble — transient view-only chibi reaction marker above an avatar.
## API:
##   func show_emotion(emotion_id: StringName, duration: float = 1.25) -> bool
##   func hide_emotion() -> void
class_name EmotionBubble
extends Node3D

const SYMBOLS: Dictionary = {
	&"heart": "♥",
	&"surprise": "!",
	&"question": "?",
	&"music": "♪",
	&"sweat": "·",
	&"sleep": "z"
}

var _bubble: MeshInstance3D
var _drop: MeshInstance3D
var _label: Label3D
var _remaining: float = 0.0
var _elapsed: float = 0.0
var _origin_y: float = 0.0

func _ready() -> void:
	_build()
	hide_emotion()

func show_emotion(emotion_id: StringName, duration: float = 1.25) -> bool:
	if not SYMBOLS.has(emotion_id):
		return false
	if _bubble == null:
		_build()
	_label.text = String(SYMBOLS[emotion_id])
	_drop.visible = emotion_id == &"sweat"
	_label.visible = emotion_id != &"sweat"
	_remaining = maxf(duration, 0.05)
	_elapsed = 0.0
	visible = true
	return true

func hide_emotion() -> void:
	_remaining = 0.0
	visible = false

func _process(delta: float) -> void:
	if _remaining <= 0.0:
		return
	_remaining -= delta
	_elapsed += delta
	position.y = _origin_y + sin(_elapsed * 7.0) * 0.028
	var pulse: float = 1.0 + sin(_elapsed * 9.0) * 0.05
	scale = Vector3.ONE * pulse
	if _remaining <= 0.0:
		hide_emotion()

func _build() -> void:
	if _bubble != null:
		return
	_origin_y = position.y
	_bubble = MeshInstance3D.new()
	_bubble.name = "Bubble"
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	_bubble.mesh = mesh
	_bubble.scale = Vector3(0.28, 0.23, 0.075)
	_bubble.position = Vector3(0.0, 0.0, 0.025)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("fff7e5")
	_bubble.material_override = material
	add_child(_bubble)
	_drop = MeshInstance3D.new()
	_drop.name = "SweatDrop"
	var drop_mesh: SphereMesh = SphereMesh.new()
	drop_mesh.radius = 0.5
	drop_mesh.height = 1.0
	drop_mesh.radial_segments = 8
	drop_mesh.rings = 4
	_drop.mesh = drop_mesh
	_drop.scale = Vector3(0.07, 0.12, 0.04)
	_drop.position = Vector3(0.10, -0.02, 0.09)
	var drop_material: StandardMaterial3D = StandardMaterial3D.new()
	drop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop_material.albedo_color = Color("8ebbd2")
	_drop.material_override = drop_material
	add_child(_drop)
	_label = Label3D.new()
	_label.name = "Symbol"
	_label.position = Vector3(0.0, -0.09, 0.075)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.font_size = 72
	_label.outline_size = 6
	_label.modulate = Color("624955")
	_label.outline_modulate = Color("fff7e5")
	_label.pixel_size = 0.003
	add_child(_label)
