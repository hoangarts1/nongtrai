## SceneryArtCatalog — supplied scenery schema and view-only layout data.
## API:
##   func validation_errors() -> PackedStringArray
##   func get_entry(id: StringName) -> Dictionary
class_name SceneryArtCatalog
extends Resource

const MAX_HASH_TERM: int = 1000000000
const KINDS: PackedStringArray = ["rock", "grass_clump", "flower", "pebble", "tuft", "object"]
@export var entries: Array[Dictionary] = []
@export var bands: Array[Dictionary] = []
@export var bucket_count: int = 100
@export var hash_multipliers: Vector2i
@export var hash_bias: int = 0
@export var size_offset: Vector2i
@export var sizes: PackedStringArray = []
@export var tall_ids: PackedStringArray = []

func get_entry(id: StringName) -> Dictionary:
	for entry: Dictionary in entries:
		if entry.get("id") == id:
			return entry.duplicate(true)
	return {}

static func required_ids() -> PackedStringArray:
	var result: PackedStringArray = []
	for kind: String in ["rock", "grass_clump"]:
		for size: String in ["small", "medium", "large"]:
			for variant: int in range(1, 4):
				result.append("%s_%s_%d" % [kind, size, variant])
	for kind: String in ["flower", "pebble", "tuft"]:
		for variant: int in range({"flower":4, "pebble":2, "tuft":3}[kind]):
			result.append("%s_%d" % [kind, variant])
	result.append_array(["bush", "tree_fruit"])
	return result

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	var required: PackedStringArray = required_ids()
	var seen: Dictionary = {}
	var paths: Dictionary = {}
	for entry: Dictionary in entries:
		var id: Variant = entry.get("id")
		if not (id is String or id is StringName) or not required.has(String(id)) or seen.has(id):
			errors.append("scenery entry has unknown/duplicate id")
		seen[id] = true
		var path: Variant = entry.get("path")
		if not path is String or not path.begins_with("res://assets/") or path.contains("..") or path.get_file() != str(id)+".png" or paths.has(path):
			errors.append("scenery entry has invalid/duplicate canonical PNG path")
		paths[path] = true
		if not KINDS.has(str(entry.get("kind", ""))):
			errors.append("scenery entry has unknown kind")
		if (id is String or id is StringName) and required.has(str(id)):
			var key: String = str(id)
			var expected_kind: String = "object" if key in ["bush", "tree_fruit"] else key.rsplit("_", true, 1)[0]
			var expected_variant: int = 0 if expected_kind == "object" else key.get_slice("_", key.get_slice_count("_")-1).to_int()
			var expected_size: String = ""
			if key.begins_with("rock_") or key.begins_with("grass_clump_"):
				expected_size = key.get_slice("_", key.get_slice_count("_")-2)
				expected_kind = "rock" if key.begins_with("rock_") else "grass_clump"
				expected_variant -= 1
			var directory: String = {"rock":"rocks", "grass_clump":"grass_clumps", "object":"objects"}.get(expected_kind, "decor")
			if str(entry.get("kind")) != expected_kind or str(entry.get("size")) != expected_size or entry.get("variant") != expected_variant or path != "res://assets/%s/%s.png" % [directory, key]:
				errors.append("scenery member metadata must match its canonical ID")
		var dimensions: Variant = entry.get("image_size")
		var pivot: Variant = entry.get("pivot")
		var scale_value: Variant = entry.get("scale")
		if not dimensions is Vector2i or dimensions.x <= 0 or dimensions.y <= 0:
			errors.append("scenery entry requires positive image dimensions")
		if not pivot is Vector2 or not pivot.is_finite() or pivot.x < 0 or pivot.y < 0 or (dimensions is Vector2i and (pivot.x > dimensions.x or pivot.y > dimensions.y)):
			errors.append("scenery pivot must be finite and inside its canvas")
		if not scale_value is Vector2 or not scale_value.is_finite() or scale_value.x <= 0 or scale_value.y <= 0:
			errors.append("scenery scale must be finite and positive")
		if not entry.get("blocks") is bool or bool(entry.get("blocks", false)) != (str(id).begins_with("rock_large_")):
			errors.append("scenery blocking policy must preserve only large rocks")
		if not entry.get("variant") is int or int(entry.get("variant", -1)) < 0:
			errors.append("scenery variant requires a nonnegative integer")
		var size: Variant = entry.get("size")
		if not (size is String or size is StringName) or (entry.get("kind") in [&"rock", &"grass_clump"] and not sizes.has(String(size))):
			errors.append("scenery size is invalid")
	for id: String in required:
		if not seen.has(StringName(id)):
			errors.append("scenery member missing: "+id)
	if bucket_count <= 0 or bucket_count > MAX_HASH_TERM:
		errors.append("scenery bucket count is invalid")
	if hash_multipliers.x <= 0 or hash_multipliers.y <= 0 or hash_multipliers.x > MAX_HASH_TERM or hash_multipliers.y > MAX_HASH_TERM or hash_bias < -MAX_HASH_TERM or hash_bias > MAX_HASH_TERM:
		errors.append("scenery hash terms exceed safe integer bounds")
	if sizes != PackedStringArray(["small", "medium", "large"]) or tall_ids != PackedStringArray(["bush", "tree_fruit"]):
		errors.append("scenery size/tall-object order must preserve the supplied contract")
	var previous: int = 0
	var kinds: PackedStringArray = []
	for band: Dictionary in bands:
		var end: Variant = band.get("end")
		var kind: String = String(band.get("kind", ""))
		if not end is int or end <= previous or end > bucket_count or not KINDS.has(kind) or kind == "object" or kinds.has(kind) or not band.get("offset") is Vector2i:
			errors.append("scenery bands require ordered bounded ends, unique kinds and offsets")
		if end is int:
			previous = end
		kinds.append(kind)
	if kinds != PackedStringArray(["rock", "grass_clump", "flower", "pebble", "tuft"]):
		errors.append("scenery bands must cover the five supplied scattered kinds")
	return errors
