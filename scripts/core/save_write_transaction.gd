## SaveWriteTransaction — staged publication with retained originals and checked rollback.
## API:
##   static func write(store:SaveFileStore,path:String,bytes:PackedByteArray,backup_count:int)->Dictionary
## Report: ok,error,committed,rollback_ok,cleanup_pending,recovery_paths (transient only).
class_name SaveWriteTransaction
extends RefCounted

static func write(store: SaveFileStore, path: String, bytes: PackedByteArray, backup_count: int) -> Dictionary:
	if store == null or path.is_empty() or backup_count < 0:
		return _report(false, &"invalid_write", false, true, PackedStringArray())
	if not store.ensure_parent(path):
		return _report(false, &"directory_failed", false, true, PackedStringArray())
	var paths: PackedStringArray = PackedStringArray([path])
	for index: int in range(1, backup_count + 1):
		paths.append("%s.bak%d" % [path, index])
	var prefix: String = store.staging_prefix(path)
	var originals: Array[Dictionary] = []
	var history: Array[PackedByteArray] = []
	var snapshots: PackedStringArray = PackedStringArray()
	var staged: PackedStringArray = PackedStringArray()
	var moved: PackedStringArray = PackedStringArray()
	var artifacts: PackedStringArray = PackedStringArray()
	for index: int in range(paths.size()):
		snapshots.append("%s.old%d" % [prefix, index])
		staged.append("%s.new%d.tmp" % [prefix, index])
		moved.append("%s.moved%d" % [prefix, index])
		artifacts.append_array(PackedStringArray([snapshots[index], staged[index], moved[index]]))
	for artifact: String in artifacts:
		if store.exists(artifact):
			# A previous recovery copy must never be overwritten or cleaned as our own.
			return _report(false, &"staging_collision", false, true, PackedStringArray([artifact]))
	for target: String in paths:
		var original: Dictionary = {"exists": store.exists(target), "bytes": PackedByteArray()}
		if original.exists:
			var read: Dictionary = store.read_bytes(target)
			if not read.ok:
				return _report(false, &"snapshot_read_failed", false, true, PackedStringArray())
			original.bytes = read.bytes
			history.append(read.bytes)
		originals.append(original)
	var desired: Array[Dictionary] = [{"exists": true, "bytes": bytes}]
	for index: int in range(backup_count):
		desired.append({"exists": index < history.size(), "bytes": history[index] if index < history.size() else PackedByteArray()})
	for index: int in range(paths.size()):
		if originals[index].exists and not store.write_bytes(snapshots[index], originals[index].bytes):
			return _report(false, &"snapshot_write_failed", false, true, _cleanup(store, artifacts))
		if desired[index].exists and not store.write_bytes(staged[index], desired[index].bytes):
			return _report(false, &"staging_write_failed", false, true, _cleanup(store, artifacts))
	var touched: Array[int] = []
	for index: int in range(paths.size()):
		if originals[index].exists:
			if not store.rename_file(paths[index], moved[index]):
				return _failed_publish(store, paths, originals, snapshots, artifacts, touched)
			touched.append(index)
		elif desired[index].exists:
			touched.append(index)
		if desired[index].exists and not store.rename_file(staged[index], paths[index]):
			return _failed_publish(store, paths, originals, snapshots, artifacts, touched)
	# The whole family is published. Cleanup failure retains redundant copies, not a false save failure.
	return _report(true, &"", true, true, _cleanup(store, artifacts))

static func _failed_publish(store: SaveFileStore, paths: PackedStringArray, originals: Array[Dictionary], snapshots: PackedStringArray, artifacts: PackedStringArray, touched: Array[int]) -> Dictionary:
	var rollback_ok: bool = true
	for reverse: int in range(touched.size() - 1, -1, -1):
		var index: int = touched[reverse]
		if store.exists(paths[index]) and not store.remove_file(paths[index]):
			rollback_ok = false
			continue
		if originals[index].exists and not store.rename_file(snapshots[index], paths[index]):
			rollback_ok = false
	if rollback_ok:
		return _report(false, &"publish_failed", false, true, _cleanup(store, artifacts))
	var retained: PackedStringArray = PackedStringArray()
	for artifact: String in artifacts:
		if store.exists(artifact):
			retained.append(artifact)
	return _report(false, &"rollback_failed", false, false, retained)

static func _cleanup(store: SaveFileStore, artifacts: PackedStringArray) -> PackedStringArray:
	var retained: PackedStringArray = PackedStringArray()
	for artifact: String in artifacts:
		if store.exists(artifact) and not store.remove_file(artifact):
			retained.append(artifact)
	return retained

static func _report(ok: bool, error: StringName, committed: bool, rollback_ok: bool, retained: PackedStringArray) -> Dictionary:
	return {"ok": ok, "error": error, "committed": committed, "rollback_ok": rollback_ok, "cleanup_pending": not retained.is_empty(), "recovery_paths": retained.duplicate()}
