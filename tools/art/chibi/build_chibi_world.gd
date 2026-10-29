## Deterministically writes C3 generated world/building/ambient scenes.
extends SceneTree

const CATALOG_PATH: String = "res://data/art/world/chibi_world_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const MODEL_DIRECTORY: String = "res://assets/generated/models/world"
const BUILDER: Script = preload("res://tools/art/chibi/chibi_world_builder.gd")
const AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")

func _init() -> void:
	call_deferred("_build")

func _build() -> void:
	var errors: PackedStringArray = _ensure_directory(MODEL_DIRECTORY)
	var catalog: Resource = load(CATALOG_PATH) as Resource
	var palette: ArtPalette = load(PALETTE_PATH) as ArtPalette
	if catalog == null:
		errors.append("cannot load C3 world art catalog")
	elif not catalog.has_method(&"validate"):
		errors.append("C3 world art catalog has no validate API")
	elif not (catalog.call(&"validate") as PackedStringArray).is_empty():
		errors.append_array(catalog.call(&"validate") as PackedStringArray)
	if palette == null:
		errors.append("cannot load chibi palette")
	if errors.is_empty() and catalog != null and palette != null:
		for asset_name: String in catalog.get("asset_ids") as PackedStringArray:
			var asset_id: StringName = StringName(asset_name)
			var model: Node3D = BUILDER.build_asset(asset_id, palette) as Node3D
			errors.append_array(_save_model(model, "%s.tscn" % asset_name, _budget_for(catalog.call(&"get_asset_kind", asset_id) as StringName, palette)))
	if errors.is_empty() and catalog != null and palette != null:
		errors.append_array(_write_manifest(catalog, palette))
	if not errors.is_empty():
		for message: String in errors:
			printerr("[build_chibi_world] %s" % message)
		quit(1)
		return
	print("[build_chibi_world] PASS")
	quit(0)

func _ensure_directory(path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	if result != OK:
		errors.append("cannot create directory %s: %s" % [path, error_string(result)])
	return errors

func _save_model(model: Node3D, filename: String, triangle_budget: int) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if model == null:
		errors.append("cannot build model: %s" % filename)
		return errors
	var audit: PackedStringArray = AUDIT.validate_model(model, triangle_budget)
	if not audit.is_empty():
		for message: String in audit:
			errors.append("%s: %s" % [filename, message])
		model.free()
		return errors
	_assign_scene_owners(model, model)
	var packed: PackedScene = PackedScene.new()
	var pack_result: Error = packed.pack(model)
	if pack_result != OK:
		errors.append("cannot pack %s: %s" % [filename, error_string(pack_result)])
	else:
		var save_result: Error = ResourceSaver.save(packed, "%s/%s" % [MODEL_DIRECTORY, filename])
		if save_result != OK:
			errors.append("cannot save %s: %s" % [filename, error_string(save_result)])
	model.free()
	return errors

func _write_manifest(catalog: Resource, palette: ArtPalette) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var entries: Array[Dictionary] = []
	for asset_name: String in catalog.get("asset_ids") as PackedStringArray:
		var asset_id: StringName = StringName(asset_name)
		var path: String = String(catalog.call(&"get_model_path", asset_id))
		var scene: PackedScene = load(path) as PackedScene
		if scene == null:
			errors.append("cannot load generated C3 world model: %s" % path)
			continue
		var model: Node3D = scene.instantiate() as Node3D
		if model == null:
			errors.append("generated C3 world root is not Node3D: %s" % path)
			continue
		entries.append({
			"file": "%s.tscn" % asset_name,
			"kind": String(catalog.call(&"get_asset_kind", asset_id)),
			"role": String(catalog.call(&"get_asset_role", asset_id)),
			"triangles": AUDIT.triangle_count(model),
			"budget": _budget_for(catalog.call(&"get_asset_kind", asset_id) as StringName, palette)
		})
		model.free()
	if not errors.is_empty():
		return errors
	var manifest: FileAccess = FileAccess.open("%s/manifest.json" % MODEL_DIRECTORY, FileAccess.WRITE)
	if manifest == null:
		errors.append("cannot write C3 world manifest")
		return errors
	manifest.store_string(JSON.stringify({"catalog_id": String(catalog.get("catalog_id")), "entries": entries}, "\t"))
	manifest.close()
	return errors

func _budget_for(kind: StringName, palette: ArtPalette) -> int:
	if kind == &"building":
		return palette.get_triangle_budget(&"building")
	if kind == &"tree":
		return palette.get_triangle_budget(&"tree")
	return palette.get_triangle_budget(&"prop")

func _assign_scene_owners(node: Node, scene_root: Node) -> void:
	for child: Node in node.get_children():
		child.owner = scene_root
		_assign_scene_owners(child, scene_root)
