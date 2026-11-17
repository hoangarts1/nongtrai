extends GutTest

const CONFIG: WaterSourceConfig = preload("res://data/water_sources.tres")
const NPCS: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")

func _copy() -> WaterSourceConfig:
	var copy: WaterSourceConfig = CONFIG.duplicate() as WaterSourceConfig
	copy.world = CONFIG.world.duplicate() as IsometricWorldConfig
	copy.sources = []
	for source: WaterSourceData in CONFIG.sources:
		copy.sources.append(source.duplicate(true) as WaterSourceData)
	return copy

func test_registered_sources_have_exact_approved_geometry_and_clear_dry_approaches() -> void:
	assert_eq(CONFIG.sources.size(),3)
	assert_eq(CONFIG.world.map_region,Rect2i(-40,-40,85,85))
	assert_eq(CONFIG.world.player_region,Rect2i(-18,-18,39,39))
	assert_eq(CONFIG.world.scenery_region,Rect2i(-20,-20,43,43))
	assert_true(DataValidator.validate_water_source_config(CONFIG,NPCS.locations,LAND).is_empty())
	assert_true(LandExpansionRules.validate(LAND).is_empty())
	var ids: Array[StringName] = [&"home_well",&"forest_stream",&"east_pond"]
	var regions: Array[Rect2i] = [Rect2i(8,9,1,1),Rect2i(-16,-7,2,14),Rect2i(16,8,4,4)]
	for index: int in range(3):
		var source: WaterSourceData = CONFIG.sources[index]
		assert_eq(source.source_id,ids[index])
		assert_eq(source.region,regions[index])
		assert_eq(WaterSourceRules.source_at(CONFIG,source.label_cell),source.source_id)
		assert_true(WaterSourceRules.is_shore(CONFIG,source,source.access_waypoints.back()))
		var cells: Array[Vector2i] = WaterSourceRules.access_cells(source)
		assert_eq(cells.front(),Vector2i(3,6))
		for cell: Vector2i in cells:
			assert_eq(WaterSourceRules.source_at(CONFIG,cell),&"")
			assert_true(CONFIG.world.player_region.has_point(cell))
			assert_false(LAND.initial_region.has_point(cell))
			for parcel: ExpansionParcelData in LAND.parcels:
				assert_false(parcel.region.has_point(cell))
		for index_cell: int in range(1,cells.size()):
			var delta: Vector2i = cells[index_cell]-cells[index_cell-1]
			assert_eq(absi(delta.x)+absi(delta.y),1)

func test_malformed_source_resources_are_rejected_without_mutating_the_shared_config() -> void:
	for field: StringName in [&"source_id",&"kind",&"display_name_key",&"region",&"label_cell"]:
		var config: WaterSourceConfig = _copy()
		var invalid: Dictionary = {&"source_id":&"BAD ID",&"kind":&"ocean",&"display_name_key":&"",&"region":Rect2i(8,9,-1,1),&"label_cell":Vector2i(999,999)}
		config.sources[0].set(field,invalid[field])
		assert_false(config.validation_errors().is_empty(),String(field))
	var empty: WaterSourceConfig = _copy()
	empty.sources[0].access_waypoints.clear()
	assert_false(empty.validation_errors().is_empty())
	var duplicate: WaterSourceConfig = _copy()
	duplicate.sources[1].source_id = duplicate.sources[0].source_id
	assert_false(duplicate.validation_errors().is_empty())
	duplicate = _copy()
	duplicate.sources.append(null)
	assert_false(duplicate.validation_errors().is_empty())
	assert_true(CONFIG.validation_errors().is_empty())
	assert_eq(CONFIG.sources[0].source_id,&"home_well")

func test_invalid_bounds_clearance_and_approach_segments_fail_the_gate() -> void:
	var config: WaterSourceConfig = _copy()
	config.world.player_region = Rect2i(-18,-18,0,39)
	assert_false(config.validation_errors().is_empty())
	config = _copy()
	config.clearance_cells = -1
	assert_false(config.validation_errors().is_empty())
	config = _copy()
	config.sources[0].access_waypoints = [Vector2i(3,6),Vector2i(7,9)]
	assert_false(config.validation_errors().is_empty())
	assert_true(WaterSourceRules.access_cells(config.sources[0]).is_empty())
	config = _copy()
	config.sources[0].access_waypoints = [Vector2i(999,9)]
	assert_false(config.validation_errors().is_empty())
	assert_true(WaterSourceRules.validate(null,[],[]).size()>0)

func test_domain_rejects_overlapping_sources_farm_buildings_and_submerged_access() -> void:
	var config: WaterSourceConfig = _copy()
	config.sources[1].region = config.sources[0].region
	config.sources[1].label_cell = config.sources[0].label_cell
	assert_false(WaterSourceRules.validate(config,[],[]).is_empty())
	assert_false(WaterSourceRules.validate(CONFIG,[],[CONFIG.sources[2].region]).is_empty())
	assert_false(WaterSourceRules.validate(CONFIG,[CONFIG.sources[2].region],[]).is_empty())
	assert_true(WaterSourceRules.validate(CONFIG,[CONFIG.sources[0].region],[]).is_empty(),"Exact existing well prop reuse is valid")
	config = _copy()
	config.sources[2].access_waypoints = [Vector2i(15,9),Vector2i(17,9)]
	assert_false(WaterSourceRules.validate(config,[],[]).is_empty())
	config = _copy()
	config.sources[2].access_waypoints = [Vector2i(3,6)]
	assert_false(WaterSourceRules.validate(config,[],[]).is_empty(),"A disconnected bank is invalid")
	assert_false(WaterSourceRules.is_shore(CONFIG,CONFIG.sources[2],Vector2i(17,9)))

func test_combined_solids_are_copied_deduplicated_and_shared_with_npc_navigation() -> void:
	var before: Array[Rect2i] = NPCS.locations.solid_rects.duplicate()
	var solids: Array[Rect2i] = NPCS.locations.get_solid_regions()
	assert_eq(solids.count(CONFIG.sources[0].region),1)
	assert_eq(solids.size(),before.size()+2)
	solids.clear()
	assert_eq(NPCS.locations.solid_rects,before)
	var scheduler: NpcSchedule = NpcSchedule.new()
	scheduler.configure(NPCS)
	assert_true(scheduler.route(Vector2i(15,9),Vector2i(17,9)).is_empty())
	assert_gt(scheduler.route(Vector2i(14,9),Vector2i(15,9)).size(),0)
	assert_true(scheduler.route(Vector2i(-14,6),Vector2i(-15,6)).is_empty(),"Out-of-nav stream clips safely")
	for npc: NpcData in NPCS.npcs:
		assert_true(NPCS.locations.has_location(npc.home_location))
	assert_eq(NPCS.locations.solid_rects,before)

func test_future_parcel_cannot_cover_sources_and_reservation_is_bounded() -> void:
	var land: LandExpansionConfig = LAND.duplicate() as LandExpansionConfig
	land.parcels = []
	for parcel: ExpansionParcelData in LAND.parcels:
		land.parcels.append(parcel.duplicate() as ExpansionParcelData)
	land.parcels[0].region = CONFIG.sources[2].region
	assert_false(LandExpansionRules.validate(land).is_empty())
	assert_eq(LAND.parcels[0].region,Rect2i(6,0,6,6),"The future-parcel probe never mutates shared production data")
	var reserved: Dictionary = WaterSourceRules.reserved_cells(CONFIG)
	assert_lt(reserved.size(),CONFIG.world.scenery_region.get_area())
	for cell: Vector2i in reserved:
		assert_true(CONFIG.world.scenery_region.has_point(cell))
	for source: WaterSourceData in CONFIG.sources:
		for cell: Vector2i in WaterSourceRules.access_cells(source):
			assert_true(reserved.has(cell))
		assert_true(reserved.has(source.label_cell))
	assert_true(WaterSourceRules.reserved_cells(null).is_empty())
