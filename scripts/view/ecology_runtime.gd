## LifeEcologyRuntime — Main-owned ecology lifecycle adapter; no separate state owner.
## API: configure(state,day); prepare(payload); begin_restore(payload); finish_restore(day,farm,land).
class_name LifeEcologyRuntime
extends RefCounted

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const LEGACY: CropMigrationConfig = preload("res://data/crop_migration_v7.tres")

var busy: bool = false
var last_restore_reason: StringName = &""
var _state: EcologyState
var _pending: Dictionary = {}

func configure(state: EcologyState, day: int) -> bool:
	if busy or state == null or state.is_busy():
		return false
	if not state.configure(PROFILE, day):
		return false
	_state = state
	return true

func prepare(payload: Dictionary) -> Dictionary:
	var clock: Variant = payload.get("clock", {})
	var day: Variant = clock.get("day_index", 0) if clock is Dictionary else null
	if not EcologySnapshotCodec.valid_day(day):
		return {"ok": false, "reason": &"invalid_clock"}
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	var context: Dictionary = EcologySaveContext.capture(payload, crops, LAND, LEGACY)
	return EcologySaveCodec.normalize(PROFILE, SAMPLING, payload.get("ecology"), int(day), crops, context)

func begin_restore(payload: Dictionary) -> Dictionary:
	if busy or _state == null or _state.is_busy():
		return {"ok": false, "reason": &"busy"}
	var result: Dictionary = prepare(payload)
	if result.ok:
		_pending = result.duplicate(true)
		busy = true
	return result

func finish_restore(day: int, farm: FarmGridState, land: LandOwnershipState) -> bool:
	if not busy or _pending.is_empty() or farm == null or land == null:
		return false
	var result: Dictionary = EcologyLifecycle.restore(_state, PROFILE, SAMPLING, _pending.snapshot, day, farm.serialize(), DataRegistry.get_all_crops(), land.get_owned_regions())
	last_restore_reason = _pending.reason if result.ok and result.reason == &"restored" else result.reason
	_pending = {}
	busy = false
	if not result.ok:
		push_warning("Ecology runtime: validated restore rejected: " + String(result.reason))
	return result.ok
