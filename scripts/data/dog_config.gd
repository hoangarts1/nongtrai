## DogConfig — DATA-only companion policy and existing world references (S21).
## API: validation_errors()->PackedStringArray; frozen_copy()->DogConfig.
class_name DogConfig
extends Resource

const MAX_NAME_CODEPOINTS: int = 24 # STYLE_GUIDE name boundary, not a reward/timing.
@export var world: IsometricWorldConfig
@export var npc_world: NpcWorldData
@export var name_max_length: int = 0
@export var follow_start_distance: int = 0
@export var follow_stop_distance: int = 0
@export var move_speed: float = 0.0
@export var context_interval: float = 0.0
@export var idle_wait_seconds: float = 0.0
@export var idle_radius: int = 0
@export var reaction_seconds: float = 0.0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if world == null or npc_world == null or npc_world.locations == null:
		return PackedStringArray(["dog requires existing world and NPC locations"])
	var region: Rect2i = world.player_region
	if region.size.x <= 0 or region.size.y <= 0 or world.map_region.size.x <= 0 or world.map_region.size.y <= 0 or not world.map_region.encloses(region) or not region.has_point(world.spawn_cell) or not region.has_point(world.debug_home_cell):
		errors.append("dog world bounds/spawn/fallback must fit the playable map")
	if world.tile_size.x <= 0 or world.tile_size.y <= 0:
		errors.append("dog requires positive shared isometric tiles")
	if npc_world.locations.nav_region.size.x <= 0 or npc_world.locations.nav_region.size.y <= 0:
		errors.append("dog requires existing valid NPC navigation context")
	for solid: Rect2i in npc_world.locations.get_solid_regions():
		if solid.size.x <= 0 or solid.size.y <= 0:
			errors.append("dog static obstacle sizes must be positive")
	if name_max_length < 1 or name_max_length > MAX_NAME_CODEPOINTS:
		errors.append("dog name length must fit the approved1-24codepoint limit")
	var span: int = maxi(0, region.size.x - 1) + maxi(0, region.size.y - 1)
	if follow_stop_distance < 1 or follow_start_distance <= follow_stop_distance or follow_start_distance > span:
		errors.append("dog follow distances require start>stop>=1 within the map")
	if idle_radius < 1 or idle_radius > span:
		errors.append("dog idle radius must fit the map")
	for value: float in [move_speed, context_interval, idle_wait_seconds, reaction_seconds]:
		if not is_finite(value) or value <= 0.0:
			errors.append("dog motion/refresh/idle/reaction parameters must be finite positive")
	return errors

func frozen_copy() -> DogConfig:
	return _copy_data(self, {}) as DogConfig

static func _copy_data(value: Variant, copies: Dictionary) -> Variant:
	# duplicate(true) retains external Resources; detach the complete DATA graph,
	# preserving shared references within the copy (water.world == config.world).
	if value is Resource and not value is Script:
		var resource: Resource = value as Resource
		var identity: int = resource.get_instance_id()
		if copies.has(identity):
			return copies[identity]
		var copy: Resource = resource.duplicate(false)
		copies[identity] = copy
		for property: Dictionary in resource.get_property_list():
			var key: String = String(property.name)
			if (int(property.usage) & PROPERTY_USAGE_STORAGE) != 0 and key not in ["script", "resource_path"]:
				copy.set(key, _copy_data(resource.get(key), copies))
		return copy
	if value is Array:
		var copy: Array = value.duplicate()
		for index: int in range(copy.size()):
			copy[index] = _copy_data(value[index], copies)
		return copy
	if value is Dictionary:
		var copy: Dictionary = value.duplicate()
		for key: Variant in copy:
			copy[key] = _copy_data(value[key], copies)
		return copy
	return value
