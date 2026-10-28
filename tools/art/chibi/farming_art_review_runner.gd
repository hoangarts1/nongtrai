## Renders C2 farm art contact sheets with four angles and day/night lighting.
extends SceneTree

const LINEUP_SCENE: PackedScene = preload("res://tools/farming_art_lineup.tscn")
const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")
const OUTPUT_DIRECTORY: String = "res://screenshots/chibi-farming"
const TILE_SIZE: int = 384

func _init() -> void:
	call_deferred("_capture_review")

func _capture_review() -> void:
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if result != OK:
		printerr("[farming_art_review] cannot create output directory: %s" % error_string(result))
		quit(1)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "FarmingReviewViewport"
	viewport.size = Vector2i(TILE_SIZE, TILE_SIZE)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	if lineup == null:
		printerr("[farming_art_review] cannot instantiate farming art lineup")
		viewport.queue_free()
		quit(1)
		return
	viewport.add_child(lineup)
	var overlay: CanvasLayer = CanvasLayer.new()
	overlay.layer = 2
	viewport.add_child(overlay)
	var caption: Label = Label.new()
	caption.position = Vector2(12.0, 8.0)
	caption.size = Vector2(360.0, 48.0)
	caption.add_theme_font_size_override(&"font_size", 14)
	caption.add_theme_color_override(&"font_color", Color("4b3c47"))
	caption.add_theme_color_override(&"font_outline_color", Color("fff8e8"))
	caption.add_theme_constant_override(&"outline_size", 3)
	overlay.add_child(caption)
	await process_frame
	await RenderingServer.frame_post_draw
	if not String(lineup.get("last_error")).is_empty():
		printerr("[farming_art_review] %s" % lineup.get("last_error"))
		viewport.queue_free()
		quit(1)
		return
	var sheet_names: Array[String] = []
	for group_id: StringName in lineup.call("get_review_group_ids") as PackedStringArray:
		lineup.call("set_focus_group", group_id)
		if not String(lineup.get("last_error")).is_empty():
			printerr("[farming_art_review] %s" % lineup.get("last_error"))
			viewport.queue_free()
			quit(1)
			return
		var filename: String = "chibi_farming_%s_contact_sheet.png" % String(group_id)
		if not await _capture_sheet(viewport, lineup, caption, String(group_id).to_upper(), filename):
			viewport.queue_free()
			quit(1)
			return
		sheet_names.append(filename)
	var manifest: FileAccess = FileAccess.open("%s/chibi_farming_contact_sheets.json" % OUTPUT_DIRECTORY, FileAccess.WRITE)
	if manifest == null:
		printerr("[farming_art_review] cannot write review manifest")
		viewport.queue_free()
		quit(1)
		return
	manifest.store_string(JSON.stringify({"tile_size": TILE_SIZE, "angles": REVIEW_LAYOUT.ANGLE_COUNT, "lighting": ["day", "night"], "lineup": "res://tools/farming_art_lineup.tscn", "sheets": sheet_names}, "\t"))
	manifest.close()
	viewport.queue_free()
	print("[farming_art_review] wrote %d contact sheets under %s" % [sheet_names.size(), OUTPUT_DIRECTORY])
	quit(0)

func _capture_sheet(viewport: SubViewport, lineup: Node3D, caption: Label, review_name: String, filename: String) -> bool:
	var size: Vector2i = REVIEW_LAYOUT.sheet_size(TILE_SIZE)
	var sheet: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	for lighting_index: int in range(REVIEW_LAYOUT.LIGHTING_COUNT):
		var night: bool = lighting_index == 1
		for view_index: int in range(REVIEW_LAYOUT.ANGLE_COUNT):
			lineup.call("set_review_view", view_index, night)
			caption.text = "%s\n%s  /  %03d deg" % [review_name.replace("_", " "), "NIGHT" if night else "DAY", 45 + view_index * 90]
			await process_frame
			RenderingServer.force_draw(false)
			await RenderingServer.frame_post_draw
			var frame: Image = viewport.get_texture().get_image()
			if frame == null or frame.is_empty():
				printerr("[farming_art_review] empty contact capture; run with graphics rendering, not headless")
				return false
			if frame.get_format() != Image.FORMAT_RGBA8:
				frame.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), REVIEW_LAYOUT.tile_origin(view_index, night, TILE_SIZE))
	var save_result: Error = sheet.save_png("%s/%s" % [OUTPUT_DIRECTORY, filename])
	if save_result != OK:
		printerr("[farming_art_review] cannot save contact sheet: %s" % error_string(save_result))
		return false
	return true
