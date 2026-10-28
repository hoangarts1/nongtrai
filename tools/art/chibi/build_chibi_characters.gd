## Deterministically writes C1 character model scenes from the character catalogue.
extends SceneTree

const CATALOG_PATH: String = "res://data/art/characters/chibi_character_catalog.tres"
const OUTPUT_DIRECTORY: String = "res://assets/generated/models/characters"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const BUILDER: Script = preload("res://tools/art/chibi/chibi_character_builder.gd")
const AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")

func _init() -> void:
	call_deferred("_build")

func _build() -> void:
	var errors: PackedStringArray = PackedStringArray()
	var directory_result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if directory_result != OK:
		errors.append("cannot create character output directory: %s" % error_string(directory_result))
	var palette: Resource = load(PALETTE_PATH) as Resource
	var catalog: Resource = load(CATALOG_PATH) as Resource
	if palette == null:
		errors.append("cannot load chibi palette")
	if catalog == null:
		errors.append("cannot load character catalogue")
	elif not catalog.has_method("validate"):
		errors.append("character catalogue has no validate API")
	elif not (catalog.call("validate") as PackedStringArray).is_empty():
		errors.append_array(catalog.call("validate") as PackedStringArray)
	if errors.is_empty() and catalog != null and palette != null:
		errors.append_array(_save_models(catalog, palette))
	if errors.is_empty() and catalog != null and palette != null:
		errors.append_array(_write_manifest(catalog, palette))
	if not errors.is_empty():
		for message: String in errors:
			printerr("[build_chibi_characters] %s" % message)
		quit(1)
		return
	print("[build_chibi_characters] PASS")
	quit(0)

func _save_models(catalog: Resource, palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var definitions: Array[Dictionary] = [
		{"file": "chr_player_base.tscn", "appearance": catalog.call("get_default_player_appearance"), "dog": false},
		{"file": "chr_an.tscn", "appearance": catalog.call("get_npc_appearance", &"an"), "dog": false},
		{"file": "chr_lam.tscn", "appearance": catalog.call("get_npc_appearance", &"lam"), "dog": false},
		{"file": "chr_linh.tscn", "appearance": catalog.call("get_npc_appearance", &"linh"), "dog": false},
		{"file": "chr_minh.tscn", "appearance": catalog.call("get_npc_appearance", &"minh"), "dog": false},
		{"file": "pet_dog.tscn", "appearance": catalog.get("pet_appearance"), "dog": true}
	]
	for definition: Dictionary in definitions:
		var appearance: Resource = definition["appearance"] as Resource
		if appearance == null:
			errors.append("missing appearance for generated model: %s" % definition["file"])
			continue
		var profile: Dictionary = appearance.call("to_builder_dictionary") as Dictionary
		var model: Node3D = BUILDER.build_dog(profile) if bool(definition["dog"]) else BUILDER.build_character(profile)
		var audit: PackedStringArray = AUDIT.validate_model(model, palette.get_triangle_budget(&"character"))
		if not audit.is_empty():
			for message: String in audit:
				errors.append("%s: %s" % [definition["file"], message])
			model.free()
			continue
		_assign_scene_owners(model, model)
		var scene: PackedScene = PackedScene.new()
		var pack_result: Error = scene.pack(model)
		if pack_result != OK:
			errors.append("cannot pack %s: %s" % [definition["file"], error_string(pack_result)])
			model.free()
			continue
		var save_result: Error = ResourceSaver.save(scene, "%s/%s" % [OUTPUT_DIRECTORY, definition["file"]])
		if save_result != OK:
			errors.append("cannot save %s: %s" % [definition["file"], error_string(save_result)])
		model.free()
	return errors

func _write_manifest(catalog: Resource, palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var entries: Array[Dictionary] = []
	for filename: String in ["chr_player_base.tscn", "chr_an.tscn", "chr_lam.tscn", "chr_linh.tscn", "chr_minh.tscn", "pet_dog.tscn"]:
		var scene: PackedScene = load("%s/%s" % [OUTPUT_DIRECTORY, filename]) as PackedScene
		if scene == null:
			errors.append("cannot load generated character model: %s" % filename)
			continue
		var model: Node3D = scene.instantiate() as Node3D
		entries.append({
			"file": filename,
			"triangles": AUDIT.triangle_count(model),
			"budget": palette.get_triangle_budget(&"character"),
			"appearance_id": String(model.get_meta("appearance_id", &""))
		})
		model.free()
	if errors.is_empty():
		var manifest: FileAccess = FileAccess.open("%s/manifest.json" % OUTPUT_DIRECTORY, FileAccess.WRITE)
		if manifest == null:
			errors.append("cannot write character model manifest")
		else:
			manifest.store_string(JSON.stringify({"catalog_id": String(catalog.get("catalog_id")), "entries": entries}, "\t"))
			manifest.close()
	return errors

func _assign_scene_owners(node: Node, scene_root: Node) -> void:
	for child: Node in node.get_children():
		child.owner = scene_root
		_assign_scene_owners(child, scene_root)
