## Deterministically writes C2 crop/item/tool scenes and transparent item stickers.
extends SceneTree

const CATALOG_PATH: String = "res://data/art/farming/chibi_farming_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const MODEL_DIRECTORY: String = "res://assets/generated/models/farming"
const ICON_DIRECTORY: String = "res://assets/generated/icons"
const BUILDER: Script = preload("res://tools/art/chibi/chibi_farming_builder.gd")
const AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")
const ICON_SIZE: int = 128
const TOOL_IDS: Array[String] = ["hoe", "watering_can", "seed", "harvest"]

const CROP_PATHS: Array[String] = [
	"res://data/crops/turnip.tres",
	"res://data/crops/spring_carrot.tres",
	"res://data/crops/spring_pea.tres",
	"res://data/crops/summer_tomato.tres",
	"res://data/crops/summer_corn.tres",
	"res://data/crops/autumn_wheat.tres",
	"res://data/crops/autumn_pumpkin.tres",
	"res://data/crops/winter_radish.tres",
	"res://data/crops/winter_cabbage.tres"
]

const ITEM_PATHS: Array[String] = [
	"res://data/items/turnip_seed.tres", "res://data/items/turnip.tres",
	"res://data/items/spring_carrot_seed.tres", "res://data/items/spring_carrot.tres",
	"res://data/items/spring_pea_seed.tres", "res://data/items/spring_pea.tres",
	"res://data/items/summer_tomato_seed.tres", "res://data/items/summer_tomato.tres",
	"res://data/items/summer_corn_seed.tres", "res://data/items/summer_corn.tres",
	"res://data/items/autumn_wheat_seed.tres", "res://data/items/autumn_wheat.tres",
	"res://data/items/autumn_pumpkin_seed.tres", "res://data/items/autumn_pumpkin.tres",
	"res://data/items/winter_radish_seed.tres", "res://data/items/winter_radish.tres",
	"res://data/items/winter_cabbage_seed.tres", "res://data/items/winter_cabbage.tres"
]

func _init() -> void:
	call_deferred("_build")

func _build() -> void:
	var errors: PackedStringArray = PackedStringArray()
	errors.append_array(_ensure_directory(MODEL_DIRECTORY))
	errors.append_array(_ensure_directory(ICON_DIRECTORY))
	var catalog: FarmingArtCatalog = load(CATALOG_PATH) as FarmingArtCatalog
	var palette: Resource = load(PALETTE_PATH) as Resource
	if catalog == null:
		errors.append("cannot load C2 farming art catalog")
	elif not catalog.validate().is_empty():
		errors.append_array(catalog.validate())
	if palette == null:
		errors.append("cannot load chibi palette")
	if errors.is_empty() and catalog != null and palette != null:
		errors.append_array(_save_crop_models(catalog, palette))
		errors.append_array(_save_item_models(palette))
		errors.append_array(_save_tool_models(catalog, palette))
	if errors.is_empty():
		errors.append_array(await _bake_sticker_icons())
	if errors.is_empty() and catalog != null and palette != null:
		errors.append_array(_write_manifest(catalog, palette))
	if not errors.is_empty():
		for message: String in errors:
			printerr("[build_chibi_farming] %s" % message)
		quit(1)
		return
	print("[build_chibi_farming] PASS")
	quit(0)

func _ensure_directory(path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	if result != OK:
		errors.append("cannot create directory %s: %s" % [path, error_string(result)])
	return errors

func _save_crop_models(catalog: FarmingArtCatalog, palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for crop_path: String in CROP_PATHS:
		var crop: Resource = load(crop_path) as Resource
		if crop == null:
			errors.append("cannot load crop data: %s" % crop_path)
			continue
		var crop_id: StringName = crop.get("crop_id")
		if not catalog.crop_ids.has(String(crop_id)):
			errors.append("crop is absent from C2 catalog: %s" % crop_id)
			continue
		for stage: int in range(4):
			var model: Node3D = BUILDER.build_crop(crop_id, StringName(str(stage)), crop.get("color") as Color, catalog.get_crop_family(crop_id), catalog.get_stage_scale(stage)) as Node3D
			errors.append_array(_save_model(model, "crop_%s_stage_%d.tscn" % [crop_id, stage], int(palette.get_triangle_budget(&"crop"))))
		var wilted: Node3D = BUILDER.build_crop(crop_id, &"withered", crop.get("color") as Color, catalog.get_crop_family(crop_id), 1.0) as Node3D
		errors.append_array(_save_model(wilted, "crop_%s_withered.tscn" % crop_id, int(palette.get_triangle_budget(&"crop"))))
	return errors

func _save_item_models(palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for item_path: String in ITEM_PATHS:
		var item: Resource = load(item_path) as Resource
		if item == null:
			errors.append("cannot load item data: %s" % item_path)
			continue
		var item_id: StringName = item.get("item_id")
		var model: Node3D = BUILDER.build_item(item_id, item.get("color") as Color) as Node3D
		errors.append_array(_save_model(model, "item_%s.tscn" % item_id, int(palette.get_triangle_budget(&"prop"))))
	return errors

func _save_tool_models(catalog: FarmingArtCatalog, palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for tool_name: String in catalog.tool_ids:
		var tool_id: StringName = StringName(tool_name)
		var model: Node3D = BUILDER.build_tool(tool_id) as Node3D
		errors.append_array(_save_model(model, "tool_%s.tscn" % tool_id, int(palette.get_triangle_budget(&"prop"))))
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

func _bake_sticker_icons() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var viewport: SubViewport = _create_icon_viewport()
	get_root().add_child(viewport)
	await process_frame
	var icon_camera: Camera3D = viewport.get_node_or_null("IconCamera") as Camera3D
	if icon_camera == null:
		errors.append("cannot find C2 icon camera")
		viewport.queue_free()
		return errors
	icon_camera.look_at(Vector3(0.0, 0.26, 0.0), Vector3.UP)
	for item_path: String in ITEM_PATHS:
		var item: Resource = load(item_path) as Resource
		if item == null:
			errors.append("cannot load item for icon: %s" % item_path)
			continue
		var item_id: StringName = item.get("item_id")
		var model_path: String = String(item.get("model_path"))
		var icon_path: String = String(item.get("icon_path"))
		var scene: PackedScene = load(model_path) as PackedScene
		if scene == null:
			errors.append("cannot load item model for icon: %s" % model_path)
			continue
		var model: Node3D = scene.instantiate() as Node3D
		if model == null:
			errors.append("item model root is not Node3D: %s" % model_path)
			continue
		model.name = "IconModel_%s" % item_id
		viewport.add_child(model)
		await process_frame
		RenderingServer.force_draw(false)
		await RenderingServer.frame_post_draw
		var source: Image = viewport.get_texture().get_image()
		model.queue_free()
		if source == null or source.is_empty():
			errors.append("empty icon capture; run C2 builder with a graphics renderer")
			continue
		if source.get_format() != Image.FORMAT_RGBA8:
			source.convert(Image.FORMAT_RGBA8)
		var icon: Image = _make_sticker(source)
		if icon.get_size() != Vector2i(ICON_SIZE, ICON_SIZE) or _alpha_count(icon) <= 0:
			errors.append("invalid baked icon for: %s" % item_id)
			continue
		var save_result: Error = icon.save_png(icon_path)
		if save_result != OK:
			errors.append("cannot save item icon %s: %s" % [item_id, error_string(save_result)])
	for tool_id: String in TOOL_IDS:
		var tool_model_path: String = "%s/tool_%s.tscn" % [MODEL_DIRECTORY, tool_id]
		var tool_icon_path: String = "%s/tool_%s.png" % [ICON_DIRECTORY, tool_id]
		var tool_scene: PackedScene = load(tool_model_path) as PackedScene
		if tool_scene == null:
			errors.append("cannot load tool model for icon: %s" % tool_id)
			continue
		var tool_model: Node3D = tool_scene.instantiate() as Node3D
		if tool_model == null:
			errors.append("tool model root is not Node3D: %s" % tool_id)
			continue
		tool_model.name = "IconTool_%s" % tool_id
		viewport.add_child(tool_model)
		await process_frame
		RenderingServer.force_draw(false)
		await RenderingServer.frame_post_draw
		var tool_source: Image = viewport.get_texture().get_image()
		tool_model.queue_free()
		if tool_source == null or tool_source.is_empty():
			errors.append("empty tool icon capture; run C2 builder with a graphics renderer")
			continue
		if tool_source.get_format() != Image.FORMAT_RGBA8:
			tool_source.convert(Image.FORMAT_RGBA8)
		var tool_icon: Image = _make_sticker(tool_source)
		if tool_icon.get_size() != Vector2i(ICON_SIZE, ICON_SIZE) or _alpha_count(tool_icon) <= 0:
			errors.append("invalid baked tool icon for: %s" % tool_id)
			continue
		var tool_save_result: Error = tool_icon.save_png(tool_icon_path)
		if tool_save_result != OK:
			errors.append("cannot save tool icon %s: %s" % [tool_id, error_string(tool_save_result)])
	viewport.queue_free()
	return errors

func _create_icon_viewport() -> SubViewport:
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "FarmingIconViewport"
	viewport.size = Vector2i(ICON_SIZE, ICON_SIZE)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("fff1db")
	environment.ambient_light_energy = 0.85
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_color = Color("fff6e3")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	viewport.add_child(sun)
	var fill: OmniLight3D = OmniLight3D.new()
	fill.position = Vector3(0.0, 1.4, 1.8)
	fill.light_color = Color("d5e8ff")
	fill.light_energy = 0.52
	fill.omni_range = 4.0
	viewport.add_child(fill)
	var camera: Camera3D = Camera3D.new()
	camera.name = "IconCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.25
	camera.near = 0.02
	camera.far = 10.0
	camera.position = Vector3(1.70, 1.45, 1.70)
	camera.current = true
	viewport.add_child(camera)
	return viewport

func _make_sticker(source: Image) -> Image:
	var sticker: Image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	sticker.fill(Color.TRANSPARENT)
	var transparent: Color = Color.TRANSPARENT
	for y: int in range(ICON_SIZE):
		for x: int in range(ICON_SIZE):
			var source_color: Color = source.get_pixel(x, y)
			if source_color.a <= 0.04:
				continue
			for shadow_y: int in range(-1, 3):
				for shadow_x: int in range(-1, 3):
					var shadow_position: Vector2i = Vector2i(x + shadow_x + 2, y + shadow_y + 3)
					if _is_icon_position(shadow_position) and sticker.get_pixelv(shadow_position) == transparent:
						sticker.set_pixelv(shadow_position, Color(0.25, 0.20, 0.28, 0.24))
	for y: int in range(ICON_SIZE):
		for x: int in range(ICON_SIZE):
			var source_color: Color = source.get_pixel(x, y)
			if source_color.a <= 0.04:
				continue
			for outline_y: int in range(-2, 3):
				for outline_x: int in range(-2, 3):
					var outline_position: Vector2i = Vector2i(x + outline_x, y + outline_y)
					if _is_icon_position(outline_position) and sticker.get_pixelv(outline_position).a <= 0.01:
						sticker.set_pixelv(outline_position, Color("fffdf4"))
			sticker.set_pixel(x, y, source_color)
	return sticker

func _is_icon_position(position: Vector2i) -> bool:
	return position.x >= 0 and position.y >= 0 and position.x < ICON_SIZE and position.y < ICON_SIZE

func _alpha_count(image: Image) -> int:
	var count: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.04:
				count += 1
	return count

func _write_manifest(catalog: FarmingArtCatalog, palette: Resource) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var entries: Array[Dictionary] = []
	for crop_id: String in catalog.crop_ids:
		for stage: int in range(4):
			entries.append(_manifest_entry("crop_%s_stage_%d.tscn" % [crop_id, stage], &"crop", int(palette.get_triangle_budget(&"crop"))))
		entries.append(_manifest_entry("crop_%s_withered.tscn" % crop_id, &"crop", int(palette.get_triangle_budget(&"crop"))))
	for item_path: String in ITEM_PATHS:
		var item: Resource = load(item_path) as Resource
		if item != null:
			entries.append(_manifest_entry("item_%s.tscn" % item.get("item_id"), &"item", int(palette.get_triangle_budget(&"prop"))))
	for tool_name: String in catalog.tool_ids:
		entries.append(_manifest_entry("tool_%s.tscn" % tool_name, &"tool", int(palette.get_triangle_budget(&"prop"))))
	for entry: Dictionary in entries:
		if String(entry.get("error", "")).is_empty():
			continue
		errors.append(String(entry["error"]))
	if not errors.is_empty():
		return errors
	var manifest: FileAccess = FileAccess.open("%s/manifest.json" % MODEL_DIRECTORY, FileAccess.WRITE)
	if manifest == null:
		errors.append("cannot write C2 farming manifest")
		return errors
	manifest.store_string(JSON.stringify({"catalog_id": String(catalog.catalog_id), "entries": entries}, "\t"))
	manifest.close()
	return errors

func _manifest_entry(filename: String, kind: StringName, budget: int) -> Dictionary:
	var path: String = "%s/%s" % [MODEL_DIRECTORY, filename]
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		return {"error": "cannot load generated farming model: %s" % path}
	var model: Node3D = scene.instantiate() as Node3D
	if model == null:
		return {"error": "generated farming root is not Node3D: %s" % path}
	var entry: Dictionary = {
		"file": filename,
		"kind": String(kind),
		"triangles": AUDIT.triangle_count(model),
		"budget": budget
	}
	model.free()
	return entry

func _assign_scene_owners(node: Node, scene_root: Node) -> void:
	for child: Node in node.get_children():
		child.owner = scene_root
		_assign_scene_owners(child, scene_root)
