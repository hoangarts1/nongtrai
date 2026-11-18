## EcologyMetricData — normalized metric tuning and thresholds, not world state.
## API: validation_errors()->PackedStringArray; static valid_id(value)->bool.
class_name EcologyMetricData
extends Resource

# Percentage unit conversion, not a tuning default.
const PERCENT_SCALE: float = 100.0
@export var metric_id: StringName
@export var minimum: float
@export var maximum: float
@export var initial_value: float
@export var ease_percent: float
@export var thresholds: Array[Dictionary] = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if not valid_id(metric_id):
		errors.append("ecology metric requires a snake_case id")
	if not is_finite(minimum) or not is_finite(maximum) or minimum < 0.0 or maximum > PERCENT_SCALE or minimum >= maximum:
		errors.append("ecology metric bounds must be ordered in normalized percentage range")
	if not is_finite(initial_value) or initial_value < minimum or initial_value > maximum:
		errors.append("ecology initial value must be finite and within bounds")
	if not is_finite(ease_percent) or ease_percent <= 0.0 or ease_percent > PERCENT_SCALE:
		errors.append("ecology ease percentage must be finite in (0,100]")
	var seen: Dictionary = {}
	for row: Dictionary in thresholds:
		var id: Variant = row.get("id")
		if not valid_id(id):
			errors.append("ecology threshold requires a snake_case id")
		elif seen.has(String(id)):
			errors.append("duplicate ecology threshold id")
		else:
			seen[String(id)] = true
		var value: Variant = row.get("value")
		if not number(value) or float(value) < minimum or float(value) > maximum:
			errors.append("ecology threshold must be a finite number within bounds")
	return errors

static func number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func valid_id(value: Variant) -> bool:
	if not value is String and not value is StringName:
		return false
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(String(value)) != null
