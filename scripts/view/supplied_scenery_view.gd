## SuppliedSceneryView — one grounded supplied texture, no input/physics/state.
## API:
##   func configure(entry: Dictionary) -> bool
##   static func create_tall(entry: Dictionary, cell: Vector2i, index: int) -> Node2D
class_name SuppliedSceneryView
extends Node2D

var sprite: Sprite2D

static func create_tall(entry: Dictionary, cell: Vector2i, index: int) -> Node2D:
	var visual: SuppliedSceneryView = SuppliedSceneryView.new()
	if not visual.configure(entry):
		visual.free()
		return null
	# Keep the established tree type/season metadata for existing consumers;
	# self_modulate hides only its old drawing, never the supplied child art.
	var root: PlaceholderWorld2D = PlaceholderWorld2D.new()
	root.kind = &"tree"
	root.self_modulate = Color.TRANSPARENT
	root.set_process(false)
	root.name = "Tree_%d" % index
	root.set_meta("cell", cell)
	root.set_meta("passive_tree", true)
	root.set_meta("asset_id", entry.id)
	visual.name = "Visual"
	root.add_child(visual)
	return root

func configure(entry: Dictionary) -> bool:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
	var path: Variant = entry.get("path")
	var pivot: Variant = entry.get("pivot")
	var scale_value: Variant = entry.get("scale")
	if not path is String or not pivot is Vector2 or not scale_value is Vector2 or not pivot.is_finite() or not scale_value.is_finite() or scale_value.x <= 0 or scale_value.y <= 0 or not ResourceLoader.exists(path):
		sprite.texture = null
		hide()
		return false
	var texture: Texture2D = load(path) as Texture2D
	if texture == null or Vector2i(texture.get_size()) != entry.get("image_size"):
		sprite.texture = null
		hide()
		return false
	sprite.texture = texture
	sprite.scale = scale_value
	sprite.position = -pivot * scale_value
	set_meta("asset_id", entry.id)
	set_meta("scenery_kind", entry.kind)
	set_meta("scenery_size", entry.size)
	set_meta("variant", entry.variant)
	show()
	return true
