## ChickenCoopSiteConfig — data-owned purchase/site/access terms.
class_name ChickenCoopSiteConfig
extends Resource
@export var site_id: StringName
@export var purchase_price: int = 0
@export var initial_hens: int = 0
@export var footprint: Rect2i
@export var entrance: Vector2i
@export var access_route: Array[Vector2i] = []
@export var clearance: int = 0
@export var world: IsometricWorldConfig
@export var land: LandExpansionConfig
@export var coop_config: ChickenCoopConfig

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if site_id==&"" or purchase_price<=0 or purchase_price>ChickenCoopConfig.MAX_JSON_INTEGER or coop_config==null or not coop_config.validation_errors().is_empty() or initial_hens<=0 or (coop_config!=null and initial_hens>coop_config.hen_capacity):
		errors.append("invalid purchase terms")
	if world==null or land==null or land.npc_world==null or not footprint.has_area() or clearance<0 or clearance>1:
		errors.append("invalid geometry context")
		return errors
	if not world.player_region.encloses(footprint) or not world.player_region.has_point(entrance) or footprint.has_point(entrance) or access_route.is_empty() or access_route.back()!=entrance:
		errors.append("invalid site or entrance")
	var exclusions: Array[Rect2i] = land.npc_world.locations.get_solid_regions()
	exclusions.append(land.initial_region)
	for parcel: ExpansionParcelData in land.parcels:
		exclusions.append(parcel.region)
	for region: Rect2i in exclusions:
		if footprint.intersects(region):
			errors.append("site overlaps reserved region")
	for i: int in range(access_route.size()):
		var cell: Vector2i = access_route[i]
		if not world.player_region.has_point(cell):
			errors.append("route outside walking region")
		if i>0 and cell.x!=access_route[i-1].x and cell.y!=access_route[i-1].y:
			errors.append("route must use axis-aligned segments")
	for cell: Vector2i in reserved_cells():
		if not world.player_region.has_point(cell):
			continue
		# Clearance clears only passive scenery. Validate the actual path, not its shoulders.
		if _on_path(cell):
			for region: Rect2i in exclusions:
				if region.has_point(cell):
					errors.append("route blocked by fixed region")
	return errors

func _on_path(cell: Vector2i) -> bool:
	for i: int in range(1,access_route.size()):
		var a: Vector2i = access_route[i-1]
		var z: Vector2i = access_route[i]
		if Rect2i(Vector2i(mini(a.x,z.x),mini(a.y,z.y)),Vector2i(absi(z.x-a.x)+1,absi(z.y-a.y)+1)).has_point(cell):
			return true
	return false

func reserved_cells() -> Dictionary:
	var cells: Dictionary = {}
	for y: int in range(footprint.position.y-clearance,footprint.end.y+clearance):
		for x: int in range(footprint.position.x-clearance,footprint.end.x+clearance):
			cells[Vector2i(x,y)] = true
	for i: int in range(1,access_route.size()):
		var a: Vector2i = access_route[i-1]
		var z: Vector2i = access_route[i]
		for y: int in range(mini(a.y,z.y)-clearance,maxi(a.y,z.y)+clearance+1):
			for x: int in range(mini(a.x,z.x)-clearance,maxi(a.x,z.x)+clearance+1):
				cells[Vector2i(x,y)] = true
	return cells
