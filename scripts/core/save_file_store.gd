## SaveFileStore — replaceable filesystem adapter for checked save transactions.
## API: ensure_parent(path), exists(path), read_bytes(path), write_bytes(path,bytes),
## rename_file(source,target), remove_file(path), staging_prefix(path).
class_name SaveFileStore
extends RefCounted

func ensure_parent(path: String) -> bool:
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())) == OK

func exists(path: String) -> bool:
	return FileAccess.file_exists(path)

func read_bytes(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "bytes": PackedByteArray()}
	var length: int = file.get_length()
	var bytes: PackedByteArray = file.get_buffer(length)
	var error: Error = file.get_error()
	file.close()
	return {"ok": bytes.size() == length and (error == OK or error == ERR_FILE_EOF), "bytes": bytes}

func write_bytes(path: String, bytes: PackedByteArray) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(bytes)
	file.flush()
	var stored: bool = file.get_error() == OK and file.get_position() == bytes.size()
	file.close()
	if not stored:
		return false
	# close() exposes no error result; reopening verifies the persisted bytes we can observe.
	var checked: Dictionary = read_bytes(path)
	return checked.ok and checked.bytes == bytes

func rename_file(source: String, target: String) -> bool:
	if exists(target):
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(target)) == OK

func remove_file(path: String) -> bool:
	return not exists(path) or DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK

func staging_prefix(path: String) -> String:
	return "%s.txn_%d" % [path, Time.get_ticks_usec()]
