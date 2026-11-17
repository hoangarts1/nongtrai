## LandOwnershipState — sole serializable owner of an ordered known-parcel prefix.
## API:
##   func configure(config: LandExpansionConfig) -> void
##   func is_ready_for(config: LandExpansionConfig) -> bool
##   func can_use_cell(cell: Vector2i) -> bool
##   func get_owned_ids() -> Array[StringName]
##   func get_owned_regions() -> Array[Rect2i]
##   func next_parcel_id() -> StringName
##   func grant_next(parcel_id: StringName) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name LandOwnershipState
extends RefCounted

var _config: LandExpansionConfig
var _owned: Array[StringName] = []

func configure(config: LandExpansionConfig) -> void:
	_config = config
	_owned.clear()

func is_ready_for(config: LandExpansionConfig) -> bool:
	if config==null or config!=_config or not LandExpansionRules.validate(config).is_empty() or _owned.size()>config.parcels.size():
		return false
	for index: int in range(_owned.size()):
		if _owned[index]!=config.parcels[index].parcel_id:
			return false
	return true

func can_use_cell(cell: Vector2i) -> bool:
	if not is_ready_for(_config):
		return false
	if _config.initial_region.has_point(cell):
		return true
	for index: int in range(_owned.size()):
		if _config.parcels[index].region.has_point(cell):
			return true
	return false

func get_owned_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	if is_ready_for(_config):
		ids.assign(_owned)
	return ids

func get_owned_regions() -> Array[Rect2i]:
	var regions: Array[Rect2i] = []
	if is_ready_for(_config):
		regions.append(_config.initial_region)
		for index: int in range(_owned.size()):
			regions.append(_config.parcels[index].region)
	return regions

func next_parcel_id() -> StringName:
	if not is_ready_for(_config) or _owned.size()>=_config.parcels.size():
		return &""
	return _config.parcels[_owned.size()].parcel_id

func grant_next(parcel_id: StringName) -> bool:
	if parcel_id.is_empty() or parcel_id!=next_parcel_id():
		return false
	# Atomic/no callback: services may safely refund a rejected grant.
	_owned.append(parcel_id)
	return true

func serialize() -> Dictionary:
	var ids: Array[String] = []
	for id: StringName in get_owned_ids():
		ids.append(String(id))
	return {"owned_parcels":ids}

func deserialize(data: Dictionary) -> void:
	_owned.clear()
	if not is_ready_for(_config):
		push_warning("LandOwnershipState: invalid configuration; no parcel grants restored")
		return
	var raw: Variant = data.get("owned_parcels",[])
	if not raw is Array:
		push_warning("LandOwnershipState: malformed parcel grants ignored")
		return
	var dropped: bool = false
	for value: Variant in raw:
		if not (value is String or value is StringName):
			dropped = true
			continue
		var id: StringName = StringName(value)
		if _owned.has(id):
			dropped = true
		elif not grant_next(id):
			dropped = true
	if dropped:
		push_warning("LandOwnershipState: unknown, duplicate or non-prefix grants ignored")
