## LandExpansionRules — shared Resource validation and exact integer-only land quotes.
## API:
##   static func validate(config: LandExpansionConfig) -> PackedStringArray
##   static func quote_cost(config: LandExpansionConfig, order: int) -> Dictionary
class_name LandExpansionRules
extends RefCounted

# Technical signed-int bound, not a gameplay price cap.
const MAX_INTEGER: int = 9223372036854775807

static func validate(config: LandExpansionConfig) -> PackedStringArray:
	var errors: PackedStringArray = []
	if config==null:
		return PackedStringArray(["land expansion config is missing"])
	if not _pricing_valid(config):
		errors.append("land expansion pricing requires positive integers and increasing growth")
	if config.world==null or config.npc_world==null or config.npc_world.locations==null:
		errors.append("land expansion requires world and static-location Resources")
		return errors
	var world: IsometricWorldConfig = config.world
	if not _positive(world.map_region) or not _positive(world.player_region) or not world.map_region.encloses(world.player_region):
		errors.append("world/player bounds must be positive and nested")
		return errors
	if not _positive(config.initial_region) or not world.map_region.encloses(config.initial_region) or not world.player_region.encloses(config.initial_region):
		errors.append("initial land must be positive and inside map/player bounds")
	if config.parcels.is_empty():
		errors.append("land expansion requires a parcel")
	var ids: Dictionary = {}
	var id_pattern: RegEx = RegEx.new()
	id_pattern.compile("^[a-z][a-z0-9_]*$")
	var regions: Array[Rect2i] = []
	if _positive(config.initial_region):
		regions.append(config.initial_region)
	for index: int in range(config.parcels.size()):
		var parcel: ExpansionParcelData = config.parcels[index]
		if parcel==null:
			errors.append("land parcel is missing")
			continue
		if id_pattern.search(String(parcel.parcel_id))==null or ids.has(parcel.parcel_id):
			errors.append("land parcel IDs must be unique snake_case identifiers")
		ids[parcel.parcel_id] = true
		if not _positive(parcel.region):
			errors.append("land parcel must have positive dimensions")
			continue
		if not world.map_region.encloses(parcel.region) or not world.player_region.encloses(parcel.region):
			errors.append("land parcel must be positive and inside map/player bounds")
		for region: Rect2i in regions:
			if region.intersects(parcel.region):
				errors.append("land regions must not overlap")
		for solid: Rect2i in config.npc_world.locations.get_solid_regions():
			if not _positive(solid):
				errors.append("static exclusion must have positive dimensions")
			elif solid.intersects(parcel.region):
				errors.append("land parcel overlaps a static/navigation exclusion")
		regions.append(parcel.region)
		var quote: Dictionary = quote_cost(config,index+1)
		if not bool(quote.ok):
			errors.append("land parcel has no safe positive price")
	return errors

static func quote_cost(config: LandExpansionConfig, order: int) -> Dictionary:
	if not _pricing_valid(config):
		return _failure(&"invalid_config")
	if order<=0:
		return _failure(&"invalid_order")
	var numerator: int = config.base_cost
	var denominator: int = 1
	var exponent: int = 0
	# Do not allocate range(order): hostile large indices must fail cheaply.
	while exponent<order-1:
		var factor_n: int = config.growth_numerator
		var factor_d: int = config.growth_denominator
		var divisor: int = _gcd(numerator,factor_d)
		@warning_ignore("integer_division")
		numerator /= divisor
		@warning_ignore("integer_division")
		factor_d /= divisor
		divisor = _gcd(factor_n,denominator)
		@warning_ignore("integer_division")
		factor_n /= divisor
		@warning_ignore("integer_division")
		denominator /= divisor
		@warning_ignore("integer_division")
		if numerator>MAX_INTEGER/factor_n or denominator>MAX_INTEGER/factor_d:
			return _failure(&"cost_overflow")
		numerator *= factor_n
		denominator *= factor_d
		exponent += 1
	@warning_ignore("integer_division")
	if denominator>MAX_INTEGER/config.rounding_step:
		return _failure(&"cost_overflow")
	var unit_denominator: int = denominator*config.rounding_step
	@warning_ignore("integer_division")
	var units: int = numerator/unit_denominator
	@warning_ignore("integer_division")
	var half_up: int = unit_denominator/2+unit_denominator%2
	if numerator%unit_denominator>=half_up:
		if units==MAX_INTEGER:
			return _failure(&"cost_overflow")
		units += 1
	@warning_ignore("integer_division")
	if units<=0 or units>MAX_INTEGER/config.rounding_step:
		return _failure(&"invalid_price")
	return {"ok":true,"reason":&"quoted","price":units*config.rounding_step}

static func _pricing_valid(config: LandExpansionConfig) -> bool:
	return config!=null and config.base_cost>0 and config.growth_denominator>0 and config.growth_numerator>config.growth_denominator and config.rounding_step>0

static func _positive(region: Rect2i) -> bool:
	return region.size.x>0 and region.size.y>0

static func _gcd(a: int, b: int) -> int:
	while b!=0:
		var remainder: int = a%b
		a = b
		b = remainder
	return a

static func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
