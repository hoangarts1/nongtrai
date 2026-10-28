## FarmEffects -- bounded, view-only C2 feedback after successful farm actions.
## API:
##   func play_action(cell: Vector2i, action_id: StringName) -> void
class_name FarmEffects
extends Node3D

const CATALOG: FarmingArtCatalog = preload("res://data/art/farming/chibi_farming_catalog.tres")
const MAX_ACTIVE_EFFECTS: int = 12
const EFFECT_SECONDS: float = 0.48

func play_action(cell: Vector2i, action_id: StringName) -> void:
	if get_child_count() >= MAX_ACTIVE_EFFECTS:
		return
	var effect: Node3D = Node3D.new()
	effect.name = "FarmEffect_%s" % String(action_id)
	effect.position = GridMath.cell_to_world(cell) + Vector3(0.0, 0.14, 0.0)
	effect.set_meta("remaining", EFFECT_SECONDS)
	effect.set_meta("action_id", action_id)
	add_child(effect)
	var color: Color = _effect_color(action_id)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + float(posmod(cell.x * 17 + cell.y * 11, 45)) * 0.01
		var particle: MeshInstance3D = _particle("Particle_%d" % index, color)
		particle.position = Vector3(cos(angle) * 0.09, float(index % 2) * 0.05, sin(angle) * 0.09)
		particle.set_meta("velocity", Vector3(cos(angle) * 0.16, 0.36 + float(index) * 0.035, sin(angle) * 0.16))
		effect.add_child(particle)

func _process(delta: float) -> void:
	for effect: Node in get_children():
		var remaining: float = float(effect.get_meta("remaining", 0.0)) - delta
		if remaining <= 0.0:
			effect.queue_free()
			continue
		effect.set_meta("remaining", remaining)
		for particle: Node in effect.get_children():
			var mesh: MeshInstance3D = particle as MeshInstance3D
			if mesh == null:
				continue
			var velocity: Vector3 = mesh.get_meta("velocity", Vector3.ZERO)
			mesh.position += velocity * delta
			mesh.scale = Vector3.ONE * maxf(0.18, remaining / EFFECT_SECONDS)

func _effect_color(action_id: StringName) -> Color:
	match action_id:
		&"seed":
			return CATALOG.seed_effect_color
		&"water", &"watering_can":
			return CATALOG.water_effect_color
		&"harvest":
			return CATALOG.harvest_effect_color
		_:
			return CATALOG.hoe_effect_color

func _particle(particle_name: String, color: Color) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = particle_name
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 6
	mesh.rings = 3
	part.mesh = mesh
	part.scale = Vector3(0.09, 0.09, 0.09)
	var material: ShaderMaterial = ChibiMaterialFactory.create_material(&"toon", &"ui_accent")
	if material.shader != null:
		material.set_shader_parameter(&"base_color", color)
	part.material_override = material
	return part
