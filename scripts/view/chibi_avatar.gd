## ChibiAvatar — procedural cozy character and view-only idle/walk animation.
class_name ChibiAvatar
extends Node3D

var _rig: Node3D
var _left_leg: MeshInstance3D
var _right_leg: MeshInstance3D
var _elapsed: float = 0.0
var _last_position: Vector3

func configure(outfit: Color, with_hat: bool = true) -> void:
	_rig = Node3D.new()
	_rig.rotation.y = PI / 4.0
	add_child(_rig)
	_part(_ellipsoid(Vector3(0.45, 0.55, 0.34)), Vector3(0, 0.64, 0), outfit)
	_part(_ellipsoid(Vector3(0.61, 0.58, 0.52)), Vector3(0, 1.12, 0), Color("f4ccac"))
	_part(_ellipsoid(Vector3(0.64, 0.35, 0.54)), Vector3(0, 1.29, -0.02), Color("78573f"))
	for side: float in [-1.0, 1.0]:
		_part(_ellipsoid(Vector3(0.065, 0.09, 0.045)), Vector3(side * 0.12, 1.14, 0.25), Color("443a32"))
		_part(_ellipsoid(Vector3(0.10, 0.045, 0.025)), Vector3(side * 0.21, 1.06, 0.22), Color("e7a29b"))
		_part(_ellipsoid(Vector3(0.14, 0.32, 0.16)), Vector3(side * 0.28, 0.66, 0), Color("f4ccac"))
	_left_leg = _part(_ellipsoid(Vector3(0.18, 0.32, 0.22)), Vector3(-0.13, 0.27, 0.02), Color("73583f"))
	_right_leg = _part(_ellipsoid(Vector3(0.18, 0.32, 0.22)), Vector3(0.13, 0.27, 0.02), Color("73583f"))
	_part(_ellipsoid(Vector3(0.34, 0.35, 0.16)), Vector3(0, 0.69, -0.23), Color("c69760"))
	if with_hat:
		var brim: CylinderMesh = CylinderMesh.new()
		brim.top_radius = 0.45
		brim.bottom_radius = 0.45
		brim.height = 0.07
		_part(brim, Vector3(0, 1.43, 0), Color("ebcd8e"))
		_part(_ellipsoid(Vector3(0.56, 0.29, 0.52)), Vector3(0, 1.54, 0), Color("ebcd8e"))
		_part(_ellipsoid(Vector3(0.12, 0.08, 0.1)), Vector3(0.28, 1.48, 0.20), Color("a0ba7a"))
	_last_position = global_position

func _process(delta: float) -> void:
	if _rig == null:
		return
	var moving: bool = global_position.distance_squared_to(_last_position) > 0.00001
	_last_position = global_position
	if GameClock.paused:
		return
	_elapsed += delta
	_rig.position.y = sin(_elapsed * (9.0 if moving else 2.0)) * (0.04 if moving else 0.012)
	_left_leg.rotation.x = sin(_elapsed * 10.0) * 0.4 if moving else 0.0
	_right_leg.rotation.x = -_left_leg.rotation.x

func _ellipsoid(dimensions: Vector3) -> SphereMesh:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	# The requested shape is applied as a local visual scale after creation.
	mesh.set_meta("visual_scale", dimensions)
	return mesh

func _part(mesh: Mesh, origin: Vector3, color: Color) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.mesh = mesh
	part.position = origin
	part.scale = mesh.get_meta("visual_scale", Vector3.ONE)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	part.material_override = material
	_rig.add_child(part)
	return part
