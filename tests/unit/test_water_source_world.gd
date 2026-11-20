extends GutTest

const CONFIG: WaterSourceConfig = preload("res://data/water_sources.tres")
const NPCS: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var locale: String
var accumulator: float

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	locale = TranslationServer.get_locale()
	GameClock.deserialize({"day_index":0,"minute":720,"season":"spring","year":1})
	GameClock.paused = true
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.set("_game_started",true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	main.world.player.movement_enabled = false
	main.world.camera_rig.set_process(false)
	main.profile["player_name"] = "Mai"
	main.presentation.configure_player_appearance({})
	await get_tree().process_frame
	await get_tree().process_frame

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)

func test_expanded_ground_source_nodes_and_reserved_corridors_preserve_old_anchors_and_owners() -> void:
	assert_eq(main.world.ground.get_used_rect(),CONFIG.world.map_region)
	assert_eq(main.world.ground.get_used_cells().size(),85*85)
	assert_eq(main.world.player.map_min,Vector2(-18,-18))
	assert_eq(main.world.player.map_max,Vector2(20,20))
	assert_eq(main.world.grid.global_to_cell(main.world.bed_marker.global_position),Vector2i(11,10))
	assert_eq(main.world.grid.global_to_cell(main.world.seed_shop_marker.global_position),Vector2i(-2,7))
	assert_eq(main.world.grid.global_to_cell(main.world.shipping_bin_marker.global_position),Vector2i(5,10))
	assert_eq(SaveService.CURRENT_VERSION,17)
	var reserved: Dictionary = WaterSourceRules.reserved_cells(CONFIG)
	var scenery: Node2D = main.presentation.get_world_art_root()
	assert_gt(scenery.get_child_count(),0)
	assert_lt(scenery.get_child_count(),43*43)
	for child: Node2D in scenery.get_children():
		if child.has_meta("cell"):
			var cell: Vector2i = child.get_meta("cell")
			assert_false(reserved.has(cell),"No decoration or scenery collider occupies the dry corridor")
			assert_true(CONFIG.world.scenery_region.has_point(cell))
	var before: Dictionary = _owners()
	var ids: Array[int] = []
	for source: WaterSourceData in CONFIG.sources:
		var view: WaterSourceView = _view(source)
		assert_same(view.get_canvas(),main.world.ground.get_canvas(),"Sources share the real WorldCanvas camera transform")
		assert_same(view.source,source)
		assert_eq(view.global_position,main.world.cell_to_global(source.label_cell))
		ids.append(view.get_instance_id())
		if source.kind==&"well":
			assert_null(view.label)
			assert_not_null(main.world.objects.get_node("WaterSource_home_well/NameLabel"))
	var combined: Array[Rect2i] = NPCS.locations.get_solid_regions()
	assert_eq(combined.count(CONFIG.sources[0].region),1)
	assert_not_null(main.world.objects.get_node("Obstacle_%d" % combined.find(CONFIG.sources[0].region)))
	main.presentation.refresh_land(main.land_ownership.get_owned_regions())
	for index: int in range(3):
		assert_eq(_view(CONFIG.sources[index]).get_instance_id(),ids[index])
	assert_eq(_owners(),before)

func test_actual_player_can_follow_every_dry_approach_but_cannot_cross_source_footprints() -> void:
	for source: WaterSourceData in CONFIG.sources:
		var path: Array[Vector2i] = WaterSourceRules.access_cells(source)
		main.world.player.move_to_cell(path.front())
		await get_tree().physics_frame
		for index: int in range(1,path.size()):
			var target: Vector2 = main.world.cell_to_global(path[index])
			var obstruction: KinematicCollision2D = main.world.player.move_and_collide(target-main.world.player.global_position)
			assert_null(obstruction,"Source %s dry route cell %s" % [source.source_id,path[index]])
			assert_lt(main.world.player.global_position.distance_to(target),0.05)
		var destination: Vector2 = main.world.cell_to_global(source.label_cell)
		var collision: KinematicCollision2D = main.world.player.move_and_collide(destination-main.world.player.global_position)
		assert_not_null(collision,"Water/stone blocks actual CharacterBody2D motion")
		assert_gt(main.world.player.global_position.distance_to(destination),8.0)
		assert_true(collision.get_collider() is StaticBody2D if collision!=null else false)

func test_real_source_render_locale_pause_and_five_zoom_picking_leave_gameplay_unchanged() -> void:
	var before: Dictionary = _owners()
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for width: int in [1152,1600]:
			viewport.size = Vector2i(width,width*9/16)
			for source: WaterSourceData in CONFIG.sources:
				var view: WaterSourceView = _view(source)
				var art: WaterSourceView = main.world.objects.get_node("WaterSource_home_well") as WaterSourceView if source.kind==&"well" else view
				assert_eq(art.label.text,tr(String(source.display_name_key)))
				assert_ne(art.label.text,String(source.display_name_key))
				var phase: float = float(view.get("_phase"))
				main.world.player.move_to_cell(source.access_waypoints.back())
				main.world.camera.global_position = view.global_position
				main.world.camera.zoom = Vector2.ONE*(0.5 if width==1152 else 1.25)
				main.world.camera.force_update_scroll()
				await get_tree().process_frame
				assert_lt(main.world.grid.cell_to_screen(source.label_cell).distance_to(Vector2(viewport.size)*0.5),1.0,"Source is centered in the actual rendered viewport")
				await _capture("%s_%s_%d" % [source.source_id,language,width])
				assert_eq(float(view.get("_phase")),phase,"Paused cosmetic water remains still")
				for zoom: float in CONFIG.world.zoom_levels:
					main.world.camera.zoom = Vector2.ONE*zoom
					main.world.camera.force_update_scroll()
					await get_tree().process_frame
					assert_eq(main.world.pick_cell(main.world.grid.cell_to_screen(source.label_cell)),source.label_cell)
	main.world.camera.global_position = Vector2(64,96)
	main.world.camera.zoom = Vector2.ONE*CONFIG.world.zoom_levels[0]
	main.world.camera.force_update_scroll()
	await _capture("expanded_overview")
	assert_eq(_owners(),before,"Presentation, zoom and locale never simulate a day or mutate owners")
	var water: WaterSourceView = _view(CONFIG.sources[1])
	var old_phase: float = float(water.get("_phase"))
	GameClock.paused = false
	water.call("_process",0.1)
	GameClock.paused = true
	assert_gt(float(water.get("_phase")),old_phase)

func _view(source: WaterSourceData) -> WaterSourceView:
	return main.world.ground.get_parent().get_node("WaterSources/"+String(source.source_id)) as WaterSourceView

func _owners() -> Dictionary:
	return {"clock":GameClock.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"farm":main.farm_state.serialize(),"land":main.land_ownership.serialize(),"jobs":main.machine_operations.serialize(),"social":main.npc_system.state.serialize(),"profile":main.profile.duplicate(true)}

func _capture(stem: String) -> void:
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase65h2a_%s.png" % stem),OK)
