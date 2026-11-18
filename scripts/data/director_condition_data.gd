## DirectorConditionData — data-only predicate over explicitly available observations.
class_name DirectorConditionData
extends Resource

const KINDS: PackedStringArray = ["metric_min", "metric_below", "dry_start", "extra_visit"]
const INT32_MAX: int = 2147483647
@export var kind: StringName
@export var metric_id: StringName
@export var threshold_id: StringName

func validation_errors(ecology: EcologyProfile) -> PackedStringArray:
	if not KINDS.has(String(kind)):
		return PackedStringArray(["director condition kind unknown"])
	if String(kind).begins_with("metric_"):
		if metric_id == &"water_clarity" or not threshold_matches(ecology, metric_id, threshold_id):
			return PackedStringArray(["director condition requires a measured known metric/threshold"])
	elif not metric_id.is_empty() or not threshold_id.is_empty():
		return PackedStringArray(["director condition has unused metric fields"])
	return PackedStringArray()

static func threshold_matches(ecology: EcologyProfile, metric: StringName, threshold: StringName) -> bool:
	if ecology != null:
		for row: Dictionary in ecology.get_thresholds():
			if row.metric_id == String(metric) and row.id == String(threshold):
				return true
	return false

static func text_key(value: StringName) -> bool:
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$")
	return pattern.search(String(value)) != null
