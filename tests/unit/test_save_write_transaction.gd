extends GutTest

class MemoryStore extends SaveFileStore:
	var files: Dictionary = {}
	var calls: Array[String] = []
	var fail_calls: Array[int] = []

	func operation(label: String) -> bool:
		calls.append(label)
		return not fail_calls.has(calls.size())

	func ensure_parent(_path: String) -> bool:
		return operation("mkdir")

	func exists(path: String) -> bool:
		return files.has(path)

	func read_bytes(path: String) -> Dictionary:
		if not operation("read:" + path) or not files.has(path):
			return {"ok": false, "bytes": PackedByteArray()}
		return {"ok": true, "bytes": files[path].duplicate()}

	func write_bytes(path: String, bytes: PackedByteArray) -> bool:
		if not operation("write:" + path):
			files[path] = "partial".to_utf8_buffer()
			return false
		files[path] = bytes.duplicate()
		return true

	func rename_file(source: String, target: String) -> bool:
		if not operation("rename:" + source + ">" + target) or not files.has(source) or files.has(target):
			return false
		files[target] = files[source]
		files.erase(source)
		return true

	func remove_file(path: String) -> bool:
		if not operation("remove:" + path):
			return false
		files.erase(path)
		return true

	func staging_prefix(path: String) -> String:
		return path + ".txn_probe"

func _store() -> MemoryStore:
	var store: MemoryStore = MemoryStore.new()
	for index: int in range(4):
		store.files[_path(index)] = ("old%d" % index).to_utf8_buffer()
	return store

func _path(index: int) -> String:
	return "slot" if index == 0 else "slot.bak%d" % index

func _family(store: MemoryStore) -> Dictionary:
	var result: Dictionary = {}
	for index: int in range(4):
		if store.files.has(_path(index)):
			result[_path(index)] = store.files[_path(index)].duplicate()
	return result

func _desired() -> Dictionary:
	return {"slot": "new".to_utf8_buffer(), "slot.bak1": "old0".to_utf8_buffer(), "slot.bak2": "old1".to_utf8_buffer(), "slot.bak3": "old2".to_utf8_buffer()}

func test_success_publishes_primary_and_three_ordered_backups_then_cleans_copies() -> void:
	var store: MemoryStore = _store()
	var report: Dictionary = SaveWriteTransaction.write(store, "slot", "new".to_utf8_buffer(), 3)
	assert_true(report.ok)
	assert_true(report.committed)
	assert_true(report.rollback_ok)
	assert_false(report.cleanup_pending)
	assert_eq(report.recovery_paths, PackedStringArray())
	assert_eq(store.files, _desired())
	var first_rename: int = -1
	var last_write: int = -1
	for index: int in range(store.calls.size()):
		if store.calls[index].begins_with("write:"):
			last_write = index
		if store.calls[index].begins_with("rename:") and first_rename < 0:
			first_rename = index
	assert_gt(first_rename, last_write, "All restorable copies/new bytes precede publication")

func test_every_single_io_fault_preserves_originals_or_reports_committed_cleanup_pending() -> void:
	var success: MemoryStore = _store()
	assert_true(SaveWriteTransaction.write(success, "slot", "new".to_utf8_buffer(), 3).ok)
	assert_gt(success.calls.size(), 20)
	for failing: int in range(1, success.calls.size() + 1):
		var store: MemoryStore = _store()
		var before: Dictionary = store.files.duplicate(true)
		store.fail_calls = [failing]
		var report: Dictionary = SaveWriteTransaction.write(store, "slot", "new".to_utf8_buffer(), 3)
		if report.ok:
			assert_true(report.committed)
			assert_true(report.cleanup_pending, "Only postcommit cleanup may succeed after a fault")
			assert_eq(_family(store), _desired())
			assert_false(report.recovery_paths.is_empty())
			for path: String in report.recovery_paths:
				assert_true(store.files.has(path))
		else:
			assert_false(report.committed)
			assert_true(report.rollback_ok, "One fault must not also break rollback")
			assert_eq(store.files, before, "Precommit fault %d must preserve all family bytes" % failing)

func test_rollback_rename_or_remove_failure_retains_good_recovery_copies() -> void:
	for faults: Array in [[15, 16], [17, 19]]:
		var store: MemoryStore = _store()
		store.fail_calls.assign(faults)
		var report: Dictionary = SaveWriteTransaction.write(store, "slot", "new".to_utf8_buffer(), 3)
		assert_false(report.ok)
		assert_false(report.committed)
		assert_false(report.rollback_ok)
		assert_eq(report.error, &"rollback_failed")
		assert_true(report.cleanup_pending)
		assert_false(report.recovery_paths.is_empty())
		for index: int in range(4):
			var preserved: bool = store.files.get(_path(index)) == ("old%d" % index).to_utf8_buffer()
			for path: String in report.recovery_paths:
				assert_true(store.files.has(path))
				preserved = preserved or store.files[path] == ("old%d" % index).to_utf8_buffer()
			assert_true(preserved, "Retain every original even when rollback cannot publish it")

func test_new_slot_missing_primary_holes_and_staging_collision_do_not_destroy_history() -> void:
	var empty: MemoryStore = MemoryStore.new()
	assert_true(SaveWriteTransaction.write(empty, "slot", "new".to_utf8_buffer(), 3).ok)
	assert_eq(empty.files, {"slot": "new".to_utf8_buffer()})
	var hole: MemoryStore = MemoryStore.new()
	hole.files["slot.bak3"] = "oldest".to_utf8_buffer()
	assert_true(SaveWriteTransaction.write(hole, "slot", "new".to_utf8_buffer(), 3).ok)
	assert_eq(hole.files, {"slot": "new".to_utf8_buffer(), "slot.bak1": "oldest".to_utf8_buffer()})
	var collision: MemoryStore = _store()
	collision.files["slot.txn_probe.old0"] = "recovery".to_utf8_buffer()
	var before: Dictionary = collision.files.duplicate(true)
	assert_eq(SaveWriteTransaction.write(collision, "slot", "new".to_utf8_buffer(), 3).error, &"staging_collision")
	assert_eq(collision.files, before)
	assert_false(SaveWriteTransaction.write(collision, "slot", PackedByteArray(), -1).ok)
	assert_false(SaveWriteTransaction.write(null, "slot", PackedByteArray(), 3).ok)

func test_real_windows_rename_readback_and_three_backup_rotations_preserve_json() -> void:
	var store: SaveFileStore = SaveFileStore.new()
	var path: String = "user://transaction_%d.json" % Time.get_ticks_usec()
	for version: int in range(1, 6):
		var text: String = JSON.stringify({"version": version, "name": "Mùa ẩn ệ ữ"})
		var report: Dictionary = SaveWriteTransaction.write(store, path, text.to_utf8_buffer(), 3)
		assert_true(report.ok)
		assert_false(report.cleanup_pending)
		assert_eq(store.read_bytes(path).bytes, text.to_utf8_buffer())
		for backup: int in range(1, mini(version, 4)):
			var raw: Variant = JSON.parse_string(store.read_bytes("%s.bak%d" % [path, backup]).bytes.get_string_from_utf8())
			assert_eq(int(raw.version), version - backup)
	for index: int in range(4):
		assert_true(store.remove_file(path if index == 0 else "%s.bak%d" % [path, index]))
	var single: String = path + ".single"
	assert_true(SaveWriteTransaction.write(store, single, "first".to_utf8_buffer(), 0).ok)
	assert_true(SaveWriteTransaction.write(store, single, "second".to_utf8_buffer(), 0).ok)
	assert_eq(store.read_bytes(single).bytes, "second".to_utf8_buffer())
	assert_true(store.remove_file(single))

func test_facade_report_is_detached_and_invalid_slot_does_not_claim_success() -> void:
	assert_false(SaveService.save_game({}, -1))
	var report: Dictionary = SaveService.get_write_report()
	assert_false(report.ok)
	assert_eq(report.error, &"invalid_slot")
	report["ok"] = true
	assert_false(SaveService.get_write_report().ok)
