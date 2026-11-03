## CropCycleRules — stateless first/repeat-cycle calculations from owner snapshots.
## API:
##   static func target_days(crop: CropData, plot: Dictionary) -> int
##   static func begin_repeat(crop: CropData, plot: Dictionary) -> Dictionary
class_name CropCycleRules
extends RefCounted

static func target_days(crop: CropData, plot: Dictionary) -> int:
	if crop == null:
		return 0
	var fallback: int = crop.regrow_days if bool(plot.get("regrowing", false)) else crop.growth_days
	return maxi(1, int(plot.get("growth_target", fallback)))

static func begin_repeat(crop: CropData, plot: Dictionary) -> Dictionary:
	if crop == null or crop.regrow_days <= 0:
		return {}
	var result: Dictionary = plot.duplicate(true)
	result["growth_days"] = 0
	result["growth_target"] = crop.regrow_days
	result["regrowing"] = true
	# Harvest is not watering: retain moisture and the current dry streak.
	return result
