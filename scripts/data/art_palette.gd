## ArtPalette — data-owned warm chibi colors, scale and triangle budgets.
## API:
##   func get_color(role: StringName, season: StringName = &"spring") -> Color
##   func get_triangle_budget(kind: StringName) -> int
##   func validate() -> PackedStringArray
class_name ArtPalette
extends Resource

const SEASONS: Array[String] = ["spring", "summer", "autumn", "winter"]
const REQUIRED_ROLES: Array[String] = [
	"ground", "foliage", "water", "wood", "stone", "roof", "ui_accent", "outline", "shadow", "sunlight"
]

@export var palette_id: StringName = &""
@export_range(0.5, 2.0, 0.05) var character_height_meters: float = 1.0
@export_range(0.4, 0.7, 0.01) var head_height_ratio_min: float = 0.50
@export_range(0.4, 0.7, 0.01) var head_height_ratio_max: float = 0.55

@export_range(1, 20000) var character_triangle_budget: int = 6000
@export_range(1, 10000) var prop_triangle_budget: int = 1500
@export_range(1, 5000) var crop_triangle_budget: int = 400
@export_range(1, 30000) var building_triangle_budget: int = 8000
@export_range(1, 10000) var tree_triangle_budget: int = 1000

@export var outline_color: Color = Color("4b3c47")
@export var shadow_tint: Color = Color("82749a")
@export var sunlight_color: Color = Color("fff3cf")
@export var wood_color: Color = Color("b98762")
@export var stone_color: Color = Color("8b8e9b")
@export var ui_accent_color: Color = Color("f3a58e")

@export var spring_ground: Color = Color("a9c98b")
@export var summer_ground: Color = Color("91ba78")
@export var autumn_ground: Color = Color("c7b278")
@export var winter_ground: Color = Color("c8d3dc")

@export var spring_foliage: Color = Color("91bd78")
@export var summer_foliage: Color = Color("73aa70")
@export var autumn_foliage: Color = Color("c28b60")
@export var winter_foliage: Color = Color("8fa4b3")

@export var spring_water: Color = Color("77b9c9")
@export var summer_water: Color = Color("5faec4")
@export var autumn_water: Color = Color("6c9eb5")
@export var winter_water: Color = Color("a4c7d7")

@export var spring_roof: Color = Color("d88876")
@export var summer_roof: Color = Color("cd766e")
@export var autumn_roof: Color = Color("b96e5a")
@export var winter_roof: Color = Color("9c7c91")

func has_role(role: StringName) -> bool:
	return REQUIRED_ROLES.has(String(role))

func get_color(role: StringName, season: StringName = &"spring") -> Color:
	match role:
		&"ground":
			return _season_color(season, spring_ground, summer_ground, autumn_ground, winter_ground)
		&"foliage":
			return _season_color(season, spring_foliage, summer_foliage, autumn_foliage, winter_foliage)
		&"water":
			return _season_color(season, spring_water, summer_water, autumn_water, winter_water)
		&"roof":
			return _season_color(season, spring_roof, summer_roof, autumn_roof, winter_roof)
		&"wood":
			return wood_color
		&"stone":
			return stone_color
		&"ui_accent":
			return ui_accent_color
		&"outline":
			return outline_color
		&"shadow":
			return shadow_tint
		&"sunlight":
			return sunlight_color
	return Color.TRANSPARENT

func get_triangle_budget(kind: StringName) -> int:
	match kind:
		&"character":
			return character_triangle_budget
		&"prop":
			return prop_triangle_budget
		&"crop":
			return crop_triangle_budget
		&"building":
			return building_triangle_budget
		&"tree":
			return tree_triangle_budget
	return 0

func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if palette_id.is_empty() or not _is_snake_case(String(palette_id)):
		errors.append("art palette id must be non-empty snake_case")
	if character_height_meters <= 0.0:
		errors.append("art palette character height must be positive")
	if head_height_ratio_min <= 0.0 or head_height_ratio_min > head_height_ratio_max or head_height_ratio_max > 1.0:
		errors.append("art palette head ratio range is invalid")
	for kind: StringName in [&"character", &"prop", &"crop", &"building", &"tree"]:
		if get_triangle_budget(kind) <= 0:
			errors.append("art palette triangle budget must be positive: %s" % kind)
	for role: String in REQUIRED_ROLES:
		for season: String in SEASONS:
			if not _is_visible_color(get_color(StringName(role), StringName(season))):
				errors.append("art palette has invalid color: %s/%s" % [role, season])
	return errors

func _season_color(season: StringName, spring: Color, summer: Color, autumn: Color, winter: Color) -> Color:
	match season:
		&"summer":
			return summer
		&"autumn":
			return autumn
		&"winter":
			return winter
	return spring

func _is_visible_color(color: Color) -> bool:
	return color.a > 0.0 and color.r >= 0.0 and color.r <= 1.0 and color.g >= 0.0 and color.g <= 1.0 and color.b >= 0.0 and color.b <= 1.0

func _is_snake_case(value: String) -> bool:
	return value == value.to_lower() and not value.contains(" ") and not value.contains("-")
