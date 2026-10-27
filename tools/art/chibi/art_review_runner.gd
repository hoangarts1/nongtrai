## Renders the C0 calibration lineup into day/night, four-angle contact sheets.
extends SceneTree

const LINEUP_SCENE: PackedScene = preload("res://tools/art_lineup.tscn")
const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")
const OUTPUT_DIRECTORY: String = "res://screenshots/chibi-core"
const TILE_SIZE: int = 512

func _init() -> void:
	call_deferred("_capture_review")

func _capture_review() -> void:
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if result != OK:
		printerr("[art_review] cannot create output directory: %s" % error_string(result))
		quit(1)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "ArtReviewViewport"
	viewport.size = Vector2i(TILE_SIZE, TILE_SIZE)
	viewport.transparent_bg = false
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	viewport.add_child(lineup)
	var overlay: CanvasLayer = CanvasLayer.new()
	overlay.layer = 2
	viewport.add_child(overlay)
	var caption: Label = Label.new()
	caption.position = Vector2(16.0, 12.0)
	caption.size = Vector2(480.0, 42.0)
	caption.add_theme_font_size_override(&"font_size", 22)
	caption.add_theme_color_override(&"font_color", Color("4b3c47"))
	caption.add_theme_color_override(&"font_outline_color", Color("fff8e8"))
	caption.add_theme_constant_override(&"outline_size", 5)
	overlay.add_child(caption)
	await process_frame
	await RenderingServer.frame_post_draw
	var sheet_names: Array[String] = ["chibi_core_contact_sheet.png"]
	lineup.set_focus_model(&"")
	if not await _capture_sheet(viewport, lineup, caption, "C0 LINEUP", "chibi_core_contact_sheet.png"):
		viewport.queue_free()
		quit(1)
		return
	for model_name: StringName in _model_names():
		lineup.set_focus_model(model_name)
		var filename: String = "chibi_core_%s_contact_sheet.png" % String(model_name).to_snake_case()
		if not await _capture_sheet(viewport, lineup, caption, String(model_name).to_upper(), filename):
			viewport.queue_free()
			quit(1)
			return
		sheet_names.append(filename)
	var manifest: FileAccess = FileAccess.open("%s/chibi_core_contact_sheet.json" % OUTPUT_DIRECTORY, FileAccess.WRITE)
	if manifest != null:
		manifest.store_string(JSON.stringify({"tile_size": TILE_SIZE, "angles": REVIEW_LAYOUT.ANGLE_COUNT, "lighting": ["day", "night"], "lineup": "res://tools/art_lineup.tscn", "sheets": sheet_names}, "\t"))
		manifest.close()
	viewport.queue_free()
	print("[art_review] wrote %d contact sheets under %s" % [sheet_names.size(), OUTPUT_DIRECTORY])
	quit(0)

func _capture_sheet(viewport: SubViewport, lineup: Node3D, caption: Label, review_name: String, filename: String) -> bool:
	var sheet_size: Vector2i = REVIEW_LAYOUT.sheet_size(TILE_SIZE)
	var sheet: Image = Image.create(sheet_size.x, sheet_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	for lighting_index: int in range(2):
		var night: bool = lighting_index == 1
		for view_index: int in range(REVIEW_LAYOUT.ANGLE_COUNT):
			lineup.set_review_view(view_index, night)
			caption.text = "%s  •  %s  •  %03d°" % [review_name, "NIGHT" if night else "DAY", 45 + view_index * 90]
			await process_frame
			RenderingServer.force_draw(false)
			await RenderingServer.frame_post_draw
			var frame: Image = viewport.get_texture().get_image()
			if frame == null or frame.is_empty():
				printerr("[art_review] contact capture is empty; run this tool with a graphics renderer, not --headless")
				return false
			if frame.get_format() != Image.FORMAT_RGBA8:
				frame.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), REVIEW_LAYOUT.tile_origin(view_index, night, TILE_SIZE))
	var output_path: String = "%s/%s" % [OUTPUT_DIRECTORY, filename]
	var save_result: Error = sheet.save_png(output_path)
	if save_result != OK:
		printerr("[art_review] cannot save contact sheet: %s" % error_string(save_result))
		return false
	return true

func _model_names() -> PackedStringArray:
	return PackedStringArray(["Character", "Prop", "Crop", "Building", "Tree"])
