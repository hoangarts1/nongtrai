## DataValidator — validates shipped gameplay Resources before tests or builds.
## API:
##   static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray
##   static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray
class_name DataValidator
extends RefCounted

static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var ids: Dictionary = {}
	for item_data: Resource in resources:
		if item_data == null:
			errors.append("item resource is missing")
			continue
		var resource_id: String = _resource_identifier(item_data)
		if resource_id.is_empty():
			errors.append("item/crop id is empty")
		elif not _is_snake_case(resource_id):
			errors.append("item/crop id is not snake_case: %s" % resource_id)
		elif ids.has(resource_id):
			errors.append("duplicate item/crop id: %s" % resource_id)
		else:
			ids[resource_id] = true
		var max_stack: Variant = item_data.get("max_stack")
		if max_stack != null:
			if int(max_stack) <= 0:
				errors.append("item max_stack must be positive: %s" % resource_id)
	return errors

static func validate_item_paths(paths: Array[String]) -> PackedStringArray:
	var resources: Array[Resource] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			resources.append(null)
			continue
		var resource: Resource = load(path)
		if resource == null:
			resources.append(null)
			continue
		resources.append(resource)
	return validate_item_resources(resources)

static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var found_keys: Dictionary = {}
	for path: String in paths:
		if not FileAccess.file_exists(path):
			errors.append("missing translation file: %s" % path)
			continue
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null:
			errors.append("unable to read translation file: %s" % path)
			continue
		var header: String = file.get_line()
		if header.strip_edges().is_empty():
			continue
		while not file.eof_reached():
			var line: String = file.get_line()
			if line.strip_edges().is_empty():
				continue
			var fields: PackedStringArray = _parse_csv_line(line)
			if fields.size() < 2:
				continue
			var key: String = fields[0].strip_edges()
			if not key.is_empty():
				found_keys[key] = true
	for key: String in required_keys:
		if not found_keys.has(key):
			errors.append("missing translation key: %s" % key)
	return errors

static func validate_vietnamese_values(english_path: String, vietnamese_path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var english: Dictionary = _read_translation_values(english_path)
	var vietnamese: Dictionary = _read_translation_values(vietnamese_path)
	for key: String in english:
		if not vietnamese.has(key) or String(vietnamese[key]).strip_edges().is_empty():
			errors.append("missing Vietnamese translation: %s" % key)
	return errors

static func _read_translation_values(path: String) -> Dictionary:
	var values: Dictionary = {}
	if not FileAccess.file_exists(path):
		return values
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return values
	file.get_line()
	while not file.eof_reached():
		var fields: PackedStringArray = _parse_csv_line(file.get_line())
		if fields.size() >= 2 and not fields[0].strip_edges().is_empty():
			values[fields[0].strip_edges()] = fields[1].strip_edges()
	return values

static func _parse_csv_line(line: String) -> PackedStringArray:
	var parts: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	for index: int in range(line.length()):
		var character: String = line.substr(index, 1)
		if character == "\"":
			if in_quotes and index + 1 < line.length() and line.substr(index + 1, 1) == "\"":
				current += "\""
				index += 1
			else:
				in_quotes = not in_quotes
		elif character == "," and not in_quotes:
			parts.append(current)
			current = ""
		else:
			current += character
	parts.append(current)
	return parts

static func _resource_identifier(resource: Resource) -> String:
	var item_id: Variant = resource.get("item_id")
	if item_id != null and String(item_id) != "":
		return String(item_id)
	var crop_id: Variant = resource.get("crop_id")
	if crop_id != null and String(crop_id) != "":
		return String(crop_id)
	return ""

static func _is_snake_case(value: String) -> bool:
	return value == value.to_lower() and not value.contains(" ") and not value.contains("-")
