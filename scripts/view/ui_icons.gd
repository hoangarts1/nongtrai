## UiIcons — original local SVG textures; UI keeps localized tooltips.
class_name UiIcons
extends RefCounted

const ICON_IDS: PackedStringArray = ["backpack", "help", "journal", "settings", "pause", "hoe", "watering_can", "seed", "harvest", "sun", "coin", "carrot", "turnip", "pea", "tomato", "corn", "pumpkin", "wheat", "radish", "cabbage", "play", "close"]
static var _textures: Dictionary = {}

static func get_icon(icon_id: StringName) -> Texture2D:
	var id: String = String(icon_id)
	if not ICON_IDS.has(id):
		return null
	if not _textures.has(id):
		_textures[id] = load("res://assets/icons/ui_%s.svg" % id)
	return _textures[id] as Texture2D

static func for_item(item_id: StringName) -> Texture2D:
	var id: String = String(item_id)
	if id.ends_with("_seed"):
		id = id.trim_suffix("_seed")
	for crop: String in ["carrot", "turnip", "pea", "tomato", "corn", "pumpkin", "wheat", "radish", "cabbage"]:
		if id.contains(crop):
			return get_icon(StringName(crop))
	return get_icon(&"seed")

static func decorate(button: Button, icon_id: StringName, icon_only: bool = false) -> void:
	button.icon = get_icon(icon_id)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 34)
	button.add_theme_constant_override("h_separation", 12)
	if icon_only:
		if button.tooltip_text.is_empty():
			button.tooltip_text = button.text
		button.text = ""
