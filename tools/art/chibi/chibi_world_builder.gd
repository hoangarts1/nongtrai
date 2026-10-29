## ChibiWorldBuilder -- deterministic original C3 world, building and ambience models.
## API:
##   static func build_asset(asset_id: StringName, palette: ArtPalette) -> Node3D
class_name ChibiWorldBuilder
extends RefCounted

const CORE_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")

static func build_asset(asset_id: StringName, palette: ArtPalette) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = String(asset_id).to_pascal_case()
	root.set_meta("asset_id", asset_id)
	root.set_meta("art_kind", _kind_for(asset_id))
	match asset_id:
		&"bld_player_cottage":
			_build_player_cottage(root, palette)
		&"bld_seed_market":
			_build_seed_market(root, palette)
		&"bld_shipping_bin":
			_build_shipping_bin(root, palette)
		&"bld_npc_cottage":
			_build_npc_cottage(root, palette)
		&"bld_observatory":
			_build_observatory(root, palette)
		&"env_round_tree":
			_build_round_tree(root, palette)
		&"env_cliff_border":
			_build_cliff_border(root, palette)
		&"env_pond_bridge":
			_build_pond_bridge(root, palette)
		&"prop_fence_wood":
			_build_fence(root, palette)
		&"prop_path_stone":
			_build_path_stone(root, palette)
		&"prop_well":
			_build_well(root, palette)
		&"prop_lamp":
			_build_lamp(root, palette)
		&"prop_mailbox":
			_build_mailbox(root, palette)
		&"prop_signpost":
			_build_signpost(root, palette)
		&"prop_bench":
			_build_bench(root, palette)
		&"prop_woodpile":
			_build_woodpile(root, palette)
		&"prop_flower_patch":
			_build_flower_patch(root, palette)
		&"prop_rock_cluster":
			_build_rock_cluster(root, palette)
		&"env_bird":
			_build_bird(root, palette)
		&"env_butterfly":
			_build_butterfly(root, palette)
		&"env_firefly":
			_build_firefly(root, palette)
		_:
			_sphere(root, "Fallback", Vector3(0.0, 0.25, 0.0), Vector3(0.50, 0.50, 0.50), palette.get_color(&"ui_accent"), &"ui_accent")
	return root

static func _build_player_cottage(root: Node3D, palette: ArtPalette) -> void:
	var wall: Color = Color("f3dfb8")
	_sphere(root, "CottageWalls", Vector3(0.0, 1.08, 0.0), Vector3(3.35, 2.16, 2.62), wall, &"wood", true)
	_sphere(root, "CottageRoof", Vector3(0.0, 2.34, -0.06), Vector3(3.88, 0.92, 3.14), palette.get_color(&"roof"), &"roof", true)
	_box(root, "Door", Vector3(0.0, 0.63, 1.33), Vector3(0.62, 1.24, 0.10), Color("875b43"), &"wood", true)
	_box(root, "DoorKnob", Vector3(0.22, 0.66, 1.40), Vector3(0.08, 0.08, 0.05), palette.get_color(&"sunlight"), &"sunlight")
	for side: float in [-1.0, 1.0]:
		_sphere(root, "Window%s" % _side_name(side), Vector3(side * 1.03, 1.13, 1.29), Vector3(0.48, 0.45, 0.11), palette.get_color(&"water"), &"water")
		_box(root, "WindowFrame%s" % _side_name(side), Vector3(side * 1.03, 1.13, 1.37), Vector3(0.09, 0.60, 0.06), Color("fff2bb"), &"sunlight")
	_box(root, "Chimney", Vector3(-1.15, 2.88, -0.42), Vector3(0.38, 1.10, 0.38), Color("a97862"), &"stone", true)
	_box(root, "Porch", Vector3(0.0, 0.10, 1.55), Vector3(1.62, 0.20, 0.68), Color("c69264"), &"wood")
	for side: float in [-1.0, 1.0]:
		_box(root, "PorchRail%s" % _side_name(side), Vector3(side * 0.69, 0.42, 1.74), Vector3(0.07, 0.55, 0.07), Color("9b704f"), &"wood")
	_add_flower_box(root, "CottageFlowerBoxLeft", Vector3(-1.12, 0.55, 1.48), palette)
	_add_flower_box(root, "CottageFlowerBoxRight", Vector3(1.12, 0.55, 1.48), palette)

static func _build_seed_market(root: Node3D, palette: ArtPalette) -> void:
	_box(root, "MarketCounter", Vector3(0.0, 0.42, 0.0), Vector3(2.28, 0.84, 1.26), Color("bd8e5d"), &"wood", true)
	for side: float in [-1.0, 1.0]:
		_cylinder(root, "MarketPost%s" % _side_name(side), Vector3(side * 0.92, 1.25, -0.43), 0.075, 2.50, Color("80583f"), &"wood", true)
	_sphere(root, "MarketRoof", Vector3(0.0, 2.39, -0.04), Vector3(2.70, 0.66, 1.75), palette.get_color(&"ui_accent"), &"ui_accent", true)
	for stripe: int in range(5):
		var stripe_color: Color = Color("fff0c9") if stripe % 2 == 0 else Color("83ae70")
		_box(root, "AwningStripe%d" % stripe, Vector3(-0.86 + float(stripe) * 0.43, 1.78, 0.56), Vector3(0.31, 0.10, 1.12), stripe_color, &"sunlight")
	for index: int in range(3):
		var x: float = -0.58 + float(index) * 0.58
		_box(root, "SeedCrate%d" % index, Vector3(x, 0.73, 0.43), Vector3(0.43, 0.28, 0.34), Color("d1a46c"), &"wood")
		_sphere(root, "SeedBag%d" % index, Vector3(x, 0.98, 0.43), Vector3(0.25, 0.22, 0.20), [Color("e7a84d"), Color("86b776"), Color("df8571")][index], &"ui_accent")
	_box(root, "MarketSign", Vector3(0.0, 1.58, 0.91), Vector3(1.02, 0.38, 0.08), palette.get_color(&"sunlight"), &"sunlight", true)

static func _build_shipping_bin(root: Node3D, palette: ArtPalette) -> void:
	_box(root, "BinBody", Vector3(0.0, 0.42, 0.0), Vector3(1.32, 0.84, 1.02), Color("a97750"), &"wood", true)
	_sphere(root, "BinLid", Vector3(0.0, 0.90, 0.0), Vector3(1.45, 0.25, 1.12), Color("dabb89"), &"wood", true)
	_box(root, "BinHandle", Vector3(0.0, 0.72, 0.57), Vector3(0.30, 0.22, 0.07), palette.get_color(&"sunlight"), &"sunlight")
	for side: float in [-1.0, 1.0]:
		_box(root, "BinBand%s" % _side_name(side), Vector3(side * 0.48, 0.42, 0.53), Vector3(0.10, 0.64, 0.06), Color("825a42"), &"wood")

static func _build_npc_cottage(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "CottageWalls", Vector3(0.0, 0.87, 0.0), Vector3(2.48, 1.74, 2.16), Color("e3d4ad"), &"wood", true)
	_sphere(root, "CottageRoof", Vector3(0.0, 1.91, -0.04), Vector3(2.84, 0.72, 2.55), palette.get_color(&"roof").darkened(0.10), &"roof", true)
	_box(root, "Door", Vector3(0.0, 0.48, 1.10), Vector3(0.46, 0.96, 0.08), Color("845a42"), &"wood")
	for side: float in [-1.0, 1.0]:
		_sphere(root, "Window%s" % _side_name(side), Vector3(side * 0.72, 0.91, 1.08), Vector3(0.32, 0.31, 0.08), palette.get_color(&"water"), &"water")
	_box(root, "Chimney", Vector3(-0.82, 2.35, -0.35), Vector3(0.28, 0.78, 0.28), Color("a97862"), &"stone")
	_box(root, "Doorstep", Vector3(0.0, 0.07, 1.24), Vector3(0.82, 0.14, 0.34), palette.get_color(&"wood"), &"wood")

static func _build_observatory(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "ObservatoryBase", Vector3(0.0, 0.55, 0.0), 1.35, 1.10, Color("b3a6be"), &"stone", true)
	_sphere(root, "ObservatoryDome", Vector3(0.0, 1.53, 0.0), Vector3(2.35, 1.72, 2.35), Color("8f8ab4"), &"roof", true)
	_box(root, "ObservatoryDoor", Vector3(0.0, 0.47, 1.34), Vector3(0.46, 0.94, 0.08), Color("594e74"), &"outline")
	_cylinder(root, "Telescope", Vector3(0.42, 2.45, 0.05), 0.15, 1.35, palette.get_color(&"sunlight"), &"sunlight")
	var telescope: MeshInstance3D = root.get_node("Telescope") as MeshInstance3D
	if telescope != null:
		telescope.rotation.z = -0.72
	_sphere(root, "StarLight", Vector3(-0.54, 2.15, 1.02), Vector3(0.17, 0.17, 0.08), palette.get_color(&"sunlight"), &"sunlight")

static func _build_round_tree(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "TreeTrunk", Vector3(0.0, 0.80, 0.0), 0.17, 1.60, Color("a77a56"), &"wood", true)
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0
		var crown_position: Vector3 = Vector3(cos(angle) * 0.42, 1.82 + float(index % 2) * 0.20, sin(angle) * 0.32)
		_sphere(root, "TreeCrown%d" % index, crown_position, Vector3(1.12, 1.06, 0.98), palette.get_color(&"foliage").lightened(float(index % 2) * 0.05), &"foliage")
	_sphere(root, "TreeTop", Vector3(0.0, 2.45, -0.06), Vector3(1.06, 0.94, 0.98), palette.get_color(&"foliage").lightened(0.10), &"foliage")
	for index: int in range(3):
		var fruit_angle: float = TAU * float(index) / 3.0
		_sphere(root, "TreeBloom%d" % index, Vector3(cos(fruit_angle) * 0.58, 2.00 + float(index % 2) * 0.22, sin(fruit_angle) * 0.52), Vector3(0.13, 0.13, 0.13), Color("f1a7a4"), &"ui_accent")

static func _build_cliff_border(root: Node3D, palette: ArtPalette) -> void:
	for index: int in range(3):
		var x: float = -0.75 + float(index) * 0.75
		var height: float = 0.68 + float(index % 2) * 0.22
		_sphere(root, "CliffStone%d" % index, Vector3(x, height * 0.50, 0.08 * float(index % 2)), Vector3(1.08, height, 0.88), palette.get_color(&"stone").darkened(float(index) * 0.05), &"stone", true)
		_sphere(root, "CliffMoss%d" % index, Vector3(x - 0.10, height + 0.04, 0.16), Vector3(0.52, 0.16, 0.36), palette.get_color(&"foliage"), &"foliage")

static func _build_pond_bridge(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "PondWater", Vector3(0.0, 0.055, 0.0), Vector3(3.92, 0.11, 2.72), palette.get_color(&"water"), &"water")
	for index: int in range(7):
		var x: float = -1.26 + float(index) * 0.42
		_box(root, "BridgePlank%d" % index, Vector3(x, 0.22, 0.0), Vector3(0.34, 0.14, 1.72), Color("b8885b"), &"wood", true)
	for side: float in [-1.0, 1.0]:
		_cylinder(root, "BridgeRail%s" % _side_name(side), Vector3(side * 1.55, 0.64, 0.0), 0.05, 1.85, Color("8b6246"), &"wood")
		var rail: MeshInstance3D = root.get_node("BridgeRail%s" % _side_name(side)) as MeshInstance3D
		if rail != null:
			rail.rotation.x = PI * 0.50

static func _build_fence(root: Node3D, palette: ArtPalette) -> void:
	for side: float in [-1.0, 1.0]:
		_cylinder(root, "FencePost%s" % _side_name(side), Vector3(side * 0.66, 0.48, 0.0), 0.07, 0.96, Color("986b49"), &"wood")
	for index: int in range(2):
		_box(root, "FenceRail%d" % index, Vector3(0.0, 0.35 + float(index) * 0.31, 0.0), Vector3(1.50, 0.075, 0.08), Color("bd8c60"), &"wood")

static func _build_path_stone(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "PathStone", Vector3(0.0, 0.075, 0.0), Vector3(0.78, 0.15, 0.60), palette.get_color(&"stone").lightened(0.11), &"stone", true)
	_sphere(root, "PathMoss", Vector3(-0.12, 0.16, 0.10), Vector3(0.22, 0.035, 0.14), palette.get_color(&"foliage"), &"foliage")

static func _build_well(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "WellBase", Vector3(0.0, 0.32, 0.0), 0.78, 0.64, palette.get_color(&"stone"), &"stone", true)
	_cylinder(root, "WellWater", Vector3(0.0, 0.66, 0.0), 0.52, 0.055, palette.get_color(&"water"), &"water")
	for side: float in [-1.0, 1.0]:
		_cylinder(root, "WellPost%s" % _side_name(side), Vector3(side * 0.60, 1.24, 0.0), 0.06, 1.42, Color("9a704d"), &"wood")
	_sphere(root, "WellRoof", Vector3(0.0, 2.00, 0.0), Vector3(1.62, 0.44, 1.22), palette.get_color(&"roof"), &"roof", true)

static func _build_lamp(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "LampPost", Vector3(0.0, 0.78, 0.0), 0.055, 1.56, Color("724f45"), &"wood")
	_sphere(root, "LampTop", Vector3(0.0, 1.64, 0.0), Vector3(0.42, 0.30, 0.42), Color("795e67"), &"roof", true)
	_sphere(root, "LampGlow", Vector3(0.0, 1.55, 0.16), Vector3(0.20, 0.20, 0.10), palette.get_color(&"sunlight"), &"sunlight")

static func _build_mailbox(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "MailboxPost", Vector3(0.0, 0.43, 0.0), 0.055, 0.86, Color("875b43"), &"wood")
	_sphere(root, "MailboxBox", Vector3(0.0, 0.95, 0.0), Vector3(0.78, 0.46, 0.58), palette.get_color(&"ui_accent"), &"ui_accent", true)
	_box(root, "MailboxFlag", Vector3(0.34, 1.14, 0.31), Vector3(0.06, 0.38, 0.04), Color("ffe8a3"), &"sunlight")

static func _build_signpost(root: Node3D, palette: ArtPalette) -> void:
	_cylinder(root, "SignPost", Vector3(0.0, 0.64, 0.0), 0.06, 1.28, Color("875b43"), &"wood")
	_box(root, "SignArrowLeft", Vector3(-0.35, 1.10, 0.0), Vector3(0.82, 0.23, 0.08), Color("d5aa71"), &"wood", true)
	_box(root, "SignArrowRight", Vector3(0.35, 0.84, 0.0), Vector3(0.82, 0.23, 0.08), Color("e4c184"), &"wood", true)
	_sphere(root, "SignFlower", Vector3(0.0, 0.18, 0.10), Vector3(0.18, 0.18, 0.14), palette.get_color(&"ui_accent"), &"ui_accent")

static func _build_bench(root: Node3D, palette: ArtPalette) -> void:
	for index: int in range(2):
		_box(root, "BenchSeat%d" % index, Vector3(0.0, 0.49 + float(index) * 0.15, 0.0), Vector3(1.32, 0.11, 0.34), Color("bd8a5f"), &"wood")
	for side: float in [-1.0, 1.0]:
		_box(root, "BenchLeg%s" % _side_name(side), Vector3(side * 0.48, 0.22, 0.0), Vector3(0.10, 0.44, 0.22), Color("815b43"), &"wood")
	_box(root, "BenchBack", Vector3(0.0, 0.82, -0.18), Vector3(1.32, 0.42, 0.09), Color("c49164"), &"wood")

static func _build_woodpile(root: Node3D, palette: ArtPalette) -> void:
	for row: int in range(2):
		for index: int in range(3):
			var log: MeshInstance3D = _cylinder(root, "WoodLog%d_%d" % [row, index], Vector3(-0.38 + float(index) * 0.38, 0.17 + float(row) * 0.28, 0.0), 0.13, 0.72, Color("a26e4c").lightened(float(row) * 0.06), &"wood")
			log.rotation.z = PI * 0.50
	_sphere(root, "WoodpileMoss", Vector3(0.0, 0.56, 0.15), Vector3(0.44, 0.08, 0.18), palette.get_color(&"foliage"), &"foliage")

static func _build_flower_patch(root: Node3D, palette: ArtPalette) -> void:
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0
		var position: Vector3 = Vector3(cos(angle) * 0.36, 0.09, sin(angle) * 0.27)
		_sphere(root, "FlowerLeaf%d" % index, position, Vector3(0.25, 0.15, 0.16), palette.get_color(&"foliage"), &"foliage")
		_sphere(root, "FlowerBloom%d" % index, position + Vector3(0.03, 0.15, 0.02), Vector3(0.12, 0.12, 0.10), Color("f3a5b8") if index % 2 == 0 else Color("f6d071"), &"ui_accent")

static func _build_rock_cluster(root: Node3D, palette: ArtPalette) -> void:
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + 0.25
		var radius: float = 0.28 + float(index) * 0.08
		_sphere(root, "Stone%d" % index, Vector3(cos(angle) * 0.36, radius * 0.56, sin(angle) * 0.30), Vector3(radius * 1.65, radius * 1.10, radius * 1.35), palette.get_color(&"stone").darkened(float(index) * 0.05), &"stone", true)
	_sphere(root, "Moss", Vector3(-0.08, 0.30, 0.05), Vector3(0.44, 0.09, 0.30), palette.get_color(&"foliage"), &"foliage")

static func _build_bird(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "BirdBody", Vector3(0.0, 0.24, 0.0), Vector3(0.42, 0.28, 0.34), Color("f7efd3"), &"sunlight")
	_sphere(root, "BirdWingLeft", Vector3(-0.22, 0.30, 0.0), Vector3(0.36, 0.09, 0.22), palette.get_color(&"foliage"), &"foliage")
	_sphere(root, "BirdWingRight", Vector3(0.22, 0.30, 0.0), Vector3(0.36, 0.09, 0.22), palette.get_color(&"foliage"), &"foliage")
	_sphere(root, "BirdBeak", Vector3(0.0, 0.24, 0.20), Vector3(0.08, 0.07, 0.16), Color("f0b45f"), &"ui_accent")

static func _build_butterfly(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "ButterflyBody", Vector3(0.0, 0.19, 0.0), Vector3(0.08, 0.38, 0.08), Color("745a54"), &"outline")
	_sphere(root, "ButterflyWingLeft", Vector3(-0.18, 0.26, 0.0), Vector3(0.33, 0.35, 0.08), Color("f4a7be"), &"ui_accent")
	_sphere(root, "ButterflyWingRight", Vector3(0.18, 0.26, 0.0), Vector3(0.33, 0.35, 0.08), Color("f3cb74"), &"ui_accent")

static func _build_firefly(root: Node3D, palette: ArtPalette) -> void:
	_sphere(root, "FireflyBody", Vector3(0.0, 0.11, 0.0), Vector3(0.13, 0.18, 0.13), Color("57484d"), &"outline")
	_sphere(root, "FireflyGlow", Vector3(0.0, 0.14, 0.08), Vector3(0.10, 0.10, 0.05), palette.get_color(&"sunlight"), &"sunlight")
	_sphere(root, "FireflyWingLeft", Vector3(-0.10, 0.18, 0.0), Vector3(0.13, 0.07, 0.04), palette.get_color(&"water").lightened(0.30), &"water")
	_sphere(root, "FireflyWingRight", Vector3(0.10, 0.18, 0.0), Vector3(0.13, 0.07, 0.04), palette.get_color(&"water").lightened(0.30), &"water")

static func _add_flower_box(root: Node3D, name_prefix: String, origin: Vector3, palette: ArtPalette) -> void:
	_box(root, name_prefix, origin, Vector3(0.44, 0.16, 0.18), Color("ba8057"), &"wood")
	for index: int in range(2):
		_sphere(root, "%sBloom%d" % [name_prefix, index], origin + Vector3(-0.12 + float(index) * 0.24, 0.15, 0.03), Vector3(0.14, 0.16, 0.12), palette.get_color(&"ui_accent").lightened(float(index) * 0.12), &"ui_accent")

static func _sphere(parent: Node3D, part_name: String, origin: Vector3, dimensions: Vector3, color: Color, role: StringName, outlined: bool = false) -> MeshInstance3D:
	var shader_id: StringName = &"foliage" if role == &"foliage" else (&"water" if role == &"water" else &"toon")
	var instance: MeshInstance3D = CORE_BUILDER._sphere(parent, part_name, origin, dimensions, color, 10, 4, shader_id, outlined) as MeshInstance3D
	instance.set_meta("art_role", role)
	return instance

static func _cylinder(parent: Node3D, part_name: String, origin: Vector3, radius: float, height: float, color: Color, role: StringName, outlined: bool = false) -> MeshInstance3D:
	var instance: MeshInstance3D = CORE_BUILDER._cylinder(parent, part_name, origin, radius, height, color, 10, 4, &"toon", outlined) as MeshInstance3D
	instance.set_meta("art_role", role)
	return instance

static func _box(parent: Node3D, part_name: String, origin: Vector3, size: Vector3, color: Color, role: StringName, outlined: bool = false) -> MeshInstance3D:
	var instance: MeshInstance3D = CORE_BUILDER._box(parent, part_name, origin, size, color, &"toon", outlined) as MeshInstance3D
	instance.set_meta("art_role", role)
	return instance

static func _kind_for(asset_id: StringName) -> StringName:
	if String(asset_id).begins_with("bld_"):
		return &"building"
	if asset_id == &"env_round_tree":
		return &"tree"
	if String(asset_id).begins_with("env_bird") or String(asset_id).begins_with("env_butterfly") or String(asset_id).begins_with("env_firefly"):
		return &"critter"
	return &"prop"

static func _side_name(side: float) -> String:
	return "Left" if side < 0.0 else "Right"
