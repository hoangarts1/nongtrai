## EcologyFeedbackProfile — presentation-only bounded 2D silhouette definitions.
class_name EcologyFeedbackProfile
extends Resource

const BINDINGS: Dictionary = {"birds": "tree_cover", "butterflies": "biodiversity"}
const MAX_POLYGON_VERTICES: int = 64
@export var total_cap: int = 14
@export var refresh_seconds: float = 0.5
@export var night_sun_energy: float = 0.3
@export var night_opacity: float = 0.25
@export var rain_opacity: float = 0.45
@export var effects: Array[Dictionary] = []

func validation_errors(ecology: EcologyProfile) -> PackedStringArray:
	var errors: PackedStringArray = []
	if ecology == null or not ecology.validation_errors().is_empty():
		return PackedStringArray(["ecology feedback requires a valid ecology profile"])
	if total_cap <= 0 or total_cap > MAX_POLYGON_VERTICES or not is_finite(refresh_seconds) or refresh_seconds <= 0.0:
		errors.append("ecology feedback cap/refresh must be positive and bounded")
	if not is_finite(night_sun_energy) or night_sun_energy < 0.0 or not _unit(night_opacity) or not _unit(rain_opacity):
		errors.append("ecology feedback lighting must be finite and bounded")
	var seen: Dictionary = {}
	var total: int = 0
	for row: Dictionary in effects:
		var id: Variant = row.get("id")
		if not EcologyMetricData.valid_id(id) or not BINDINGS.has(String(id)) or seen.has(String(id)):
			errors.append("ecology feedback effect is unknown/duplicate; water effects unavailable")
			continue
		seen[String(id)] = true
		if row.get("metric_id") != BINDINGS[String(id)] or row.get("threshold_id") != id:
			errors.append("ecology feedback metric/threshold binding invalid")
		var found: bool = false
		for threshold: Dictionary in ecology.get_thresholds():
			if threshold.id == row.get("threshold_id") and threshold.metric_id == row.get("metric_id"):
				found = true
		if not found:
			errors.append("ecology feedback requires a known matching threshold")
		var count: Variant = row.get("count")
		if not count is int or int(count) <= 0 or int(count) > total_cap:
			errors.append("ecology feedback effect count exceeds cap")
		else:
			total += int(count)
		var anchors: Variant = row.get("anchors")
		if not anchors is PackedFloat32Array or not count is int or anchors.size() != int(count):
			errors.append("ecology feedback requires one normalized anchor per critter")
		else:
			var unique: Dictionary = {}
			for value: float in anchors:
				if not _unit(value) or unique.has(value):
					errors.append("ecology feedback anchors must be finite unique unit fractions")
				unique[value] = true
		for field: String in ["body", "wing"]:
			if not _polygon(row.get(field)):
				errors.append("ecology feedback polygon invalid: " + field)
		for field: String in ["body_color", "wing_color"]:
			var color: Variant = row.get(field)
			if not color is Color or not _unit(color.r) or not _unit(color.g) or not _unit(color.b) or not _unit(color.a):
				errors.append("ecology feedback color invalid: " + field)
		for field: String in ["speed", "flap_speed", "altitude", "scale"]:
			if not EcologyMetricData.number(row.get(field)) or float(row[field]) <= 0.0:
				errors.append("ecology feedback motion must be finite/positive: " + field)
		var span: Variant = row.get("span")
		if not span is Vector2 or not is_finite(span.x) or not is_finite(span.y) or span.x < 0.0 or span.y < 0.0:
			errors.append("ecology feedback span invalid")
	if seen.size() != BINDINGS.size() or total > total_cap:
		errors.append("ecology feedback requires both effects within total cap")
	return errors

static func _unit(value: float) -> bool:
	return is_finite(value) and value >= 0.0 and value <= 1.0

static func _polygon(value: Variant) -> bool:
	if not value is PackedVector2Array or value.size() < 3 or value.size() > MAX_POLYGON_VERTICES:
		return false
	var area: float = 0.0
	for index: int in range(value.size()):
		var point: Vector2 = value[index]
		var next: Vector2 = value[(index + 1) % value.size()]
		if not is_finite(point.x) or not is_finite(point.y) or not is_finite(next.x) or not is_finite(next.y):
			return false
		area += point.cross(next)
	return is_finite(area) and not is_zero_approx(area)
