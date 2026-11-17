## ChickenCoopConfig — data-only daily production terms; no item registration.
class_name ChickenCoopConfig
extends Resource

# External JSON integer precision bound, not a gameplay buffer/capacity cap.
const MAX_JSON_INTEGER: int = 9007199254740991
@export var feed_item_id: StringName = &""
@export var hen_capacity: int = 0
@export var feed_per_hen: int = 0
@export var eggs_per_fed_hen: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if feed_item_id.is_empty():
		errors.append("chicken coop feed item identity is required")
	for field: StringName in [&"hen_capacity",&"feed_per_hen",&"eggs_per_fed_hen"]:
		var value: int = int(get(field))
		if value<=0 or value>MAX_JSON_INTEGER:
			errors.append("chicken coop %s must be a positive JSON-safe integer" % field)
	if errors.is_empty():
		@warning_ignore("integer_division")
		var max_feed_hens: int = MAX_JSON_INTEGER/feed_per_hen
		@warning_ignore("integer_division")
		var max_egg_hens: int = MAX_JSON_INTEGER/eggs_per_fed_hen
		if hen_capacity>max_feed_hens or hen_capacity>max_egg_hens:
			errors.append("chicken coop full-herd feed/output exceeds JSON integer precision")
	return errors
