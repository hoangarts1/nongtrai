## CropEconomyRules — stateless integer checks for initial/repeat crop returns.
## API:
##   static func validate(config: CropEconomyConfig, crops: Array[Resource], items: Array[Resource]) -> PackedStringArray
class_name CropEconomyRules
extends RefCounted

# Integrity bound ensures multiplying two validated values cannot overflow int64.
const MAX_RULE_INTEGER: int = 2147483647

static func validate(config: CropEconomyConfig, crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = []
	if config == null or config.max_profit_per_plot_day <= 0 or config.max_profit_per_plot_day > MAX_RULE_INTEGER:
		errors.append("crop economy ceiling must be a positive bounded integer")
		return errors
	var by_id: Dictionary = {}
	for resource: Resource in items:
		if resource is ItemData:
			by_id[resource.item_id] = resource
	for resource: Resource in crops:
		var crop: CropData = resource as CropData
		if crop == null:
			errors.append("crop economy requires CropData")
			continue
		var seed: ItemData = by_id.get(crop.seed_item) as ItemData
		var product: ItemData = by_id.get(crop.product_item) as ItemData
		if seed == null or product == null:
			errors.append("crop economy %s has missing items" % crop.crop_id)
			continue
		var valid: bool = true
		for value: int in [crop.yield_qty, crop.growth_days, seed.buy_price, product.sell_price]:
			valid = valid and value > 0 and value <= MAX_RULE_INTEGER
		valid = valid and crop.regrow_days >= 0 and crop.regrow_days <= MAX_RULE_INTEGER
		if not valid:
			errors.append("crop economy %s requires positive bounded values/durations" % crop.crop_id)
			continue
		var gross: int = crop.yield_qty * product.sell_price
		var net: int = gross - seed.buy_price
		if net <= 0 or net > config.max_profit_per_plot_day * crop.growth_days:
			errors.append("crop economy %s initial return exceeds ceiling or is not profitable" % crop.crop_id)
		if crop.regrow_days > 0 and gross > config.max_profit_per_plot_day * crop.regrow_days:
			errors.append("crop economy %s repeat return exceeds ceiling" % crop.crop_id)
	return errors
