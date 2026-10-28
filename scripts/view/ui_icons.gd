## UiIcons — original local SVG textures; UI keeps localized tooltips.
class_name UiIcons
extends RefCounted

const ICON_IDS: PackedStringArray = ["backpack", "help", "journal", "settings", "pause", "hoe", "watering_can", "seed", "harvest", "sun", "coin", "carrot", "turnip", "pea", "tomato", "corn", "pumpkin", "wheat", "radish", "cabbage", "play", "close"]
static var _textures: Dictionary = {}

static func get_icon(icon_id: StringName) -> Texture2D:
	var id: String = String(icon_id)
	if not ICON_IDS.has(id):
		return null
	if id in ["hoe", "watering_can", "seed", "harvest"]:
		var generated_tool_path: String = "res://assets/generated/icons/tool_%s.png" % id
		if ResourceLoader.exists(generated_tool_path):
			var generated_tool: Texture2D = _load_texture(generated_tool_path)
			if generated_tool != null:
				return generated_tool
	if not _textures.has(id):
		_textures[id] = load("res://assets/icons/ui_%s.svg" % id)
	return _textures[id] as Texture2D

static func for_item(item_id: StringName) -> Texture2D:
	var item: Resource = DataRegistry.get_item(item_id)
	if item != null:
		var generated_path: String = String(item.get("icon_path"))
		if not generated_path.is_empty() and ResourceLoader.exists(generated_path):
			var generated: Texture2D = _load_texture(generated_path)
			if generated != null:
				return generated
	var id: String = String(item_id)
	if id.ends_with("_seed"):
		id = id.trim_suffix("_seed")
	for crop: String in ["carrot", "turnip", "pea", "tomato", "corn", "pumpkin", "wheat", "radish", "cabbage"]:
		if id.contains(crop):
			return get_icon(StringName(crop))
	return get_icon(&"seed")

static func _load_texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path) as Texture2D
	return _textures[path] as Texture2D

static func decorate(button: Button, icon_id: StringName, icon_only: bool = false) -> void:
	button.icon = get_icon(icon_id)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 34)
	button.add_theme_constant_override("h_separation", 12)
	if icon_only:
		if button.tooltip_text.is_empty():
			button.tooltip_text = button.text
		button.text = ""
