## CharacterAppearanceData — data-owned visual recipe for one chibi character.
## API:
##   func to_builder_dictionary() -> Dictionary
##   func validate() -> PackedStringArray
class_name CharacterAppearanceData
extends Resource

@export var appearance_id: StringName = &""
@export var character_id: StringName = &""
@export var display_name_key: StringName = &""
@export var hair_style: StringName = &"round_bob"
@export var accessory: StringName = &"none"
@export_range(0.78, 1.20, 0.01) var body_scale: float = 1.0

@export var skin_color: Color = Color("f4ccac")
@export var hair_color: Color = Color("745542")
@export var outfit_color: Color = Color("a7bd88")
@export var accent_color: Color = Color("f3a58e")
@export var shoe_color: Color = Color("705544")
@export var eye_color: Color = Color("443a32")
@export var blush_color: Color = Color("efa3a2")

func to_builder_dictionary() -> Dictionary:
	return {
		"appearance_id": appearance_id,
		"character_id": character_id,
		"display_name_key": display_name_key,
		"hair_style": hair_style,
		"accessory": accessory,
		"body_scale": body_scale,
		"skin_color": skin_color,
		"hair_color": hair_color,
		"outfit_color": outfit_color,
		"accent_color": accent_color,
		"shoe_color": shoe_color,
		"eye_color": eye_color,
		"blush_color": blush_color
	}

func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not _is_snake_case(String(appearance_id)):
		errors.append("character appearance id must be non-empty snake_case")
	if not _is_snake_case(String(character_id)):
		errors.append("character id must be non-empty snake_case: %s" % appearance_id)
	if display_name_key.is_empty():
		errors.append("character display name key is missing: %s" % appearance_id)
	if not _is_snake_case(String(hair_style)):
		errors.append("character hair style must be non-empty snake_case: %s" % appearance_id)
	if not _is_snake_case(String(accessory)):
		errors.append("character accessory must be non-empty snake_case: %s" % appearance_id)
	if body_scale <= 0.0:
		errors.append("character body scale must be positive: %s" % appearance_id)
	for entry: Dictionary in [
		{"name": "skin", "color": skin_color},
		{"name": "hair", "color": hair_color},
		{"name": "outfit", "color": outfit_color},
		{"name": "accent", "color": accent_color},
		{"name": "shoe", "color": shoe_color},
		{"name": "eye", "color": eye_color},
		{"name": "blush", "color": blush_color}
	]:
		if not _is_visible_color(entry["color"] as Color):
			errors.append("character color is invalid: %s/%s" % [appearance_id, entry["name"]])
	return errors

func _is_visible_color(color: Color) -> bool:
	return color.a > 0.0 and color.r >= 0.0 and color.r <= 1.0 and color.g >= 0.0 and color.g <= 1.0 and color.b >= 0.0 and color.b <= 1.0

func _is_snake_case(value: String) -> bool:
	return not value.is_empty() and value == value.to_lower() and not value.contains(" ") and not value.contains("-")
