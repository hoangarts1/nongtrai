## WeatherProfile — probabilities and visual effects for each weather id.
## API:
##   func validation_errors() -> PackedStringArray
extends Resource
class_name WeatherProfile

const MAX_WEIGHT_TOTAL: int = 2147483647
@export var initial_weather_id: StringName = &""
@export var forecast_days: int = 0
@export var entries: Array[Dictionary] = []

func get_entry(weather_id: StringName) -> Dictionary:
	for entry: Dictionary in entries:
		if StringName(entry.get("id", "")) == weather_id:
			return entry
	return {}

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if forecast_days<=0 or forecast_days>MAX_WEIGHT_TOTAL:
		errors.append("weather forecast horizon must be a positive bounded integer")
	if entries.is_empty():
		errors.append("weather entries must not be empty")
	var seen: Dictionary = {}
	var total: int = 0
	for index: int in range(entries.size()):
		var entry: Dictionary = entries[index]
		var context: String = "weather entry %d" % index
		var id: Variant = entry.get("id")
		if not _valid_id(id):
			errors.append(context+" has invalid snake_case id")
		else:
			var key: StringName = StringName(id)
			if seen.has(key):
				errors.append(context+" has duplicate weather id "+String(key))
			seen[key] = true
		var probability: Variant = entry.get("probability")
		if not probability is int or probability<0 or probability>MAX_WEIGHT_TOTAL:
			errors.append(context+" probability must be a nonnegative bounded integer")
		elif total>MAX_WEIGHT_TOTAL-probability:
			errors.append(context+" probability total exceeds safe bound")
		else:
			total += probability
		var darkness: Variant = entry.get("darkness")
		if not (darkness is int or darkness is float) or not is_finite(float(darkness)) or float(darkness)<0.0 or float(darkness)>1.0:
			errors.append(context+" darkness must be finite within 0..1")
		var rain: Variant = entry.get("rain")
		var storm: Variant = entry.get("storm")
		if not rain is bool or not storm is bool:
			errors.append(context+" rain/storm flags must be booleans")
		elif bool(storm) and not bool(rain):
			errors.append(context+" storm requires rain")
	if not seen.has(initial_weather_id):
		errors.append("weather initial_weather_id must resolve in profile")
	if total<=0:
		errors.append("weather probabilities must have a positive total")
	return errors

static func _valid_id(value: Variant) -> bool:
	if not value is String and not value is StringName:
		return false
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	return pattern.search(String(value))!=null
