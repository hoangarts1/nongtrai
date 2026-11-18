## DirectorActivityConfig — observation window and registered counter identities (S14).
## API: validation_errors()->PackedStringArray; valid_id(value)->bool.
class_name DirectorActivityConfig
extends Resource

# S14 defines the supported window range; the chosen window lives in the Resource.
const MIN_WINDOW_DAYS: int = 7
const MAX_WINDOW_DAYS: int = 14
const SOURCE_IDS: PackedStringArray = ["plot_tilled", "crop_planted", "plot_watered", "crop_harvested", "item_purchased", "item_sold"]
@export var window_days: int = 0
@export var activity_ids: PackedStringArray = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if window_days < MIN_WINDOW_DAYS or window_days > MAX_WINDOW_DAYS:
		errors.append("director activity window must be within S14's7-14days")
	var seen: Dictionary = {}
	for id: String in activity_ids:
		if not valid_id(id) or not SOURCE_IDS.has(id) or seen.has(id):
			errors.append("director activity id is unknown/invalid/duplicate: " + id)
		seen[id] = true
	if activity_ids.size() != SOURCE_IDS.size() or seen.size() != SOURCE_IDS.size():
		errors.append("director activity requires all six registered source identities")
	return errors

static func valid_id(value: Variant) -> bool:
	if not value is String and not value is StringName:
		return false
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(String(value)) != null
