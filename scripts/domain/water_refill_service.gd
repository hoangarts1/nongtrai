## WaterRefillService — stateless authorization for the actual can at a dry source bank.
## API:
##   func configure(config: WateringCanConfig, state: WateringCanState, sources: WaterSourceConfig, locations: WorldLocations) -> void
##   func can_refill(player_cell: Vector2i) -> Dictionary
##   func refill(player_cell: Vector2i) -> Dictionary
class_name WaterRefillService
extends RefCounted

var _config: WateringCanConfig
var _state: WateringCanState
var _sources: WaterSourceConfig
var _locations: WorldLocations

func configure(config: WateringCanConfig, state: WateringCanState, sources: WaterSourceConfig, locations: WorldLocations) -> void:
	_config = config
	_state = state
	_sources = sources
	_locations = locations

func can_refill(player_cell: Vector2i) -> Dictionary:
	if _state==null or not _state.is_ready_for(_config) or _sources==null or not _sources.validation_errors().is_empty() or _locations==null or _locations.water_sources!=_sources:
		return _failure(&"invalid_service")
	if not _sources.world.player_region.has_point(player_cell):
		return _failure(&"source_unavailable")
	for region: Rect2i in _locations.get_solid_regions():
		if region.has_point(player_cell):
			return _failure(&"source_unavailable")
	for source: WaterSourceData in _sources.sources:
		if WaterSourceRules.is_shore(_sources,source,player_cell):
			var available: bool = _state.get_charges()<_state.get_capacity()
			return {"ok":available,"reason":&"available" if available else &"already_full","source_id":source.source_id,"display_name_key":source.display_name_key,"charges":_state.get_charges(),"capacity":_state.get_capacity()}
	return _failure(&"source_unavailable")

func refill(player_cell: Vector2i) -> Dictionary:
	var ready: Dictionary = can_refill(player_cell)
	if not bool(ready.ok):
		return ready
	if not _state.refill():
		return _failure(&"refill_rejected")
	ready["reason"] = &"refilled"
	ready["charges"] = _state.get_charges()
	return ready

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
