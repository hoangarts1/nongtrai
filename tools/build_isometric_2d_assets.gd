## Builds deterministic 2D isometric PNG assets for buildings, character spritesheet, and 9-slice UI frame.
extends SceneTree

const INK: Color = Color("3a2412")
const WOOD: Color = Color("bc8340")
const WOOD_DARK: Color = Color("8c5828")
const WOOD_LIGHT: Color = Color("d8a461")
const PAPER: Color = Color("f5e3b0")
const PAPER_SHADE: Color = Color("dfc99b")
const ROOF_RED: Color = Color("c85a40")
const ROOF_LIGHT: Color = Color("dc7256")
const ROOF_DARK: Color = Color("9e3f2a")
const GREEN: Color = Color("5fb230")
const GOLD: Color = Color("ffd25a")
const SKY: Color = Color("8ed2f6")

var _failed: bool = false

func _init() -> void:
	var asset_root: String = "res://assets"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output-root="):
			asset_root = argument.trim_prefix("--output-root=").strip_edges()
	if asset_root.is_empty():
		push_error("build_isometric_2d_assets: output root is empty")
		quit(1)
		return
	_build_cottage(asset_root.path_join("buildings/cottage_2x.png"))
	_build_market(asset_root.path_join("buildings/market_2x.png"))
	_build_shipping_bin(asset_root.path_join("buildings/shipping_bin_2x.png"))
	_build_farmer_sheet(asset_root.path_join("characters/farmer_sheet_2x.png"))
	_build_ui_frame(asset_root.path_join("ui/frame_wood_9slice.png"))
	if _failed:
		quit(1)
	else:
		print("[build_isometric_2d_assets] PASS")
		quit(0)

func _save_png(img: Image, path: String) -> void:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	if directory_error!=OK:
		_failed = true
		push_error("build_isometric_2d_assets: cannot create directory for %s (%d)" % [path,directory_error])
		return
	var write_error: Error = img.save_png(path)
	if write_error!=OK:
		_failed = true
		push_error("build_isometric_2d_assets: cannot write %s (%d)" % [path,write_error])

func _build_cottage(path: String) -> void:
	var img: Image = Image.create(160, 140, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_fill_ellipse(img, Vector2(80, 120), Vector2(58, 18), Color(0.12, 0.16, 0.08, 0.25))
	# Left isometric wall: (32,88) -> (80,112) -> (80,68) -> (32,44)
	_fill_iso_wall(img, 32, 80, 44, 68, 44, PAPER, INK)
	# Right isometric wall: (80,112) -> (128,88) -> (128,44) -> (80,68)
	_fill_iso_wall(img, 80, 128, 68, 44, 44, PAPER_SHADE, INK)
	# Roof left & right slopes
	_fill_roof(img, 24, 80, 136, 18, 46, ROOF_RED, ROOF_LIGHT, ROOF_DARK, INK)
	# Chimney
	_fill_rect_outlined(img, Rect2i(96, 16, 14, 24), Color("8c7a6b"), INK)
	# Door on right wall & window on left wall
	_fill_iso_wall(img, 96, 112, 80, 72, 24, WOOD_DARK, INK)
	_fill_iso_wall(img, 46, 66, 62, 72, 16, SKY, INK)
	_save_png(img,path)

func _build_market(path: String) -> void:
	var img: Image = Image.create(140, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_fill_ellipse(img, Vector2(70, 110), Vector2(48, 15), Color(0.12, 0.16, 0.08, 0.25))
	_fill_iso_wall(img, 30, 70, 72, 92, 24, WOOD, INK)
	_fill_iso_wall(img, 70, 110, 92, 72, 24, WOOD_DARK, INK)
	_fill_rect_outlined(img, Rect2i(34, 38, 6, 42), WOOD_DARK, INK)
	_fill_rect_outlined(img, Rect2i(100, 38, 6, 42), WOOD_DARK, INK)
	_fill_roof(img, 24, 70, 116, 20, 42, ROOF_RED, PAPER, ROOF_DARK, INK)
	_save_png(img,path)

func _build_shipping_bin(path: String) -> void:
	var img: Image = Image.create(96, 88, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_fill_ellipse(img, Vector2(48, 72), Vector2(32, 11), Color(0.12, 0.16, 0.08, 0.25))
	_fill_iso_wall(img, 22, 48, 42, 55, 22, WOOD, INK)
	_fill_iso_wall(img, 48, 74, 55, 42, 22, WOOD_DARK, INK)
	_fill_roof(img, 20, 48, 76, 28, 42, WOOD_LIGHT, WOOD, WOOD_DARK, INK)
	_fill_rect_outlined(img, Rect2i(44, 44, 8, 8), GOLD, INK)
	_save_png(img,path)

func _build_farmer_sheet(path: String) -> void:
	var img: Image = Image.create(256, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	for frame: int in range(4):
		var cx: int = 32 + frame * 64
		var bob: int = -2 if frame % 2 == 1 else 0
		_fill_ellipse(img, Vector2(cx, 56), Vector2(14, 5), Color(0.1, 0.15, 0.06, 0.25))
		_fill_rect_outlined(img, Rect2i(cx - 8, 44 + bob, 7, 10), WOOD_DARK, INK)
		_fill_rect_outlined(img, Rect2i(cx + 1, 44 - bob, 7, 10), WOOD_DARK, INK)
		_fill_rect_outlined(img, Rect2i(cx - 10, 28 + bob, 20, 18), Color("6a9c55"), INK)
		_fill_ellipse(img, Vector2(cx, 18 + bob), Vector2(12, 11), Color("efc69f"), INK)
		_fill_ellipse(img, Vector2(cx, 10 + bob), Vector2(16, 5), Color("e6c875"), INK)
		_fill_rect_outlined(img, Rect2i(cx - 10, 5 + bob, 20, 6), Color("e6c875"), INK)
	_save_png(img,path)

func _build_ui_frame(path: String) -> void:
	var img: Image = Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_fill_rect_outlined(img, Rect2i(2, 2, 92, 92), WOOD, INK)
	_fill_rect_outlined(img, Rect2i(12, 12, 72, 72), PAPER, INK)
	for pt: Vector2 in [Vector2(8, 8), Vector2(88, 8), Vector2(8, 88), Vector2(88, 88)]:
		_fill_ellipse(img, pt, Vector2(4, 4), GOLD, INK)
	_save_png(img,path)

func _fill_iso_wall(img: Image, x0: int, x1: int, y0: int, y1: int, h: int, fill: Color, border: Color) -> void:
	var span: float = maxf(1.0, float(x1 - x0))
	for x: int in range(x0, x1 + 1):
		var t: float = float(x - x0) / span
		var top_y: int = int(round(lerpf(float(y0), float(y1), t)))
		var bot_y: int = top_y + h
		for y: int in range(top_y, bot_y + 1):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var edge: bool = x <= x0 + 1 or x >= x1 - 1 or y <= top_y + 1 or y >= bot_y - 1
				img.set_pixel(x, y, border if edge else fill)

func _fill_roof(img: Image, x_left: int, x_mid: int, x_right: int, y_peak: int, y_eave: int, c_main: Color, c_light: Color, c_dark: Color, border: Color) -> void:
	for x: int in range(x_left, x_right + 1):
		var ratio: float = float(absi(x - x_mid)) / maxf(1.0, float(x_mid - x_left))
		var top_y: int = int(round(lerpf(float(y_peak), float(y_eave - 10), ratio)))
		var bot_y: int = int(round(lerpf(float(y_eave), float(y_eave + 12), 1.0 - ratio)))
		for y: int in range(top_y, bot_y + 1):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var edge: bool = y <= top_y + 1 or y >= bot_y - 1 or x <= x_left + 1 or x >= x_right - 1
				var checker: bool = ((x / 6) + (y / 5)) % 2 == 0
				var tone: Color = (c_light if checker else c_main) if x < x_mid else (c_main if checker else c_dark)
				img.set_pixel(x, y, border if edge else tone)

func _fill_rect_outlined(img: Image, rect: Rect2i, fill: Color, border: Color) -> void:
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var edge: bool = x <= rect.position.x + 1 or x >= rect.end.x - 2 or y <= rect.position.y + 1 or y >= rect.end.y - 2
				img.set_pixel(x, y, border if edge else fill)

func _fill_ellipse(img: Image, center: Vector2, radii: Vector2, fill: Color, border: Color = Color.TRANSPARENT) -> void:
	for y: int in range(int(center.y - radii.y - 2), int(center.y + radii.y + 2)):
		for x: int in range(int(center.x - radii.x - 2), int(center.x + radii.x + 2)):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var dx: float = (float(x) - center.x) / maxf(1.0, radii.x)
				var dy: float = (float(y) - center.y) / maxf(1.0, radii.y)
				var d: float = dx * dx + dy * dy
				if d <= 1.0:
					var is_border: bool = border.a > 0.0 and d >= 0.72
					img.set_pixel(x, y, border if is_border else fill)

