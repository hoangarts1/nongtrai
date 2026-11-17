## WaterSourceRules — stateless shared world-source geometry; never refills a can.
## API:
##   static func validate(config: WaterSourceConfig, solids: Array[Rect2i], protected_regions: Array[Rect2i]) -> PackedStringArray
##   static func access_cells(source: WaterSourceData) -> Array[Vector2i]
##   static func source_at(config: WaterSourceConfig, cell: Vector2i) -> StringName
##   static func is_shore(config: WaterSourceConfig, source: WaterSourceData, cell: Vector2i) -> bool
##   static func reserved_cells(config: WaterSourceConfig) -> Dictionary
class_name WaterSourceRules
extends RefCounted

static func validate(config: WaterSourceConfig, solids: Array[Rect2i], protected_regions: Array[Rect2i]) -> PackedStringArray:
	if config==null:
		return PackedStringArray(["water source config is missing"])
	var errors: PackedStringArray = config.validation_errors()
	if not errors.is_empty():
		return errors
	var regions: Array[Rect2i] = []
	for source: WaterSourceData in config.sources:
		for previous: Rect2i in regions:
			if previous.intersects(source.region):
				errors.append("water sources must not overlap")
		regions.append(source.region)
		for region: Rect2i in protected_regions:
			if region.intersects(source.region):
				errors.append("water source overlaps owned/planned farmland")
		for solid: Rect2i in solids:
			if solid.intersects(source.region) and not (source.kind==&"well" and solid==source.region):
				errors.append("water source overlaps an existing building")
		for cell: Vector2i in access_cells(source):
			if not source_at(config,cell).is_empty():
				errors.append("water source approach crosses water/well")
			for region: Rect2i in solids+protected_regions:
				if region.has_point(cell):
					errors.append("water source approach crosses a protected/static cell")
		if not is_shore(config,source,source.access_waypoints.back()):
			errors.append("water source approach must end on a dry bank")
		for cell: Vector2i in [config.world.spawn_cell,config.world.house_cell,config.world.shop_cell,config.world.shipping_bin_cell,config.world.debug_home_cell]:
			if source.region.has_point(cell):
				errors.append("water source covers an existing interaction anchor")
	return errors

static func access_cells(source: WaterSourceData) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if source==null or source.access_waypoints.is_empty():
		return result
	result.append(source.access_waypoints[0])
	for index: int in range(1,source.access_waypoints.size()):
		var cell: Vector2i = source.access_waypoints[index-1]
		var target: Vector2i = source.access_waypoints[index]
		if cell.x!=target.x and cell.y!=target.y:
			return []
		var step: Vector2i = Vector2i(0 if cell.x==target.x else (1 if target.x>cell.x else -1),0 if cell.y==target.y else (1 if target.y>cell.y else -1))
		while cell!=target:
			cell += step
			result.append(cell)
	return result

static func source_at(config: WaterSourceConfig, cell: Vector2i) -> StringName:
	if config!=null:
		for source: WaterSourceData in config.sources:
			if source!=null and source.region.has_point(cell):
				return source.source_id
	return &""

static func is_shore(config: WaterSourceConfig, source: WaterSourceData, cell: Vector2i) -> bool:
	return config!=null and config.world!=null and source!=null and config.world.player_region.has_point(cell) and source.region.grow(1).has_point(cell) and source_at(config,cell).is_empty()

static func reserved_cells(config: WaterSourceConfig) -> Dictionary:
	var result: Dictionary = {}
	if config==null or not config.validation_errors().is_empty():
		return result
	for source: WaterSourceData in config.sources:
		_mark_region(result,source.region.grow(config.clearance_cells).intersection(config.world.scenery_region))
		for cell: Vector2i in access_cells(source):
			_mark_region(result,Rect2i(cell,Vector2i.ONE).grow(config.clearance_cells).intersection(config.world.scenery_region))
	return result

static func _mark_region(result: Dictionary, region: Rect2i) -> void:
	for y: int in range(region.position.y,region.end.y):
		for x: int in range(region.position.x,region.end.x):
			result[Vector2i(x,y)] = true
