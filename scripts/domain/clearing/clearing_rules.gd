## ClearingRules - compile existing deterministic art IDs, never generate rewards/RNG.
## API: compile(config:ClearingConfig)->Dictionary.
class_name ClearingRules
extends RefCounted

static func compile(config: ClearingConfig) -> Dictionary:
	if config==null or not config.validation_errors().is_empty(): return {}
	var scenery: Dictionary = SceneryPlacementRules.compile(config.scenery)
	if scenery.is_empty(): return {}
	var excluded: Dictionary = WaterSourceRules.reserved_cells(config.water)
	excluded.merge(config.coop.reserved_cells())
	var regions: Array[Rect2i] = config.land.npc_world.locations.get_solid_regions()
	regions.append(config.land.initial_region)
	for parcel: ExpansionParcelData in config.land.parcels:
		if parcel==null: return {}
		regions.append(parcel.region)
	var anchors: Array[Vector2i] = [config.world.spawn_cell,config.world.house_cell,config.world.shipping_bin_cell,config.world.shop_cell]
	var entries: Dictionary[Vector2i, StringName] = {}
	var bounds: Rect2i = config.world.player_region
	for y: int in range(bounds.position.y,bounds.end.y):
		for x: int in range(bounds.position.x,bounds.end.x):
			var cell: Vector2i = Vector2i(x,y)
			var reserved: bool = excluded.has(cell)
			for region: Rect2i in regions:
				if region.has_point(cell): reserved = true; break
			for anchor: Vector2i in anchors:
				if cell.distance_squared_to(anchor)<=config.anchor_clearance_squared: reserved = true; break
			if reserved: continue
			var entry: Dictionary = SceneryPlacementRules.select(scenery,cell,true)
			if not entry.is_empty() and entry.kind in [&"rock",&"grass_clump"]:
				entries[cell] = StringName(entry.id)
	if entries.size()<config.story_goal: return {}
	return {"entries":entries,"goal":config.story_goal}
