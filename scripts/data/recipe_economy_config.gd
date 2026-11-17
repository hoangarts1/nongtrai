## RecipeEconomyConfig — approved validation tiers and daily-to-hour conversion.
## API: validation_errors() -> PackedStringArray
class_name RecipeEconomyConfig
extends Resource
const MAX_RULE_INTEGER: int = 2147483647
@export var max_value_added_per_game_hour_by_unlock_level: Dictionary = {}
@export var game_hours_per_day: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if game_hours_per_day<=0 or game_hours_per_day>MAX_RULE_INTEGER:
		errors.append("recipe economy requires positive bounded game_hours_per_day")
	# These are schema tier identities; all actual ceilings are Resource-owned.
	if max_value_added_per_game_hour_by_unlock_level.size()!=3:
		errors.append("recipe economy requires exactly unlock tiers 1/2/3")
	for level: int in [1,2,3]:
		var cap: Variant = max_value_added_per_game_hour_by_unlock_level.get(level)
		if not cap is int or cap<=0 or cap>MAX_RULE_INTEGER:
			errors.append("recipe economy tier %d requires positive bounded integer cap" % level)
	for key: Variant in max_value_added_per_game_hour_by_unlock_level:
		if not key is int or key<1 or key>3:
			errors.append("recipe economy has unknown/noninteger unlock tier")
	return errors
