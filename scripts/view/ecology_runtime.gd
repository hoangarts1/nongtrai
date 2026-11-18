## LifeEcologyRuntime — Main-owned ecology lifecycle adapter; no separate state owner.
## API: configure(state,day); prepare(payload); begin_restore(payload); finish_restore(day,farm,land).
## begin_day(day,farm,land); finish_day(day,farm); abort_day().
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
var _day_token: int = -1
var _day_config: EcologySamplingConfig
var _day_crops: Array[Resource] = []
var _day_regions: Array[Rect2i] = []

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

func begin_day(day: int, farm: FarmGridState, land: LandOwnershipState) -> Dictionary:
	if busy or _state == null or farm == null or land == null:
		return {"ok": false, "reason": &"busy_or_missing_owner"}
	var quote: Dictionary = _state.day_quote(day)
	if not quote.ok:
		return quote
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	var regions: Array[Rect2i] = land.get_owned_regions()
	var sample: Dictionary = EcologySampler.sample(SAMPLING, farm.serialize(), crops, regions, _state.get_metrics())
	if not sample.ok:
		return {"ok": false, "reason": &"invalid_context"}
	var reservation: Dictionary = _state.begin_day(day)
	if not reservation.ok:
		return reservation
	# Freeze sampling inputs before farm callbacks; keep texture Resources out of copies.
	_day_config = SAMPLING.duplicate(true) as EcologySamplingConfig
	_day_config.species_aliases = SAMPLING.species_aliases.duplicate(true)
	_day_crops.clear()
	for resource: Resource in crops:
		var source: CropData = resource as CropData
		var frozen: CropData = CropData.new()
		frozen.crop_id = source.crop_id
		frozen.growth_days = source.growth_days
		frozen.regrow_days = source.regrow_days
		frozen.perennial = source.perennial
		_day_crops.append(frozen)
	_day_regions = regions.duplicate()
	_day_token = int(reservation.token)
	busy = true
	return reservation

func finish_day(day: int, farm: FarmGridState) -> Dictionary:
	if not busy or _day_token < 0 or farm == null or day != _state.get_day_index() + 1:
		return {"ok": false, "reason": &"invalid_day_context"}
	var sample: Dictionary = EcologySampler.sample(_day_config, farm.serialize(), _day_crops, _day_regions, _state.get_metrics())
	if not sample.ok:
		return {"ok": false, "reason": &"invalid_finished_farm"}
	var result: Dictionary = _state.finish_day(_day_token, sample.targets)
	if result.ok:
		result["sample"] = sample
		_clear_day()
	return result

func abort_day() -> bool:
	if not busy or _day_token < 0 or not _state.abort_day(_day_token):
		return false
	_clear_day()
	return true

func _clear_day() -> void:
	_day_token = -1
	_day_config = null
	_day_crops.clear()
	_day_regions.clear()
	busy = false
