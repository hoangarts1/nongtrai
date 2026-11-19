## StoryLifecycle - references/transient guard only; StoryState remains sole truth.
## API: configure(config,state)->bool; is_busy()->bool; prepare(payload,legacy=false)
## ->Dictionary; restore(candidate)->bool; reset()->bool. No game-save wiring yet.
class_name StoryLifecycle
extends RefCounted
var _config: StoryConfig
var _state: StoryState
var _busy: bool = false
func is_busy() -> bool:
	return _busy or (_state!=null and _state.is_busy())
func configure(config: StoryConfig, state: StoryState) -> bool:
	if is_busy() or state==null or state.is_busy() or not StorySnapshotCodec.decode(config,state.serialize()).ok: return false
	_config = config.frozen_copy()
	_state = state
	return true
func prepare(payload: Dictionary, legacy: bool = false) -> Dictionary:
	if is_busy() or _state==null: return {"ok":false,"reason":&"story_busy_or_unconfigured"}
	return StorySaveCodec.normalize(_config,payload.get("story"),payload,legacy)
func restore(candidate: Dictionary) -> bool:
	if is_busy() or _state==null or typeof(candidate.get("ok"))!=TYPE_BOOL or candidate.get("ok")!=true or not candidate.get("snapshot") is Dictionary: return false
	var decoded: Dictionary = StorySnapshotCodec.decode(_config,candidate.snapshot)
	if not decoded.ok: return false
	_busy = true
	var restored: bool = _state.deserialize(decoded.snapshot)
	_busy = false
	return restored
func reset() -> bool:
	if is_busy() or _state==null: return false
	_busy = true
	var reset_ok: bool = _state.configure(_config)
	_busy = false
	return reset_ok
