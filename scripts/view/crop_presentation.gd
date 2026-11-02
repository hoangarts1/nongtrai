## CropPresentation — 2D crop-stage placeholders; existing crop Resources own growth/yield.
## API:
##   static func render(crop: Sprite2D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i) -> void
##   static func clear(crop: Sprite2D) -> void
class_name CropPresentation
extends RefCounted

static var _textures: Dictionary = {}

static func clear(crop: Sprite2D) -> void:
	crop.texture = null
	crop.set_meta("mature", false)
	crop.set_meta("withered", false)

static func get_stage_id(growth_ratio: float, withered: bool = false) -> StringName:
	return &"withered" if withered else StringName(str(3 if growth_ratio >= 0.999 else clampi(floori(growth_ratio * 3.0), 0, 2)))

static func render(crop: Sprite2D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, _cell: Vector2i) -> void:
	var stage: StringName = get_stage_id(growth_ratio, withered)
	var key: String = "%s:%s:%s:%s" % [crop_id, stage, crop_color.to_html(), str(watered)]
	if not _textures.has(key):
		_textures[key] = _texture(stage, crop_color, watered)
	crop.texture = _textures[key] as Texture2D
	crop.centered = true
	crop.offset = Vector2(0, -24)
	crop.set_meta("stage_id", stage)
	crop.set_meta("mature", stage == &"3")
	crop.set_meta("withered", withered)
	crop.set_meta("crop_id", crop_id)

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
