## EcologyJournalConfig — localized readout definitions, without gameplay state.
## API: validation_errors(profile); get_translation_keys()->PackedStringArray.
class_name EcologyJournalConfig
extends Resource

const REQUIRED_TEXTS: PackedStringArray = ["title", "entry", "back", "scope", "unmeasured", "water_note", "current", "target", "ease", "next", "active", "below", "waiting", "news_title", "news_summary"]
const COUNTS: Dictionary = {"tree_cover": "mature_fruit_trees", "biodiversity": "species", "water_clarity": ""}
@export var texts: Dictionary = {}
@export var rows: Array[Dictionary] = []

func validation_errors(profile: EcologyProfile) -> PackedStringArray:
	var errors: PackedStringArray = []
	if profile == null or not profile.validation_errors().is_empty():
		return PackedStringArray(["ecology journal requires a valid profile"])
	if texts.size() != REQUIRED_TEXTS.size():
		errors.append("ecology journal requires the complete text set")
	for field: String in REQUIRED_TEXTS:
		if not _key(texts.get(field)):
			errors.append("ecology journal text key missing/invalid: " + field)
	var known: Dictionary = {}
	for row: Dictionary in rows:
		var id: Variant = row.get("id")
		if not EcologyMetricData.valid_id(id) or not COUNTS.has(String(id)) or profile.get_metric(StringName(id)) == null or known.has(String(id)):
			errors.append("ecology journal metric is unknown/duplicate")
			continue
		known[String(id)] = true
		for field: String in ["label_key", "hint_key", "threshold_key"]:
			if not _key(row.get(field)):
				errors.append("ecology journal row translation key invalid")
		if row.get("count_key") != COUNTS[String(id)] or (not String(COUNTS[String(id)]).is_empty() and not _key(row.get("count_text_key"))):
			errors.append("ecology journal count binding invalid")
		var found: bool = false
		for threshold: Dictionary in profile.get_thresholds():
			if row.get("threshold_id") == threshold.id and String(id) == threshold.metric_id:
				found = true
		if not found:
			errors.append("ecology journal threshold must belong to its metric")
	if known.size() != COUNTS.size():
		errors.append("ecology journal requires all three metric definitions")
	return errors

func get_translation_keys() -> PackedStringArray:
	var keys: PackedStringArray = []
	for value: Variant in texts.values():
		if _key(value):
			keys.append(String(value))
	for row: Dictionary in rows:
		for field: String in ["label_key", "hint_key", "threshold_key", "count_text_key"]:
			if _key(row.get(field)):
				keys.append(String(row[field]))
	return keys

static func _key(value: Variant) -> bool:
	if not value is String and not value is StringName:
		return false
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*$")
	return pattern.search(String(value)) != null
