## Renders C1 character lineup and per-model four-angle day/night contact sheets.
extends SceneTree

const LINEUP_SCENE: PackedScene = preload("res://tools/character_lineup.tscn")
const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")
const OUTPUT_DIRECTORY: String = "res://screenshots/chibi-characters"
const TILE_SIZE: int = 512

func _init() -> void:
	call_deferred("_capture_review")

func _capture_review() -> void:
	var directory_result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	if directory_result != OK:
		printerr("[character_review] cannot create output directory: %s" % error_string(directory_result))
		quit(1)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.name = "CharacterReviewViewport"
	viewport.size = Vector2i(TILE_SIZE, TILE_SIZE)
	viewport.transparent_bg = false
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	if lineup == null:
		printerr("[character_review] cannot instantiate character lineup")
		viewport.queue_free()
		quit(1)
		return
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
	var lineup_error: String = String(lineup.get("last_error"))
	if not lineup_error.is_empty():
		printerr("[character_review] %s" % lineup_error)
		viewport.queue_free()
		quit(1)
		return
	var sheet_names: Array[String] = []
	lineup.call("set_focus_model", &"")
	if not await _capture_sheet(viewport, lineup, caption, "C1 LINEUP", "chibi_characters_contact_sheet.png"):
		viewport.queue_free()
		quit(1)
		return
	sheet_names.append("chibi_characters_contact_sheet.png")
	var model_ids: PackedStringArray = lineup.call("get_review_model_names") as PackedStringArray
	for model_id: StringName in model_ids:
		lineup.call("set_focus_model", model_id)
		var filename: String = "chibi_character_%s_contact_sheet.png" % String(model_id)
		if not await _capture_sheet(viewport, lineup, caption, String(model_id).to_upper(), filename):
			viewport.queue_free()
			quit(1)
			return
		sheet_names.append(filename)
	var manifest: FileAccess = FileAccess.open("%s/chibi_characters_contact_sheet.json" % OUTPUT_DIRECTORY, FileAccess.WRITE)
	if manifest == null:
		printerr("[character_review] cannot write review manifest")
		viewport.queue_free()
		quit(1)
		return
	manifest.store_string(JSON.stringify({
		"tile_size": TILE_SIZE,
		"angles": REVIEW_LAYOUT.ANGLE_COUNT,
		"lighting": ["day", "night"],
		"lineup": "res://tools/character_lineup.tscn",
		"sheets": sheet_names
	}, "\t"))
	manifest.close()
	viewport.queue_free()
	print("[character_review] wrote %d contact sheets under %s" % [sheet_names.size(), OUTPUT_DIRECTORY])
	quit(0)

func _capture_sheet(viewport: SubViewport, lineup: Node3D, caption: Label, review_name: String, filename: String) -> bool:
	var sheet_size: Vector2i = REVIEW_LAYOUT.sheet_size(TILE_SIZE)
	var sheet: Image = Image.create(sheet_size.x, sheet_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)
	for lighting_index: int in range(REVIEW_LAYOUT.LIGHTING_COUNT):
		var night: bool = lighting_index == 1
		for view_index: int in range(REVIEW_LAYOUT.ANGLE_COUNT):
			lineup.call("set_review_view", view_index, night)
			caption.text = "%s  •  %s  •  %03d°" % [review_name, "NIGHT" if night else "DAY", 45 + view_index * 90]
			await process_frame
			RenderingServer.force_draw(false)
			await RenderingServer.frame_post_draw
			var frame: Image = viewport.get_texture().get_image()
			if frame == null or frame.is_empty():
				printerr("[character_review] contact capture is empty; run this tool with a graphics renderer, not --headless")
				return false
			if frame.get_format() != Image.FORMAT_RGBA8:
				frame.convert(Image.FORMAT_RGBA8)
			sheet.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), REVIEW_LAYOUT.tile_origin(view_index, night, TILE_SIZE))
	var output_path: String = "%s/%s" % [OUTPUT_DIRECTORY, filename]
	var save_result: Error = sheet.save_png(output_path)
	if save_result != OK:
		printerr("[character_review] cannot save contact sheet: %s" % error_string(save_result))
		return false
	return true
