## CropStageRules — stateless visual/care boundaries; never advances a crop.
## API:
##   static func stage_index(growth_days: int, target_days: int, regrowing: bool = false) -> int
##   static func ratio_stage_index(progress: float, regrowing: bool = false) -> int
##   static func crosses_stage(current_days: int, next_days: int, target_days: int, regrowing: bool = false) -> bool
class_name CropStageRules
extends RefCounted

const CONFIG: CropStageConfig = preload("res://data/crop_stage_config.tres")

static func stage_index(growth_days: int, target_days: int, regrowing: bool = false) -> int:
	if growth_days < 0 or target_days <= 0 or not CONFIG.validation_errors().is_empty():
		return -1
	if regrowing:
		return CONFIG.stage_count - 1 if growth_days >= target_days else CONFIG.repeat_stage - 1
	# Compare rational boundaries without multiplying an untrusted day by four.
	@warning_ignore("integer_division")
	var whole: int = target_days / CONFIG.stage_count
	var remainder: int = target_days % CONFIG.stage_count
	var result: int = 0
	for index: int in range(1, CONFIG.stage_count):
		@warning_ignore("integer_division")
		var boundary: int = whole * index + (remainder * index + CONFIG.stage_count - 1) / CONFIG.stage_count
		if growth_days >= boundary:
			result = index
	return result

static func ratio_stage_index(progress: float, regrowing: bool = false) -> int:
	if not is_finite(progress) or not CONFIG.validation_errors().is_empty():
		return -1
	var bounded: float = clampf(progress, 0.0, 1.0)
	if regrowing:
		return CONFIG.stage_count - 1 if bounded >= 1.0 else CONFIG.repeat_stage - 1
	return mini(CONFIG.stage_count - 1, floori(bounded * CONFIG.stage_count))

static func crosses_stage(current_days: int, next_days: int, target_days: int, regrowing: bool = false) -> bool:
	var current: int = stage_index(current_days, target_days, regrowing)
	var next: int = stage_index(next_days, target_days, regrowing)
	if current < 0 or next < 0 or next_days <= current_days:
		return false
	# Maturity is also a care boundary even when the last image already shows fruit.
	return next > current or (current_days < target_days and next_days >= target_days)
