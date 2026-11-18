## SceneryPlacementRules — stateless cosmetic selection, never gameplay RNG/state.
## API:
##   static func compile(catalog: SceneryArtCatalog) -> Dictionary
##   static func cell_hash(config: Dictionary, cell: Vector2i, offset: Vector2i = Vector2i.ZERO) -> int
##   static func select(config: Dictionary, cell: Vector2i, include_decor: bool = false) -> Dictionary
class_name SceneryPlacementRules
extends RefCounted

static func compile(catalog: SceneryArtCatalog) -> Dictionary:
	if catalog == null or not catalog.validation_errors().is_empty():
		return {}
	var entries: Dictionary = {}
	var groups: Dictionary = {}
	for entry: Dictionary in catalog.entries:
		entries[StringName(entry.id)] = entry.duplicate(true)
		var group: String = "%s:%s" % [entry.kind, entry.size]
		if not groups.has(group):
			groups[group] = []
		groups[group].append(entries[StringName(entry.id)])
	return {"entries":entries, "groups":groups, "bands":catalog.bands.duplicate(true), "bucket_count":catalog.bucket_count, "multipliers":catalog.hash_multipliers, "bias":catalog.hash_bias, "size_offset":catalog.size_offset, "sizes":catalog.sizes.duplicate()}

static func cell_hash(config: Dictionary, cell: Vector2i, offset: Vector2i = Vector2i.ZERO) -> int:
	var factors: Variant = config.get("multipliers")
	var bias: Variant = config.get("bias")
	if not factors is Vector2i or not bias is int or factors.x <= 0 or factors.y <= 0 or factors.x > SceneryArtCatalog.MAX_HASH_TERM or factors.y > SceneryArtCatalog.MAX_HASH_TERM or bias < -SceneryArtCatalog.MAX_HASH_TERM or bias > SceneryArtCatalog.MAX_HASH_TERM:
		return -1
	# Promote each component before adding offsets: Vector2i addition can wrap.
	# Two int32 components/offsets times <=1e9 still fit signed int64.
	return absi((int(cell.x)+int(offset.x))*int(factors.x) + (int(cell.y)+int(offset.y))*int(factors.y) + int(bias))

static func select(config: Dictionary, cell: Vector2i, include_decor: bool = false) -> Dictionary:
	var value: int = cell_hash(config, cell)
	var count: Variant = config.get("bucket_count")
	if value < 0 or not count is int or count <= 0 or not config.get("bands") is Array or not config.get("entries") is Dictionary:
		return {}
	var bucket: int = value % int(count)
	for raw: Variant in config.bands:
		if not raw is Dictionary:
			return {}
		var band: Dictionary = raw
		if not band.get("end") is int or not band.get("offset") is Vector2i:
			return {}
		if bucket >= int(band.end):
			continue
		var kind: StringName = StringName(band.get("kind", ""))
		if not include_decor and kind not in [&"rock", &"grass_clump"]:
			return {}
		var candidates: Array[Dictionary] = []
		var size: String = ""
		if kind in [&"rock", &"grass_clump"]:
			if not config.get("sizes") is PackedStringArray or config.sizes.is_empty() or not config.get("size_offset") is Vector2i:
				return {}
			size = config.sizes[cell_hash(config, cell, config.size_offset) % config.sizes.size()]
		if not config.get("groups") is Dictionary:
			return {}
		for entry: Variant in config.groups.get("%s:%s" % [kind, size], []):
			if not entry is Dictionary:
				return {}
			candidates.append(entry)
		if candidates.is_empty():
			return {}
		return candidates[cell_hash(config, cell, band.offset) % candidates.size()].duplicate(true)
	return {}
