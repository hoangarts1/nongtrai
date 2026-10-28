## ChibiFarmingBuilder -- deterministic original C2 crop, item and tool models.
## API:
##   static func build_crop(crop_id: StringName, stage_id: StringName, crop_color: Color, family: StringName, stage_scale: float) -> Node3D
##   static func build_item(item_id: StringName, item_color: Color) -> Node3D
##   static func build_tool(tool_id: StringName) -> Node3D
class_name ChibiFarmingBuilder
extends RefCounted

const CORE_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")
const MATERIAL_FACTORY: Script = preload("res://scripts/view/chibi_material_factory.gd")

const FOLIAGE: Color = Color("69aa58")
const DARK_FOLIAGE: Color = Color("3f7d43")
const DRY_FOLIAGE: Color = Color("92704d")
const WOOD: Color = Color("b7825f")
const STONE: Color = Color("9fa4ad")

static func build_crop(crop_id: StringName, stage_id: StringName, crop_color: Color, family: StringName = &"root", stage_scale: float = 1.0) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Crop_%s_%s" % [String(crop_id), String(stage_id)]
	root.set_meta("art_kind", &"crop")
	root.set_meta("crop_id", crop_id)
	root.set_meta("stage_id", stage_id)
	if stage_id == &"withered":
		_build_withered(root)
		return root
	var stage: int = clampi(int(stage_id), 0, 3)
	var scale_value: float = clampf(stage_scale, 0.20, 1.0)
	match family:
		&"root":
			_build_root(root, crop_id, stage, scale_value, crop_color)
		&"vine":
			if crop_id == &"summer_tomato":
				_build_tomato(root, stage, scale_value, crop_color)
			else:
				_build_pea(root, stage, scale_value, crop_color)
		&"stalk":
			_build_corn(root, stage, scale_value, crop_color)
		&"grain":
			_build_wheat(root, stage, scale_value, crop_color)
		&"ground_vine":
			_build_pumpkin(root, stage, scale_value, crop_color)
		&"leafy":
			_build_cabbage(root, stage, scale_value, crop_color)
		_:
			_build_root(root, crop_id, stage, scale_value, crop_color)
	if stage == 3:
		_add_mature_sparkles(root)
	return root

static func build_item(item_id: StringName, item_color: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Item_%s" % String(item_id)
	root.set_meta("art_kind", &"prop")
	root.set_meta("item_id", item_id)
	var id: String = String(item_id)
	if id.ends_with("_seed"):
		_box(root, "SeedPouch", Vector3(0.0, 0.19, 0.0), Vector3(0.38, 0.38, 0.17), item_color.lightened(0.12), true)
		_box(root, "PouchLabel", Vector3(0.0, 0.21, 0.091), Vector3(0.17, 0.15, 0.018), Color("fff6d5"), true)
		for index: int in range(3):
			_sphere(root, "Seed_%d" % index, Vector3(-0.08 + float(index) * 0.08, 0.14 + float(index % 2) * 0.08, 0.104), Vector3(0.045, 0.045, 0.02), item_color.darkened(0.24), false)
		return root
	var crop_id: StringName = StringName(id)
	match crop_id:
		&"turnip", &"spring_carrot", &"winter_radish":
			_sphere(root, "Root", Vector3(0.0, 0.18, 0.0), Vector3(0.34, 0.36, 0.30), item_color, true)
			_leaf(root, "Leaf", Vector3(0.02, 0.42, 0.0), 0.12, Vector3(0.12, 0.07, 0.26), FOLIAGE)
		&"spring_pea":
			_sphere(root, "PeaPod", Vector3(0.0, 0.17, 0.0), Vector3(0.20, 0.34, 0.16), item_color, true)
			_sphere(root, "PodCap", Vector3(0.0, 0.37, 0.0), Vector3(0.11, 0.08, 0.11), DARK_FOLIAGE, false)
		&"summer_tomato":
			_sphere(root, "Tomato", Vector3(0.0, 0.20, 0.0), Vector3(0.38, 0.36, 0.38), item_color, true)
			_leaf(root, "Calyx", Vector3(0.0, 0.40, 0.0), 0.0, Vector3(0.22, 0.045, 0.22), DARK_FOLIAGE)
		&"summer_corn":
			_sphere(root, "Corn", Vector3(0.0, 0.29, 0.0), Vector3(0.23, 0.58, 0.20), item_color, true)
			_leaf(root, "Husk", Vector3(0.06, 0.22, 0.0), 0.70, Vector3(0.20, 0.05, 0.42), FOLIAGE)
		&"autumn_wheat":
			_cylinder(root, "Bundle", Vector3(0.0, 0.30, 0.0), 0.06, 0.60, item_color, true)
			_cylinder(root, "BundleSide", Vector3(0.10, 0.27, 0.0), 0.05, 0.52, item_color.lightened(0.10), true)
		&"autumn_pumpkin":
			_sphere(root, "Pumpkin", Vector3(0.0, 0.20, 0.0), Vector3(0.46, 0.36, 0.43), item_color, true)
			_cylinder(root, "Stem", Vector3(0.0, 0.43, 0.0), 0.035, 0.15, DARK_FOLIAGE, true)
		&"winter_cabbage":
			_sphere(root, "Cabbage", Vector3(0.0, 0.18, 0.0), Vector3(0.43, 0.34, 0.40), item_color, true)
			_leaf(root, "Leaf", Vector3(0.16, 0.20, 0.0), 0.5, Vector3(0.24, 0.06, 0.30), item_color.lightened(0.12))
		_:
			_sphere(root, "Produce", Vector3(0.0, 0.20, 0.0), Vector3(0.34, 0.36, 0.30), item_color, true)
	return root

static func build_tool(tool_id: StringName) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Tool_%s" % String(tool_id)
	root.set_meta("art_kind", &"prop")
	root.set_meta("tool_id", tool_id)
	match tool_id:
		&"watering_can", &"water":
			_sphere(root, "CanBody", Vector3(0.0, 0.16, 0.0), Vector3(0.36, 0.28, 0.30), Color("72c8df"), true)
			_cylinder(root, "CanHandle", Vector3(0.0, 0.38, 0.0), 0.035, 0.25, WOOD, true)
			_cylinder(root, "CanSpout", Vector3(0.22, 0.18, 0.0), 0.035, 0.34, Color("72c8df"), true, Vector3(0.0, 0.0, -PI * 0.50))
		&"seed":
			_box(root, "SeedBag", Vector3(0.0, 0.19, 0.0), Vector3(0.35, 0.38, 0.16), Color("edc472"), true)
			_box(root, "SeedLabel", Vector3(0.0, 0.20, 0.091), Vector3(0.14, 0.14, 0.018), Color("fff6d5"), true)
		&"harvest":
			_cylinder(root, "Handle", Vector3(0.0, 0.30, 0.0), 0.035, 0.58, WOOD, true)
			_box(root, "SickleBlade", Vector3(0.16, 0.06, 0.0), Vector3(0.31, 0.075, 0.06), STONE, true)
		_:
			_cylinder(root, "Handle", Vector3(0.0, 0.33, 0.0), 0.035, 0.64, WOOD, true)
			_box(root, "HoeHead", Vector3(0.0, 0.045, 0.0), Vector3(0.36, 0.08, 0.075), STONE, true)
	return root

static func _build_root(root: Node3D, crop_id: StringName, stage: int, scale_value: float, crop_color: Color) -> void:
	var root_color: Color = crop_color
	if crop_id == &"spring_carrot":
		root_color = crop_color
	elif crop_id == &"winter_radish":
		root_color = crop_color.lightened(0.04)
	if stage > 0:
		_sphere(root, "RootBody", Vector3(0.0, 0.10 + 0.13 * scale_value, 0.0), Vector3(0.20 + 0.24 * scale_value, 0.20 + 0.26 * scale_value, 0.18 + 0.20 * scale_value), root_color, true)
	var leaf_count: int = 2 if stage < 2 else 3
	for index: int in range(leaf_count):
		var angle: float = TAU * float(index) / float(leaf_count)
		_leaf(root, "Leaf_%d" % index, Vector3(cos(angle) * 0.055, 0.20 + 0.34 * scale_value, sin(angle) * 0.055), angle, Vector3(0.11 + 0.10 * scale_value, 0.045, 0.18 + 0.25 * scale_value), FOLIAGE)

static func _build_pea(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	var height: float = 0.24 + 0.70 * scale_value
	_cylinder(root, "Vine", Vector3(0.0, height * 0.5, 0.0), 0.03, height, DARK_FOLIAGE, true)
	for index: int in range(2 + stage):
		var side: float = -1.0 if index % 2 == 0 else 1.0
		_leaf(root, "PeaLeaf_%d" % index, Vector3(side * 0.09, 0.18 + float(index) * height * 0.18, 0.0), side * 0.80, Vector3(0.15, 0.04, 0.22), FOLIAGE)
	if stage >= 2:
		_sphere(root, "PeaPod", Vector3(0.13, height * 0.54, 0.02), Vector3(0.12, 0.27, 0.10), crop_color, true)

static func _build_tomato(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	var height: float = 0.28 + 0.70 * scale_value
	_cylinder(root, "TomatoStem", Vector3(0.0, height * 0.5, 0.0), 0.035, height, DARK_FOLIAGE, true)
	for index: int in range(2 + mini(stage, 2)):
		var angle: float = TAU * float(index) / float(2 + mini(stage, 2))
		_leaf(root, "TomatoLeaf_%d" % index, Vector3(cos(angle) * 0.13, height * (0.30 + float(index) * 0.12), sin(angle) * 0.13), angle, Vector3(0.19, 0.045, 0.25), FOLIAGE)
	if stage >= 2:
		for index: int in range(2 if stage == 2 else 3):
			var angle: float = TAU * float(index) / float(2 if stage == 2 else 3)
			_sphere(root, "Tomato_%d" % index, Vector3(cos(angle) * 0.16, height * 0.46, sin(angle) * 0.16), Vector3(0.17, 0.17, 0.17), crop_color, true)

static func _build_corn(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	var height: float = 0.34 + 1.00 * scale_value
	_cylinder(root, "CornStalk", Vector3(0.0, height * 0.5, 0.0), 0.042, height, Color("6d9850"), true)
	for index: int in range(2 + mini(stage, 2)):
		var side: float = -1.0 if index % 2 == 0 else 1.0
		_leaf(root, "CornLeaf_%d" % index, Vector3(side * 0.10, height * (0.25 + float(index) * 0.16), 0.0), side * 1.02, Vector3(0.14, 0.035, 0.42), FOLIAGE)
	if stage >= 2:
		_sphere(root, "CornEar", Vector3(0.13, height * 0.56, 0.02), Vector3(0.13, 0.30, 0.12), crop_color, true)

static func _build_wheat(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	var height: float = 0.25 + 0.70 * scale_value
	for index: int in range(2 + mini(stage, 2)):
		var offset: float = -0.09 + float(index) * 0.09
		_cylinder(root, "WheatStem_%d" % index, Vector3(offset, height * 0.5, 0.0), 0.022, height * (0.88 + float(index) * 0.04), Color("91a74c"), true)
		if stage >= 2:
			_sphere(root, "WheatHead_%d" % index, Vector3(offset, height * 0.91, 0.0), Vector3(0.10, 0.24, 0.10), crop_color, true)

static func _build_pumpkin(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	_cylinder(root, "PumpkinVine", Vector3(0.0, 0.06, 0.0), 0.025, 0.35 + 0.35 * scale_value, DARK_FOLIAGE, true, Vector3(0.0, 0.0, PI * 0.50))
	for index: int in range(2 + mini(stage, 2)):
		var angle: float = TAU * float(index) / float(2 + mini(stage, 2))
		_leaf(root, "PumpkinLeaf_%d" % index, Vector3(cos(angle) * 0.18, 0.10, sin(angle) * 0.18), angle, Vector3(0.24 + 0.10 * scale_value, 0.05, 0.28 + 0.10 * scale_value), FOLIAGE)
	if stage >= 2:
		_sphere(root, "Pumpkin", Vector3(0.06, 0.16 + 0.08 * scale_value, -0.04), Vector3(0.28 + 0.20 * scale_value, 0.22 + 0.16 * scale_value, 0.28 + 0.20 * scale_value), crop_color, true)

static func _build_cabbage(root: Node3D, stage: int, scale_value: float, crop_color: Color) -> void:
	var count: int = 3 + stage
	for index: int in range(count):
		var angle: float = TAU * float(index) / float(count)
		_leaf(root, "CabbageLeaf_%d" % index, Vector3(cos(angle) * 0.12, 0.11 + 0.03 * scale_value, sin(angle) * 0.12), angle, Vector3(0.20 + 0.15 * scale_value, 0.055, 0.23 + 0.13 * scale_value), crop_color.lightened(0.10))
	if stage >= 1:
		_sphere(root, "CabbageHeart", Vector3(0.0, 0.13 + 0.12 * scale_value, 0.0), Vector3(0.22 + 0.20 * scale_value, 0.19 + 0.17 * scale_value, 0.22 + 0.20 * scale_value), crop_color, true)

static func _build_withered(root: Node3D) -> void:
	_cylinder(root, "DryStem", Vector3(0.0, 0.29, 0.0), 0.032, 0.58, DRY_FOLIAGE, true)
	for index: int in range(3):
		var angle: float = TAU * float(index) / 3.0
		_leaf(root, "DryLeaf_%d" % index, Vector3(cos(angle) * 0.09, 0.23 + float(index) * 0.07, sin(angle) * 0.09), angle, Vector3(0.14, 0.03, 0.24), DRY_FOLIAGE)

static func _add_mature_sparkles(root: Node3D) -> void:
	var sparkles: Node3D = Node3D.new()
	sparkles.name = "MatureSparkles"
	root.add_child(sparkles)
	for index: int in range(3):
		var angle: float = TAU * float(index) / 3.0
		_box(sparkles, "Sparkle_%d" % index, Vector3(cos(angle) * 0.28, 0.58 + float(index) * 0.12, sin(angle) * 0.28), Vector3(0.045, 0.13, 0.025), Color("fff0a6"), true)

static func _leaf(parent: Node3D, part_name: String, origin: Vector3, yaw: float, dimensions: Vector3, color: Color) -> void:
	var leaf: MeshInstance3D = _sphere(parent, part_name, origin, dimensions, color, false)
	leaf.rotation.y = yaw
	leaf.rotation.z = 0.28

static func _sphere(parent: Node3D, part_name: String, origin: Vector3, dimensions: Vector3, color: Color, outlined: bool) -> MeshInstance3D:
	var mesh: ArrayMesh = CORE_BUILDER._rounded_mesh(8, 3)
	return _mesh(parent, part_name, mesh, origin, dimensions, color, &"toon", outlined)

static func _cylinder(parent: Node3D, part_name: String, origin: Vector3, radius: float, height: float, color: Color, outlined: bool, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh: ArrayMesh = CORE_BUILDER._cylinder_mesh(8)
	var part: MeshInstance3D = _mesh(parent, part_name, mesh, origin, Vector3(radius * 2.0, height, radius * 2.0), color, &"toon", outlined)
	part.rotation = rotation_value
	return part

static func _box(parent: Node3D, part_name: String, origin: Vector3, size: Vector3, color: Color, outlined: bool) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return _mesh(parent, part_name, mesh, origin, Vector3.ONE, color, &"toon", outlined)

static func _mesh(parent: Node3D, part_name: String, mesh: Mesh, origin: Vector3, scale_value: Vector3, color: Color, shader_id: StringName, outlined: bool) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = part_name
	instance.mesh = mesh
	instance.position = origin
	instance.scale = scale_value
	var material: ShaderMaterial = MATERIAL_FACTORY.create_material(shader_id, &"foliage")
	if material.shader != null:
		material.set_shader_parameter(&"base_color", color)
		# The game world retains DayNightProfile authority. A local tinted shadow
		# keeps the tiny crop silhouettes readable when that profile is low-angle.
		material.set_shader_parameter(&"shadow_color", color.darkened(0.18))
		material.set_shader_parameter(&"rim_color", color.lightened(0.24))
		if outlined:
			var outline: ShaderMaterial = MATERIAL_FACTORY.create_material(&"outline", &"outline")
			if outline.shader != null:
				material.next_pass = outline
	instance.material_override = material
	parent.add_child(instance)
	return instance
