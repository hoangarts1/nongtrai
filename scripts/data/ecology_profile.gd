## EcologyProfile — validated set of metrics and globally unique threshold identities.
## API: validation_errors(); get_metric(id); get_thresholds()->Array[Dictionary].
class_name EcologyProfile
extends Resource

@export var metrics: Array[Resource] = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if metrics.is_empty():
		errors.append("ecology profile must contain metrics")
	var ids: Dictionary = {}
	var thresholds: Dictionary = {}
	for resource: Resource in metrics:
		var metric: EcologyMetricData = resource as EcologyMetricData
		if metric == null:
			errors.append("ecology profile contains a missing/wrong metric resource")
			continue
		errors.append_array(metric.validation_errors())
		if ids.has(metric.metric_id):
			errors.append("duplicate ecology metric id")
		ids[metric.metric_id] = true
		for row: Dictionary in metric.thresholds:
			if EcologyMetricData.valid_id(row.get("id")):
				var id: String = String(row.id)
				if thresholds.has(id):
					errors.append("ecology threshold ids must be unique across metrics")
				thresholds[id] = true
	return errors

func get_metric(id: StringName) -> EcologyMetricData:
	for resource: Resource in metrics:
		var metric: EcologyMetricData = resource as EcologyMetricData
		if metric != null and metric.metric_id == id:
			return metric
	return null

func get_thresholds() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not validation_errors().is_empty():
		return result
	for resource: Resource in metrics:
		var metric: EcologyMetricData = resource as EcologyMetricData
		if metric != null:
			for row: Dictionary in metric.thresholds:
				result.append({"metric_id": String(metric.metric_id), "id": String(row.id), "value": float(row.value)})
	return result
