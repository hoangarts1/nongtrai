## NpcActor — placeholder and route interpolation; logical cells live in NpcSocialState.
class_name NpcActor
extends Node3D

var state: NpcSocialState
var data: NpcData
var name_label: Label3D

func configure(social: NpcSocialState, npc: NpcData) -> void:
	state = social
	data = npc
	position = GridMath.cell_to_world(state.cells[data.npc_id])
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.25
	capsule.height = 1.2
	mesh.mesh = capsule
	mesh.position.y = 0.6
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = data.color
	mesh.material_override = material
	add_child(mesh)
	name_label = Label3D.new()
	name_label.position.y = 1.6
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
