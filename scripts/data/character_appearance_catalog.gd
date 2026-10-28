## CharacterAppearanceCatalog — data-owned player cosmetic options and NPC visual recipes.
## API:
##   func get_npc_appearance(npc_id: StringName) -> Resource
##   func get_player_customization() -> Dictionary
##   func normalize_player_customization(selection: Dictionary) -> Dictionary
##   func resolve_player(selection: Dictionary) -> Dictionary
##   func validate() -> PackedStringArray
class_name CharacterAppearanceCatalog
extends Resource

const MIN_OPTION_COUNT: int = 6

@export var catalog_id: StringName = &""
@export var player_base: Resource
@export var npc_appearances: Array[Resource] = []
@export var pet_appearance: Resource
@export var player_hair_styles: PackedStringArray = PackedStringArray()
@export var player_skin_tones: Array[Color] = []
@export var player_hair_colors: Array[Color] = []
@export var player_outfit_colors: Array[Color] = []

func get_npc_appearance(npc_id: StringName) -> Resource:
	for appearance: Resource in npc_appearances:
		if appearance != null and StringName(appearance.get("character_id")) == npc_id:
			return appearance
	return null

func get_default_player_appearance() -> Resource:
	return player_base

func get_player_customization() -> Dictionary:
	return {
		"hair_styles": player_hair_styles.duplicate(),
		"skin_tones": player_skin_tones.duplicate(),
		"hair_colors": player_hair_colors.duplicate(),
		"outfit_colors": player_outfit_colors.duplicate(),
		"default": normalize_player_customization({})
	}

func normalize_player_customization(selection: Dictionary) -> Dictionary:
	var base: Resource = player_base
	if base == null:
		return {}
	var style: StringName = StringName(selection.get("hair_style", base.get("hair_style")))
	if not player_hair_styles.has(String(style)):
		style = player_hair_styles[0] if not player_hair_styles.is_empty() else StringName(base.get("hair_style"))
	return {
		"hair_style": String(style),
		"skin_index": _normalized_index(selection.get("skin_index", 0), player_skin_tones.size()),
		"hair_color_index": _normalized_index(selection.get("hair_color_index", 0), player_hair_colors.size()),
		"outfit_color_index": _normalized_index(selection.get("outfit_color_index", 0), player_outfit_colors.size())
	}

func resolve_player(selection: Dictionary) -> Dictionary:
	var base: Resource = player_base
	if base == null:
		return {}
	var normalized: Dictionary = normalize_player_customization(selection)
	var profile: Dictionary = base.call("to_builder_dictionary") as Dictionary
	profile["hair_style"] = StringName(normalized.get("hair_style", base.get("hair_style")))
	profile["skin_color"] = _color_at(player_skin_tones, int(normalized.get("skin_index", 0)), base.get("skin_color") as Color)
	profile["hair_color"] = _color_at(player_hair_colors, int(normalized.get("hair_color_index", 0)), base.get("hair_color") as Color)
	profile["outfit_color"] = _color_at(player_outfit_colors, int(normalized.get("outfit_color_index", 0)), base.get("outfit_color") as Color)
	profile["selection"] = normalized
	return profile

func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not _is_snake_case(String(catalog_id)):
		errors.append("character catalog id must be non-empty snake_case")
	if player_base == null:
		errors.append("character catalog has no player base")
	else:
		if not player_base.has_method("validate") or not player_base.has_method("to_builder_dictionary"):
			errors.append("character catalog player base has invalid API")
		else:
			errors.append_array(player_base.call("validate") as PackedStringArray)
		if StringName(player_base.get("character_id")) != &"player":
			errors.append("character catalog player base id must be player")
	if pet_appearance == null:
		errors.append("character catalog has no pet calibration profile")
	else:
		if not pet_appearance.has_method("validate"):
			errors.append("character catalog pet profile has invalid API")
		else:
			errors.append_array(pet_appearance.call("validate") as PackedStringArray)
	if player_hair_styles.size() < MIN_OPTION_COUNT:
		errors.append("character catalog needs at least %d hair styles" % MIN_OPTION_COUNT)
	if player_skin_tones.size() < MIN_OPTION_COUNT:
		errors.append("character catalog needs at least %d skin tones" % MIN_OPTION_COUNT)
	if player_hair_colors.size() < MIN_OPTION_COUNT:
		errors.append("character catalog needs at least %d hair colors" % MIN_OPTION_COUNT)
	if player_outfit_colors.size() < MIN_OPTION_COUNT:
		errors.append("character catalog needs at least %d outfit colors" % MIN_OPTION_COUNT)
	var seen_styles: Dictionary = {}
	for style: String in player_hair_styles:
		if not _is_snake_case(style) or seen_styles.has(style):
			errors.append("character catalog hair styles must be unique snake_case")
		seen_styles[style] = true
	for color_group: Array[Color] in [player_skin_tones, player_hair_colors, player_outfit_colors]:
		for color: Color in color_group:
			if not _is_visible_color(color):
				errors.append("character catalog has an invalid player color")
	var seen_npcs: Dictionary = {}
	for appearance: Resource in npc_appearances:
		if appearance == null:
			errors.append("character catalog has a null NPC appearance")
			continue
		if not appearance.has_method("validate"):
			errors.append("character catalog NPC appearance has invalid API")
		else:
			errors.append_array(appearance.call("validate") as PackedStringArray)
		var npc_id: String = String(appearance.get("character_id"))
		if seen_npcs.has(npc_id):
			errors.append("character catalog has duplicate NPC appearance: %s" % npc_id)
		seen_npcs[npc_id] = true
	for required_id: StringName in [&"an", &"lam", &"linh", &"minh"]:
		if not seen_npcs.has(String(required_id)):
			errors.append("character catalog is missing NPC appearance: %s" % required_id)
	return errors

func _normalized_index(value: Variant, count: int) -> int:
	if count <= 0:
		return 0
	return clampi(int(value), 0, count - 1)

func _color_at(values: Array[Color], index: int, fallback: Color) -> Color:
	if values.is_empty():
		return fallback
	return values[clampi(index, 0, values.size() - 1)]

func _is_visible_color(color: Color) -> bool:
	return color.a > 0.0 and color.r >= 0.0 and color.r <= 1.0 and color.g >= 0.0 and color.g <= 1.0 and color.b >= 0.0 and color.b <= 1.0

func _is_snake_case(value: String) -> bool:
	return not value.is_empty() and value == value.to_lower() and not value.contains(" ") and not value.contains("-")
