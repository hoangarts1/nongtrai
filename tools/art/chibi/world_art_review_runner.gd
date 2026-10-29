## Renders C3 world art contact sheets with four seasons, day/night and four angles.
extends SceneTree

const LINEUP_SCENE: PackedScene = preload("res://tools/chibi_world_lineup.tscn")
const OUTPUT_DIRECTORY: String = "res://screenshots/chibi-world"
const TILE_SIZE: int = 384
const SEASONS: Array[String] = ["spring", "summer", "autumn", "winter"]
const ANGLES: Array[float] = [45.0, 135.0, 225.0, 315.0]

func _init() -> void:
	call_deferred("_capture_review")

func _capture_review() -> void:
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if result != OK:
		printerr("[world_art_review] cannot create output directory: %s" % error_string(result))
		quit(1)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "WorldReviewViewport"
	viewport.size = Vector2i(TILE_SIZE, TILE_SIZE)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	if lineup == null:
		printerr("[world_art_review] cannot instantiate C3 world lineup")
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
		printerr("[world_art_review] %s" % lineup.get("last_error"))
		viewport.queue_free()
		quit(1)
		return
	var sheet_names: Array[String] = []
	for group_id: StringName in lineup.call("get_review_group_ids") as PackedStringArray:
		lineup.call("set_focus_group", group_id)
		if not String(lineup.get("last_error")).is_empty():
			printerr("[world_art_review] %s" % lineup.get("last_error"))
			viewport.queue_free()
			quit(1)
			return
		var filename: String = "chibi_world_%s_contact_sheet.png" % String(group_id)
		if not await _capture_sheet(viewport, lineup, caption, String(group_id).to_upper(), filename):
			viewport.queue_free()
			quit(1)
			return
		sheet_names.append(filename)
	var manifest: FileAccess = FileAccess.open("%s/chibi_world_contact_sheets.json" % OUTPUT_DIRECTORY, FileAccess.WRITE)
	if manifest == null:
		printerr("[world_art_review] cannot write review manifest")
		viewport.queue_free()
		quit(1)
		return
	manifest.store_string(JSON.stringify({"tile_size": TILE_SIZE, "angles": ANGLES, "seasons": SEASONS, "lighting": ["day", "night"], "lineup": "res://tools/chibi_world_lineup.tscn", "sheets": sheet_names}, "\t"))
	manifest.close()
	viewport.queue_free()
	print("[world_art_review] wrote %d contact sheets under %s" % [sheet_names.size(), OUTPUT_DIRECTORY])
	quit(0)

func _capture_sheet(viewport: SubViewport, lineup: Node3D, caption: Label, review_name: String, filename: String) -> bool:
	var sheet: Image = Image.create(TILE_SIZE * ANGLES.size(), TILE_SIZE * SEASONS.size() * 2, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	for season_index: int in range(SEASONS.size()):
		for lighting_index: int in range(2):
			var night: bool = lighting_index == 1
			for view_index: int in range(ANGLES.size()):
				lineup.call("set_review_view", view_index, night, StringName(SEASONS[season_index]))
				caption.text = "%s\n%s %s / %03d deg" % [review_name.replace("_", " "), String(SEASONS[season_index]).to_upper(), "NIGHT" if night else "DAY", int(ANGLES[view_index])]
				await process_frame
				RenderingServer.force_draw(false)
				await RenderingServer.frame_post_draw
				var frame: Image = viewport.get_texture().get_image()
				if frame == null or frame.is_empty():
					printerr("[world_art_review] empty contact capture; run with graphics rendering, not headless")
					return false
				if frame.get_format() != Image.FORMAT_RGBA8:
					frame.convert(Image.FORMAT_RGBA8)
				var origin: Vector2i = Vector2i(view_index * TILE_SIZE, (season_index * 2 + lighting_index) * TILE_SIZE)
				sheet.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), origin)
	var save_result: Error = sheet.save_png("%s/%s" % [OUTPUT_DIRECTORY, filename])
	if save_result != OK:
		printerr("[world_art_review] cannot save contact sheet: %s" % error_string(save_result))
		return false
	return true
