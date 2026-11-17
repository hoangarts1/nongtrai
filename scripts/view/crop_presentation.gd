## CropPresentation — 2D crop-stage placeholders; existing crop Resources own growth/yield.
## API:
##   static func render(crop: Sprite2D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i, regrowing: bool = false) -> void
##   static func clear(crop: Sprite2D) -> void
class_name CropPresentation
extends RefCounted

static var _textures: Dictionary = {}
static var _manifest: Dictionary = {}
static var _missing_visuals: Dictionary = {}

static func clear(crop: Sprite2D) -> void:
	crop.texture = null
	crop.set_meta("mature", false)
	crop.set_meta("withered", false)

static func get_stage_id(growth_ratio: float, withered: bool = false, regrowing: bool = false) -> StringName:
	return &"withered" if withered else StringName(str(maxi(0, CropStageRules.ratio_stage_index(growth_ratio, regrowing))))

static func render(crop: Sprite2D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, _cell: Vector2i, regrowing: bool = false) -> void:
	var stage: StringName = get_stage_id(growth_ratio, withered, regrowing)
	var stage_index: int = maxi(0, CropStageRules.ratio_stage_index(growth_ratio, regrowing))
	var visual: Dictionary = _get_visual(crop_id, stage_index, withered)
	if visual.is_empty():
		var key: String = "%s:%s:%s:%s" % [crop_id, stage, crop_color.to_html(), str(watered)]
		if not _textures.has(key):
			_textures[key] = _texture(stage, crop_color, watered)
		crop.texture = _textures[key] as Texture2D
		crop.offset = Vector2(0, -24)
	else:
		crop.texture = visual["texture"] as Texture2D
		crop.offset = Vector2(0, float(visual["canvas"][1]) * 0.5 - float(visual["pivot"][1]))
	crop.centered = true
	crop.set_meta("stage_id", stage)
	crop.set_meta("visual_stage", stage_index + 1)
	crop.set_meta("visual_asset", visual.get("path", "placeholder"))
	# Fruit art in the last quarter does not authorize an early harvest.
	crop.set_meta("mature", not withered and is_finite(growth_ratio) and growth_ratio >= 1.0)
	crop.set_meta("withered", withered)
	crop.set_meta("crop_id", crop_id)

static func _get_visual(crop_id: StringName, stage_index: int, withered: bool) -> Dictionary:
	var crop_name: String = String(crop_id)
	for prefix: String in ["spring_", "summer_", "autumn_", "winter_"]:
		if crop_name.begins_with(prefix):
			crop_name = crop_name.trim_prefix(prefix)
			break
	var manifest: Dictionary = _load_manifest()
	var entry: Dictionary = manifest.get("crops", {}).get(crop_name, {})
	if entry.is_empty():
		_warn_missing(crop_name)
		return {}
	var directory: String = "res://assets/crops/%s/" % crop_name
	var suffix: String = "_wilted" if withered else ""
	var path: String = "%s%s_stage%d%s.png" % [directory, crop_name, stage_index + 1, suffix]
	if not FileAccess.file_exists(path):
		_warn_missing(path)
		return {}
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		_warn_missing(path)
		return {}
	return {
		"texture": texture,
		"path": path,
		"canvas": Vector2(entry.get("canvas", [128, 128])[0], entry.get("canvas", [128, 128])[1]),
		"pivot": Vector2(entry.get("pivot", [64, 100])[0], entry.get("pivot", [64, 100])[1])
	}

static func _load_manifest() -> Dictionary:
	if not _manifest.is_empty():
		return _manifest
	var file: FileAccess = FileAccess.open("res://assets/crops/crops_manifest.json", FileAccess.READ)
	if file == null:
		push_warning("Crop manifest is unavailable; crop placeholders remain active.")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_manifest = parsed as Dictionary
	return _manifest

static func _warn_missing(key: String) -> void:
	if _missing_visuals.has(key):
		return
	_missing_visuals[key] = true
	push_warning("Crop visual is unavailable for %s; placeholder remains active." % key)

static func _texture(stage: StringName, color: Color, watered: bool) -> Texture2D:
	var image: Image = Image.create(40, 52, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var height: int = 12 if stage == &"0" else (22 if stage == &"1" else (32 if stage == &"2" else 42))
	var foliage: Color = Color("69933e") if stage != &"withered" else Color("8b704d")
	var body: Color = color if stage != &"withered" else Color("9b8059")
	for y: int in range(52):
		for x: int in range(40):
			var p: Vector2 = Vector2(x - 20, y - (49 - height))
			var leaf_left: Vector2 = (p + Vector2(6, 0)) / Vector2(10, 6)
			var leaf_right: Vector2 = (p - Vector2(6, 0)) / Vector2(10, 6)
			if leaf_left.length_squared() < 1.0 or leaf_right.length_squared() < 1.0 or (absf(p.x) < 1.5 and p.y >= 0 and p.y < height):
				image.set_pixel(x, y, foliage)
			if stage == &"3" or stage == &"withered":
				if ((Vector2(x - 20, y - 39)) / Vector2(9, 10)).length_squared() <= 1.0:
					image.set_pixel(x, y, body)
	if watered:
		for y: int in range(43, 48):
			for x: int in range(29, 33):
				image.set_pixel(x,y,Color("6fb7f0"))
	if stage == &"3":
		image.set_pixel(31, 12, Color("ffd25a"))
		image.set_pixel(30, 11, Color("ffd25a"))
		image.set_pixel(32, 11, Color("ffd25a"))
	return ImageTexture.create_from_image(image)
