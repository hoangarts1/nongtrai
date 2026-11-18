## SaveEnvelopeCodec — validates only the JSON envelope, without I/O or migrations.
## API:
##   static func decode(raw: Variant, current_version: int) -> Dictionary
## Result: {ok:bool,error:StringName,version:int,data:Dictionary}; detached on success.
class_name SaveEnvelopeCodec
extends RefCounted

const MAX_JSON_INTEGER: int = 9007199254740991

static func decode(raw: Variant, current_version: int) -> Dictionary:
	if current_version < 0 or current_version > MAX_JSON_INTEGER:
		return _failure(&"invalid_current_version")
	if not raw is Dictionary:
		return _failure(&"invalid_root")
	var data: Dictionary = raw
	var metadata: Variant = data.get("meta", {})
	if not metadata is Dictionary:
		return _failure(&"invalid_meta")
	var value: Variant = metadata.get("save_version", 0)
	if not _valid_version(value):
		return _failure(&"invalid_version")
	var version: int = int(value)
	if version > current_version:
		return _failure(&"unsupported_future", version)
	return {"ok": true, "error": &"", "version": version, "data": data.duplicate(true)}

static func _valid_version(value: Variant) -> bool:
	if value is int:
		return value >= 0 and value <= MAX_JSON_INTEGER
	if value is float:
		return is_finite(value) and value >= 0.0 and value <= MAX_JSON_INTEGER and value == floorf(value)
	return false

static func _failure(error: StringName, version: int = -1) -> Dictionary:
	return {"ok": false, "error": error, "version": version, "data": {}}
