## ChickenCoopSaveCodec — validates the v11 component without replacing other progress.
## API: static empty(day), normalize(raw,day,config).
class_name ChickenCoopSaveCodec
extends RefCounted

static func empty(day: int) -> Dictionary:
	return {"owned":false,"coop":{"current_day":day,"hen_count":0,"fed_hens":0,"pending_eggs":0}}

static func normalize(raw: Variant, day: int, config: ChickenCoopConfig) -> Dictionary:
	var fallback: Dictionary = empty(day)
	if not raw is Dictionary or not raw.get("owned") is bool or not raw.get("coop") is Dictionary or config==null or not config.validation_errors().is_empty():
		push_warning("ChickenCoopSaveCodec: missing/malformed coop; unowned fallback")
		return fallback
	var state: Dictionary = raw.coop
	for key: String in ["current_day","hen_count","fed_hens","pending_eggs"]:
		if ChickenCoopState._json_integer(state.get(key))<0:
			push_warning("ChickenCoopSaveCodec: invalid integer; unowned fallback")
			return fallback
	var hens: int = int(state.hen_count)
	if int(state.current_day)!=day or hens>config.hen_capacity or int(state.fed_hens)>hens or (not bool(raw.owned) and (hens!=0 or int(state.fed_hens)!=0 or int(state.pending_eggs)!=0)) or (bool(raw.owned) and hens<=0):
		push_warning("ChickenCoopSaveCodec: inconsistent ownership/day; unowned fallback")
		return fallback
	var coop: ChickenCoopState = ChickenCoopState.new()
	coop.configure(config,day,0)
	coop.deserialize(state)
	return {"owned":bool(raw.owned),"coop":coop.serialize()}
