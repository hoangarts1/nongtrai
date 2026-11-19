## StoryState - sole serializable story progress/read-page owner, no Nodes or rewards.
## API: configure(config)->bool; observe(ids,expected_revision=-1)->Dictionary;
## acknowledge_page(id,expected_revision=-1)->Dictionary; serialize/deserialize;
## get_revision()->int; is_busy/can_read_page/is_complete()->bool; changed().
class_name StoryState
extends RefCounted
signal changed()
var _config: StoryConfig
var _wire: Dictionary = {}
var _revision: int = 0
var _busy: bool = false
func is_busy() -> bool: return _busy
func get_revision() -> int: return _revision
func configure(config: StoryConfig) -> bool:
	if _busy or not StoryCatalogValidator.validate(config).is_empty(): return false
	_config = config.frozen_copy()
	_wire = StorySnapshotCodec.empty()
	_revision += 1
	return true
func serialize() -> Dictionary:
	return _wire.duplicate(true)
func deserialize(raw: Dictionary) -> bool:
	if _busy or _config==null: return false
	var decoded: Dictionary = StorySnapshotCodec.decode(_config,raw)
	if not decoded.ok: return false
	_wire = decoded.snapshot
	_revision += 1
	return true
func can_read_page(page_id: StringName) -> bool:
	return _config!=null and StoryRules.can_read(_config,_wire,page_id)
func is_complete() -> bool:
	return _config!=null and StoryRules.chapter_complete(_config,_wire)
func observe(objective_ids: PackedStringArray, expected_revision: int = -1) -> Dictionary:
	var ready: Dictionary = _gate(expected_revision)
	if not ready.ok: return ready
	var next: Dictionary = serialize()
	var seen: Dictionary = {}
	for id: String in objective_ids:
		if not _config.supported_ids().has(id) or seen.has(id): return {"ok":false,"reason":&"invalid_story_observation"}
		seen[id] = true
		if not next.completed_objectives.has(id): next.completed_objectives.append(id)
	return _replace(next)
func acknowledge_page(page_id: StringName, expected_revision: int = -1) -> Dictionary:
	var ready: Dictionary = _gate(expected_revision)
	if not ready.ok: return ready
	if not can_read_page(page_id): return {"ok":false,"reason":&"story_page_locked"}
	var next: Dictionary = serialize()
	if not next.read_pages.has(String(page_id)): next.read_pages.append(String(page_id))
	return _replace(next)
func _gate(expected_revision: int) -> Dictionary:
	if _busy or _config==null: return {"ok":false,"reason":&"story_busy_or_unconfigured"}
	if expected_revision < -1 or (expected_revision>=0 and expected_revision!=_revision): return {"ok":false,"reason":&"stale_story_quote"}
	return {"ok":true}
func _replace(next: Dictionary) -> Dictionary:
	var decoded: Dictionary = StorySnapshotCodec.decode(_config,next)
	if not decoded.ok: return decoded
	if decoded.snapshot==_wire: return {"ok":true,"changed":false}
	_busy = true
	_wire = decoded.snapshot
	_revision += 1
	changed.emit()
	_busy = false
	return {"ok":true,"changed":true}
