## EcologySamplingConfig — explicit goals and species identities for farm sampling.
## API: validation_errors(crops: Array[Resource]) -> PackedStringArray.
class_name EcologySamplingConfig
extends Resource

const INT32_MAX: int = 2147483647

@export var mature_tree_goal: int = 0
@export var species_goal: int = 0
@export var fruit_tree_ids: PackedStringArray = []
@export var species_aliases: Dictionary = {}

func validation_errors(crops: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = []
	if mature_tree_goal <= 0 or mature_tree_goal > INT32_MAX or species_goal <= 0 or species_goal > INT32_MAX:
		errors.append("ecology sampling goals must be positive int32 quantities")
	var known: Dictionary = {}
	if crops.is_empty():
		errors.append("ecology sampling requires a crop catalog")
	for resource: Resource in crops:
		var crop: CropData = resource as CropData
		if crop == null:
			errors.append("ecology sampling catalog contains a missing/wrong CropData")
			continue
		var id: String = String(crop.crop_id)
		if not EcologyMetricData.valid_id(id) or known.has(id):
			errors.append("ecology sampling crop ids must be valid and unique")
		if crop.growth_days <= 0 or crop.growth_days > INT32_MAX or crop.regrow_days < 0 or crop.regrow_days > INT32_MAX:
			errors.append("ecology sampling crop growth data is invalid")
		known[id] = crop
	var trees: Dictionary = {}
	if fruit_tree_ids.is_empty():
		errors.append("ecology sampling requires fruit tree ids")
	for id: String in fruit_tree_ids:
		var crop: CropData = known.get(id) as CropData
		if not EcologyMetricData.valid_id(id) or trees.has(id) or crop == null:
			errors.append("ecology sampling fruit tree id is unknown/invalid/duplicate")
		elif not crop.perennial or crop.regrow_days <= 0:
			errors.append("ecology sampling fruit trees must be perennial repeat crops")
		trees[id] = true
	var aliases: Dictionary = {}
	for source: Variant in species_aliases:
		var target: Variant = species_aliases[source]
		if not EcologyMetricData.valid_id(source) or not EcologyMetricData.valid_id(target):
			errors.append("ecology sampling alias requires string species ids")
			continue
		var from_id: String = String(source)
		var to_id: String = String(target)
		if not known.has(from_id) or not known.has(to_id) or aliases.has(from_id) or from_id == to_id:
			errors.append("ecology sampling alias is unknown/duplicate/self-referential")
		aliases[from_id] = to_id
	# Canonical targets are terminal: reject chains as well as cycles.
	for target: String in aliases.values():
		if aliases.has(target):
			errors.append("ecology sampling aliases must terminate without chains/cycles")
	return errors
