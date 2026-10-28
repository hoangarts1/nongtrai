## ChibiCharacterModelBuilder — deterministic original character meshes for C1.
## API:
##   static func build_character(profile: Dictionary, customization: Dictionary = {}) -> Node3D
##   static func build_dog(profile: Dictionary) -> Node3D
class_name ChibiCharacterModelBuilder
extends RefCounted

const MATERIAL_FACTORY: Script = preload("res://scripts/view/chibi_material_factory.gd")
const CORE_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")

static func build_character(profile: Dictionary, customization: Dictionary = {}) -> Node3D:
	var resolved: Dictionary = _merged_profile(profile, customization)
	var root: Node3D = Node3D.new()
	root.name = "Character_%s" % String(resolved.get("character_id", &"character")).capitalize()
	root.set_meta("art_kind", &"character")
	root.set_meta("appearance_id", resolved.get("appearance_id", &""))
	var rig: Node3D = _pivot(root, "Rig", Vector3.ZERO)
	rig.scale = Vector3.ONE * float(resolved.get("body_scale", 1.0))
	var skin: Color = resolved.get("skin_color", Color.WHITE) as Color
	var hair: Color = resolved.get("hair_color", Color.WHITE) as Color
	var outfit: Color = resolved.get("outfit_color", Color.WHITE) as Color
	var accent: Color = resolved.get("accent_color", Color.WHITE) as Color
	var shoes: Color = resolved.get("shoe_color", Color.WHITE) as Color
	var eyes: Color = resolved.get("eye_color", Color("443a32")) as Color
	var blush: Color = resolved.get("blush_color", Color("efa3a2")) as Color
	var body: Node3D = _pivot(rig, "Body", Vector3(0.0, 0.43, 0.0))
	_sphere(body, "BodyMesh", Vector3.ZERO, Vector3(0.38, 0.39, 0.29), outfit, true)
	_sphere(body, "Apron", Vector3(0.0, -0.02, 0.28), Vector3(0.25, 0.29, 0.035), accent, false)
	var head: Node3D = _pivot(rig, "Head", Vector3(0.0, 0.76, 0.0))
	_sphere(head, "HeadMesh", Vector3.ZERO, Vector3(0.58, 0.59, 0.48), skin, true)
	_add_hair(head, StringName(resolved.get("hair_style", &"round_bob")), hair)
	# Bring the expression a little forward and upward. It remains grounded in
	# the same head pivot, but stays readable from the fixed elevated game view.
	# The rounded head has a 0.24 m front radius. Keep the face just beyond that
	# curved surface so its features read as a face instead of floating pieces.
	var face: Node3D = _pivot(head, "Face", Vector3(0.0, 0.08, 0.245))
	_face_features(face, eyes, blush)
	_add_arm(rig, "ArmLeft", -1.0, skin, outfit)
	_add_arm(rig, "ArmRight", 1.0, skin, outfit)
	_add_leg(rig, "LegLeft", -1.0, shoes)
	_add_leg(rig, "LegRight", 1.0, shoes)
	var accessory: Node3D = _pivot(rig, "Accessory", Vector3.ZERO)
	_add_accessory(accessory, StringName(resolved.get("accessory", &"none")), accent, outfit, hair)
	return root

static func build_dog(profile: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PetDogCalibration"
	root.set_meta("art_kind", &"character")
	root.set_meta("appearance_id", profile.get("appearance_id", &"dog_calibration"))
	var rig: Node3D = _pivot(root, "Rig", Vector3.ZERO)
	var fur: Color = profile.get("skin_color", Color("d4ac7b")) as Color
	var dark_fur: Color = profile.get("hair_color", Color("845b3a")) as Color
	var bandana: Color = profile.get("accent_color", Color("ec555c")) as Color
	var body: Node3D = _pivot(rig, "Body", Vector3(0.0, 0.28, 0.0))
	_sphere(body, "BodyMesh", Vector3.ZERO, Vector3(0.58, 0.34, 0.38), fur, true)
	var head: Node3D = _pivot(rig, "Head", Vector3(0.32, 0.46, 0.20))
	_sphere(head, "HeadMesh", Vector3.ZERO, Vector3(0.38, 0.34, 0.34), fur, true)
	_sphere(head, "EarLeft", Vector3(-0.20, 0.12, 0.02), Vector3(0.16, 0.27, 0.12), dark_fur, true)
	_sphere(head, "EarRight", Vector3(0.20, 0.12, 0.02), Vector3(0.16, 0.27, 0.12), dark_fur, true)
	var face: Node3D = _pivot(head, "Face", Vector3(0.0, -0.04, 0.32))
	_face_features(face, Color("382d29"), fur)
	_sphere(face, "Nose", Vector3(0.0, -0.07, 0.055), Vector3(0.085, 0.06, 0.035), Color("382d29"), false, true)
	for side: float in [-1.0, 1.0]:
		var front: Node3D = _pivot(rig, "FrontPaw%s" % ("Left" if side < 0.0 else "Right"), Vector3(0.22, 0.15, side * 0.16))
		_sphere(front, "Paw", Vector3.ZERO, Vector3(0.16, 0.28, 0.15), fur, true)
		var rear: Node3D = _pivot(rig, "RearPaw%s" % ("Left" if side < 0.0 else "Right"), Vector3(-0.28, 0.15, side * 0.16))
		_sphere(rear, "Paw", Vector3.ZERO, Vector3(0.16, 0.28, 0.15), fur, true)
	var accessory: Node3D = _pivot(rig, "Accessory", Vector3(0.16, 0.35, 0.0))
	_box(accessory, "Bandana", Vector3(0.0, 0.0, 0.28), Vector3(0.12, 0.11, 0.035), bandana, false)
	var tail: Node3D = _pivot(rig, "Tail", Vector3(-0.55, 0.35, 0.0))
	tail.rotation.z = deg_to_rad(-34.0)
	_sphere(tail, "TailMesh", Vector3(-0.16, 0.16, 0.0), Vector3(0.12, 0.38, 0.13), dark_fur, true)
	return root

static func _merged_profile(profile: Dictionary, customization: Dictionary) -> Dictionary:
	var merged: Dictionary = profile.duplicate(true)
	for field: String in ["hair_style", "skin_color", "hair_color", "outfit_color", "accent_color", "shoe_color", "eye_color", "blush_color"]:
		if customization.has(field):
			merged[field] = customization[field]
	return merged

static func _pivot(parent: Node3D, pivot_name: String, origin: Vector3) -> Node3D:
	var pivot: Node3D = Node3D.new()
	pivot.name = pivot_name
	pivot.position = origin
	parent.add_child(pivot)
	return pivot

static func _add_arm(rig: Node3D, pivot_name: String, side: float, skin: Color, outfit: Color) -> void:
	var arm: Node3D = _pivot(rig, pivot_name, Vector3(side * 0.34, 0.53, 0.0))
	_sphere(arm, "Sleeve", Vector3(0.0, -0.03, 0.0), Vector3(0.15, 0.22, 0.16), outfit, true)
	_sphere(arm, "Hand", Vector3(0.0, -0.17, 0.015), Vector3(0.13, 0.13, 0.13), skin, true)

static func _add_leg(rig: Node3D, pivot_name: String, side: float, shoes: Color) -> void:
	var leg: Node3D = _pivot(rig, pivot_name, Vector3(side * 0.14, 0.19, 0.0))
	_sphere(leg, "LegMesh", Vector3(0.0, 0.04, 0.0), Vector3(0.15, 0.29, 0.17), shoes, true)
	_sphere(leg, "Shoe", Vector3(0.0, -0.075, 0.055), Vector3(0.20, 0.10, 0.25), shoes.darkened(0.12), true)

static func _face_features(face: Node3D, eye_color: Color, blush_color: Color) -> void:
	_sphere(face, "EyeLeft", Vector3(-0.15, 0.035, 0.015), Vector3(0.075, 0.105, 0.026), eye_color, false, true)
	_sphere(face, "EyeRight", Vector3(0.15, 0.035, 0.015), Vector3(0.075, 0.105, 0.026), eye_color, false, true)
	_sphere(face, "EyeSparkleLeft", Vector3(-0.132, 0.062, 0.040), Vector3(0.020, 0.028, 0.010), Color.WHITE, false, true)
	_sphere(face, "EyeSparkleRight", Vector3(0.168, 0.062, 0.040), Vector3(0.020, 0.028, 0.010), Color.WHITE, false, true)
	_sphere(face, "Mouth", Vector3(0.0, -0.105, 0.018), Vector3(0.062, 0.030, 0.016), eye_color, false, true)
	_sphere(face, "CheekLeft", Vector3(-0.255, -0.075, 0.0), Vector3(0.090, 0.038, 0.010), blush_color, false, true)
	_sphere(face, "CheekRight", Vector3(0.255, -0.075, 0.0), Vector3(0.090, 0.038, 0.010), blush_color, false, true)

static func _add_hair(head: Node3D, style: StringName, color: Color) -> void:
	_sphere(head, "HairCap", Vector3(0.0, 0.20, -0.01), Vector3(0.56, 0.22, 0.46), color, true)
	match style:
		&"soft_bangs":
			for side: float in [-1.0, 0.0, 1.0]:
				_sphere(head, "Bang_%s" % side, Vector3(side * 0.15, 0.10, 0.38), Vector3(0.18, 0.21, 0.10), color, true)
		&"leaf_braid":
			for index: int in range(3):
				_sphere(head, "Braid_%d" % index, Vector3(-0.34, 0.06 - float(index) * 0.10, -0.03), Vector3(0.13, 0.17, 0.13), color, true)
		&"side_swoop":
			_sphere(head, "Swoop", Vector3(-0.19, 0.11, 0.36), Vector3(0.32, 0.18, 0.12), color, true)
			_sphere(head, "BackHair", Vector3(0.27, 0.02, -0.03), Vector3(0.17, 0.34, 0.18), color, true)
		&"short_peak":
			_sphere(head, "Peak", Vector3(0.0, 0.34, 0.02), Vector3(0.18, 0.22, 0.18), color, true)
			_sphere(head, "SideHairLeft", Vector3(-0.31, 0.05, -0.01), Vector3(0.13, 0.25, 0.16), color, true)
			_sphere(head, "SideHairRight", Vector3(0.31, 0.05, -0.01), Vector3(0.13, 0.25, 0.16), color, true)
		&"twin_puffs":
			_sphere(head, "PuffLeft", Vector3(-0.40, 0.14, -0.02), Vector3(0.25, 0.26, 0.23), color, true)
			_sphere(head, "PuffRight", Vector3(0.40, 0.14, -0.02), Vector3(0.25, 0.26, 0.23), color, true)
		_:
			_sphere(head, "BobLeft", Vector3(-0.32, 0.02, -0.02), Vector3(0.17, 0.30, 0.18), color, true)
			_sphere(head, "BobRight", Vector3(0.32, 0.02, -0.02), Vector3(0.17, 0.30, 0.18), color, true)

static func _add_accessory(accessory: Node3D, style: StringName, accent: Color, outfit: Color, hair: Color) -> void:
	match style:
		&"straw_hat":
			# A compact brim preserves the farming silhouette without hiding the
			# face in the orthographic, high-angle gameplay camera.
			_cylinder(accessory, "HatBrim", Vector3(0.0, 1.06, -0.14), 0.38, 0.060, Color("ebcd8e"), true)
			_sphere(accessory, "HatCrown", Vector3(0.0, 1.17, -0.12), Vector3(0.43, 0.20, 0.36), Color("ebcd8e"), true)
			_sphere(accessory, "HatLeaf", Vector3(0.23, 1.13, 0.14), Vector3(0.11, 0.07, 0.06), accent, true)
		&"chef_hat":
			_sphere(accessory, "ChefHatBase", Vector3(0.0, 1.05, 0.0), Vector3(0.42, 0.14, 0.34), Color("fff7e8"), true)
			for offset: Vector3 in [Vector3(-0.18, 1.20, 0.0), Vector3(0.0, 1.28, 0.0), Vector3(0.18, 1.20, 0.0)]:
				_sphere(accessory, "ChefPuff_%d" % accessory.get_child_count(), offset, Vector3(0.25, 0.22, 0.22), Color("fff7e8"), true)
		&"tool_belt":
			_cylinder(accessory, "Belt", Vector3(0.0, 0.38, 0.0), 0.29, 0.075, accent, true)
			_box(accessory, "BeltPouch", Vector3(0.0, 0.37, 0.31), Vector3(0.17, 0.15, 0.08), Color("b98762"), true)
			_sphere(accessory, "Pencil", Vector3(0.35, 0.90, 0.10), Vector3(0.035, 0.22, 0.035), Color("edc457"), false)
		&"flower_crown":
			for index: int in range(5):
				var angle: float = TAU * float(index) / 5.0
				_sphere(accessory, "Flower_%d" % index, Vector3(cos(angle) * 0.30, 1.01 + sin(angle) * 0.035, sin(angle) * 0.24), Vector3(0.10, 0.07, 0.10), accent, true)
		&"merchant_pack":
			_sphere(accessory, "Pack", Vector3(0.0, 0.50, -0.30), Vector3(0.34, 0.40, 0.16), hair, true)
			_box(accessory, "PackFlap", Vector3(0.0, 0.56, -0.45), Vector3(0.19, 0.13, 0.025), accent, true)
			_cylinder(accessory, "HatBand", Vector3(0.0, 1.06, 0.0), 0.35, 0.055, accent, true)
			_sphere(accessory, "MerchantHat", Vector3(0.0, 1.15, 0.0), Vector3(0.42, 0.22, 0.36), outfit, true)
		&"red_bandana":
			_box(accessory, "Bandana", Vector3(0.0, 0.38, 0.25), Vector3(0.12, 0.12, 0.03), accent, false)
		_:
			pass

static func _sphere(parent: Node3D, part_name: String, origin: Vector3, dimensions: Vector3, color: Color, outlined: bool, unshaded: bool = false) -> MeshInstance3D:
	var sphere: ArrayMesh = CORE_BUILDER._rounded_mesh(12, 6)
	return _mesh(parent, part_name, sphere, origin, dimensions, color, outlined, unshaded)

static func _cylinder(parent: Node3D, part_name: String, origin: Vector3, radius: float, height: float, color: Color, outlined: bool) -> MeshInstance3D:
	var cylinder: ArrayMesh = CORE_BUILDER._cylinder_mesh(12)
	return _mesh(parent, part_name, cylinder, origin, Vector3(radius * 2.0, height, radius * 2.0), color, outlined, false)

static func _box(parent: Node3D, part_name: String, origin: Vector3, size: Vector3, color: Color, outlined: bool, unshaded: bool = false) -> MeshInstance3D:
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	return _mesh(parent, part_name, box, origin, Vector3.ONE, color, outlined, unshaded)

static func _mesh(parent: Node3D, part_name: String, mesh: Mesh, origin: Vector3, scale_factor: Vector3, color: Color, outlined: bool, unshaded: bool) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = part_name
	instance.mesh = mesh
	instance.position = origin
	instance.scale = scale_factor
	instance.material_override = _material(color, outlined, unshaded)
	parent.add_child(instance)
	return instance

static func _material(color: Color, outlined: bool, unshaded: bool) -> Material:
	if unshaded:
		var face_material: StandardMaterial3D = StandardMaterial3D.new()
		face_material.albedo_color = color
		face_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		face_material.roughness = 1.0
		return face_material
	var material: ShaderMaterial = MATERIAL_FACTORY.create_material(&"toon", &"wood")
	if material.shader != null:
		material.set_shader_parameter(&"base_color", color)
		if outlined:
			var outline: ShaderMaterial = MATERIAL_FACTORY.create_material(&"outline", &"outline")
			if outline.shader != null:
				material.next_pass = outline
		return material
	var fallback: StandardMaterial3D = StandardMaterial3D.new()
	fallback.albedo_color = color
	fallback.roughness = 0.88
	return fallback
