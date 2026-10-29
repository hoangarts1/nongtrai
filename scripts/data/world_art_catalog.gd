## WorldArtCatalog -- C3 visual-only world art IDs, roles and passive placements.
## API:
##   func get_model_path(asset_id: StringName) -> String
##   func get_asset_kind(asset_id: StringName) -> StringName
##   func get_asset_role(asset_id: StringName) -> StringName
##   func get_placements(asset_id: StringName) -> Array[Vector3]
##   func validate() -> PackedStringArray
class_name WorldArtCatalog
extends Resource

const MODEL_DIRECTORY: String = "res://assets/generated/models/world"
const SEASONS: Array[String] = ["spring", "summer", "autumn", "winter"]
const VALID_KINDS: Array[String] = ["building", "tree", "prop", "critter"]

@export var catalog_id: StringName = &"chibi_world"
@export var asset_ids: PackedStringArray = PackedStringArray()
@export var building_ids: PackedStringArray = PackedStringArray()
@export var tree_ids: PackedStringArray = PackedStringArray()
@export var prop_ids: PackedStringArray = PackedStringArray()
@export var critter_ids: PackedStringArray = PackedStringArray()
@export var asset_roles: Dictionary = {}
@export var placements: Dictionary = {}
@export_range(1, 64, 1) var ambient_effect_cap: int = 28
@export var spring_effect_color: Color = Color("ffd1dc")
@export var summer_effect_color: Color = Color("ffe28a")
@export var autumn_effect_color: Color = Color("e6a76a")
@export var winter_effect_color: Color = Color("e6f4ff")
@export var rain_ripple_color: Color = Color("c6e6ef")

func get_model_path(asset_id: StringName) -> String:
	if not asset_ids.has(String(asset_id)):
		return ""
	return "%s/%s.tscn" % [MODEL_DIRECTORY, String(asset_id)]

func get_asset_kind(asset_id: StringName) -> StringName:
	if building_ids.has(String(asset_id)):
		return &"building"
	if tree_ids.has(String(asset_id)):
		return &"tree"
	if critter_ids.has(String(asset_id)):
		return &"critter"
	if prop_ids.has(String(asset_id)):
		return &"prop"
	return &""

func get_asset_role(asset_id: StringName) -> StringName:
	return StringName(asset_roles.get(String(asset_id), ""))

func get_placements(asset_id: StringName) -> Array[Vector3]:
	var locations: Array[Vector3] = []
	var raw_locations: Variant = placements.get(String(asset_id), [])
	if not raw_locations is Array:
		return locations
	for raw_location: Variant in raw_locations as Array:
		if raw_location is Vector3:
			locations.append(raw_location as Vector3)
	return locations

func get_season_effect_color(season: StringName) -> Color:
	match season:
		&"summer":
			return summer_effect_color
		&"autumn":
			return autumn_effect_color
		&"winter":
			return winter_effect_color
		_:
			return spring_effect_color

func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if catalog_id.is_empty() or not _is_snake_case(String(catalog_id)):
		errors.append("world art catalog id must be non-empty snake_case")
	if asset_ids.size() < 20:
		errors.append("world art catalog must list at least twenty assets")
	var seen: Dictionary = {}
	for asset_id: String in asset_ids:
		if asset_id.is_empty() or not _is_snake_case(asset_id) or seen.has(asset_id):
			errors.append("world art catalog has invalid or duplicate asset id: %s" % asset_id)
		seen[asset_id] = true
		var kind: StringName = get_asset_kind(StringName(asset_id))
		if not VALID_KINDS.has(String(kind)):
			errors.append("world art asset has no kind: %s" % asset_id)
		var role: StringName = get_asset_role(StringName(asset_id))
		if role.is_empty() or not ArtPalette.REQUIRED_ROLES.has(String(role)):
			errors.append("world art asset has invalid palette role: %s" % asset_id)
	for kind_ids: PackedStringArray in [building_ids, tree_ids, prop_ids, critter_ids]:
		for asset_id: String in kind_ids:
			if not seen.has(asset_id):
				errors.append("world art kind references unknown asset: %s" % asset_id)
	if building_ids.size() < 5 or tree_ids.size() < 1 or prop_ids.size() < 10 or critter_ids.size() != 3:
		errors.append("world art catalog category coverage is incomplete")
	if ambient_effect_cap <= 0 or ambient_effect_cap > 64:
		errors.append("world art ambient effect cap must be between one and sixty-four")
	for asset_id: String in placements:
		if not seen.has(asset_id):
			errors.append("world art placement references unknown asset: %s" % asset_id)
			continue
		var raw_locations: Variant = placements[asset_id]
		if not raw_locations is Array:
			errors.append("world art placement must be an array: %s" % asset_id)
			continue
		for raw_location: Variant in raw_locations as Array:
			if not raw_location is Vector3 or not _is_finite_vector(raw_location as Vector3):
				errors.append("world art placement must be a finite Vector3: %s" % asset_id)
	for color: Color in [spring_effect_color, summer_effect_color, autumn_effect_color, winter_effect_color, rain_ripple_color]:
		if color.a <= 0.0:
			errors.append("world art effect colors must be visible")
	return errors

func _is_finite_vector(value: Vector3) -> bool:
	return _is_finite_float(value.x) and _is_finite_float(value.y) and _is_finite_float(value.z)

func _is_finite_float(value: float) -> bool:
	return value == value and absf(value) < 1000000.0

func _is_snake_case(value: String) -> bool:
	return value == value.to_lower() and not value.contains(" ") and not value.contains("-")
