## LifeInventoryIcon — uses existing art with transparent padding removed in the view.
class_name LifeInventoryIcon
extends RefCounted

static var _cache: Dictionary[StringName,Texture2D] = {}

static func for_item(id: StringName) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var source: Texture2D = UiIcons.for_item(id)
	if source==null:
		return null
	var image: Image = source.get_image()
	var bounds: Rect2i = image.get_used_rect()
	if bounds.has_area():
		var icon: AtlasTexture = AtlasTexture.new()
		icon.atlas = source
		icon.region = Rect2(bounds)
		_cache[id] = icon
	else:
		_cache[id] = source
	return _cache[id]
