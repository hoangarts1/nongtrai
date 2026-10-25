## DataValidator — validates shipped gameplay Resources before tests or builds.
## API:
##   static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray
class_name DataValidator
extends RefCounted

static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var ids: Dictionary = {}
	for item_data: Resource in resources:
		if item_data == null:
			errors.append("item resource is missing")
			continue
		var item_id: String = String(item_data.get("item_id"))
		if item_id.is_empty():
			errors.append("item id is empty")
		elif not _is_snake_case(item_id):
			errors.append("item id is not snake_case: %s" % item_id)
		elif ids.has(item_id):
			errors.append("duplicate item id: %s" % item_id)
		else:
			ids[item_id] = true
		var max_stack: int = int(item_data.get("max_stack"))
		if max_stack <= 0:
			errors.append("item max_stack must be positive: %s" % item_id)
	return errors

static func validate_item_paths(paths: Array[String]) -> PackedStringArray:
	var resources: Array[Resource] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			resources.append(null)
			continue
		resources.append(load(path) as Resource)
	return validate_item_resources(resources)

static func _is_snake_case(value: String) -> bool:
	return value == value.to_lower() and not value.contains(" ") and not value.contains("-")
