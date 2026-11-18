## SaveLoadResolver — read-only primary/backup selection through the same envelope codec.
## API:
##   static func resolve(path:String,current_version:int,migrate:Callable,backup_count:int,reader:Callable=Callable()) -> Dictionary
##   static func read_file(path:String) -> Dictionary
## Result: {payload:Dictionary,report:{status,error,source_index,attempts}}; no file writes.
class_name SaveLoadResolver
extends RefCounted

static func resolve(path: String, current_version: int, migrate: Callable, backup_count: int, reader: Callable = Callable()) -> Dictionary:
	var read: Callable = reader if reader.is_valid() else read_file
	var attempts: Array[Dictionary] = []
	if backup_count < 0 or not migrate.is_valid():
		return _result({}, &"error", &"invalid_resolver", -1, attempts)
	for index: int in range(backup_count + 1):
		var candidate: String = path if index == 0 else "%s.bak%d" % [path, index]
		var file: Dictionary = read.call(candidate)
		if not bool(file.get("exists", false)):
			attempts.append({"source_index": index, "error": &"missing"})
			if index == 0:
				return _result({}, &"missing", &"missing", -1, attempts)
			continue
		var error: StringName = &"read_failed"
		if bool(file.get("ok", false)):
			var parser: JSON = JSON.new()
			if parser.parse(String(file.get("text", ""))) == OK:
				var decoded: Dictionary = SaveEnvelopeCodec.decode(parser.data, current_version)
				error = decoded.error
				if decoded.ok:
					var payload: Dictionary = migrate.call(decoded.data, decoded.version)
					if not payload.is_empty():
						attempts.append({"source_index": index, "error": &""})
						return _result(payload, &"primary" if index == 0 else &"recovered", &"", index, attempts)
					error = &"migration_failed"
			else:
				error = &"invalid_json"
		attempts.append({"source_index": index, "error": error})
		if index == 0 and error == &"unsupported_future":
			return _result({}, &"error", error, -1, attempts)
	return _result({}, &"error", &"no_valid_save", -1, attempts)

static func read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"exists": false, "ok": false}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": true, "ok": false}
	var text: String = file.get_as_text()
	var error: Error = file.get_error()
	file.close()
	return {"exists": true, "ok": error == OK or error == ERR_FILE_EOF, "text": text}

static func _result(payload: Dictionary, status: StringName, error: StringName, source_index: int, attempts: Array[Dictionary]) -> Dictionary:
	return {"payload": payload.duplicate(true), "report": {"status": status, "error": error, "source_index": source_index, "attempts": attempts.duplicate(true)}}
