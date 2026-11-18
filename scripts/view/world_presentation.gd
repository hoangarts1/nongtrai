## WorldPresentation — 2D placeholders beneath ground-level anchors; never owns gameplay state.
## API:
##   func configure(main: Node) -> void
##   func configure_player_appearance(customization: Dictionary) -> void
##   func get_player_avatar() -> PlaceholderAvatar2D
##   func get_world_art_root() -> Node2D
##   func get_season_fx() -> Node
class_name WorldPresentation
extends Node

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")
const CATALOG: Resource = preload("res://data/art/world/chibi_world_catalog.tres")
const CHARACTER_CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
const SCENERY_CATALOG: SceneryArtCatalog = preload("res://data/art/world/isometric_scenery_catalog.tres")
const COOP_SITE: ChickenCoopSiteConfig = preload("res://data/chicken_coop_site.tres")
const WATER_CONFIG: WaterSourceConfig = preload("res://data/water_sources.tres")
var _world: GrayBoxWorld
var _main: Node
var _world_art: Node2D
var _owned_regions: Array[Rect2i] = []
var _player_avatar: PlaceholderAvatar2D
var _anchor_art: Dictionary = {}
var _source_reserved: Dictionary = {}
var _coop_reserved: Dictionary = COOP_SITE.reserved_cells()
var _scenery_config: Dictionary = {}
var _decor_queued: bool = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh_anchor_labels()

func configure(main: Node) -> void:
	name = "WorldPresentation"
	_main = main
	_world = main.world as GrayBoxWorld
	_player_avatar = _world.player.get_node("Visual") as PlaceholderAvatar2D
	_world_art = Node2D.new()
	_world_art.name = "WorldArt2D"
	_world_art.y_sort_enabled = true
	_world.objects.add_child(_world_art)
	_place_anchor("House", _world.CONFIG.house_cell, &"cottage", "")
	_place_anchor("SeedShop", _world.CONFIG.shop_cell, &"market", tr("UI_PROMPT_SHOP"))
	_place_anchor("ShippingBin", _world.CONFIG.shipping_bin_cell, &"bin", tr("UI_PROMPT_SELL"))
	_refresh_anchor_labels()
	_source_reserved = WaterSourceRules.reserved_cells(WATER_CONFIG)
	_scenery_config = SceneryPlacementRules.compile(SCENERY_CATALOG)
	_build_water_sources()
	refresh_land(main.land_ownership.get_owned_regions())
	main.farm_state.plot_changed.connect(func(_cell: Vector2i) -> void: _queue_decor_refresh())
	GameClock.season_changed.connect(_on_season_changed)
	_on_season_changed(GameClock.season)

func refresh_land(regions: Array[Rect2i]) -> void:
	if regions==_owned_regions and _world_art.get_child_count()>0:
		_queue_decor_refresh()
		return
	_owned_regions.assign(regions)
	# Remove generated blockers immediately; queue_free alone leaves live collision.
	for child: Node in _world_art.get_children():
		_world_art.remove_child(child)
		child.queue_free()
	_build_trees()
	_build_natural_scenery()

func _owned_cell(cell: Vector2i) -> bool:
	for region: Rect2i in _owned_regions:
		if region.has_point(cell):
			return true
	return false

func _build_trees() -> void:
	if _scenery_config.is_empty():
		return
	var tree_positions: Variant = CATALOG.call("get_placements", &"env_round_tree")
	if tree_positions is Array:
		var index: int = 0
		for legacy: Variant in tree_positions:
			if not legacy is Vector3:
				continue
			var cell: Vector2i = GridMath.world_to_cell(legacy)
			if _owned_cell(cell) or _source_reserved.has(cell) or _coop_reserved.has(cell):
				continue
			var entry: Dictionary = SCENERY_CATALOG.get_entry(StringName(SCENERY_CATALOG.tall_ids[index % SCENERY_CATALOG.tall_ids.size()]))
			var tree: Node2D = SuppliedSceneryView.create_tall(entry, cell, index)
			if tree == null:
				continue
			_world_art.add_child(tree)
			tree.global_position = _world.cell_to_global(cell)
			tree.visible = not _decor_occupied(cell)
			index += 1


func _build_natural_scenery() -> void:
	var map_region: Rect2i = _world.CONFIG.scenery_region
	var placed: int = 0
	for y: int in range(map_region.position.y, map_region.end.y):
		for x: int in range(map_region.position.x, map_region.end.x):
			var cell: Vector2i = Vector2i(x, y)
			if _reserved_scenery_cell(cell):
				continue
			var entry: Dictionary = SceneryPlacementRules.select(_scenery_config, cell, true)
			if not entry.is_empty() and (entry.kind in [&"rock", &"grass_clump"] or not _decor_occupied(cell)):
				_add_scenery_sprite(entry, cell, placed)
				placed += 1

func _decor_occupied(cell: Vector2i) -> bool:
	if not _main.farm_state.get_plot(cell).is_empty() or _world.player.get_cell() == cell:
		return true
	for placement: Dictionary in _main.machine_placements.get_all_placements():
		if Rect2i(placement.cell, MachinePlacementState.MACHINE_SIZE).has_point(cell):
			return true
	var social: NpcSocialState = _main.npc_system.state
	if social.cells.values().has(cell):
		return true
	for path: Variant in social.paths.values():
		if path is Array and path.has(cell):
			return true
	return false

func _queue_decor_refresh() -> void:
	if not _decor_queued:
		_decor_queued = true
		call_deferred("_refresh_decor")

func _refresh_decor() -> void:
	_decor_queued = false
	var present: Dictionary = {}
	for child: Node in _world_art.get_children():
		if child.get_meta("passive_tree", false):
			(child as Node2D).visible = not _decor_occupied(child.get_meta("cell"))
		if child.get_meta("scenery_kind", &"") in [&"flower", &"pebble", &"tuft"]:
			var cell: Vector2i = child.get_meta("cell")
			if _reserved_scenery_cell(cell) or _decor_occupied(cell):
				_world_art.remove_child(child)
				child.queue_free()
			else:
				present[cell] = true
	var region: Rect2i = _world.CONFIG.scenery_region
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var cell: Vector2i = Vector2i(x, y)
			if present.has(cell) or _reserved_scenery_cell(cell):
				continue
			var entry: Dictionary = SceneryPlacementRules.select(_scenery_config, cell, true)
			if not entry.is_empty() and entry.kind in [&"flower", &"pebble", &"tuft"] and not _decor_occupied(cell):
				_add_scenery_sprite(entry, cell, _world_art.get_child_count())

func _reserved_scenery_cell(cell: Vector2i) -> bool:
	if _owned_cell(cell) or _source_reserved.has(cell) or _coop_reserved.has(cell):
		return true
	for reserved: Vector2i in [_world.CONFIG.house_cell, _world.CONFIG.shipping_bin_cell, _world.CONFIG.shop_cell, _world.CONFIG.spawn_cell]:
		if cell.distance_squared_to(reserved) <= 4:
			return true
	return false

func _build_water_sources() -> void:
	var floor_root: Node2D = Node2D.new()
	floor_root.name = "WaterSources"
	floor_root.z_index = -15
	_world.ground.get_parent().add_child(floor_root)
	for source: WaterSourceData in WATER_CONFIG.sources:
		var floor_view: WaterSourceView = WaterSourceView.new()
		floor_view.name = String(source.source_id)
		floor_root.add_child(floor_view)
		floor_view.configure(source,_world.grid,WATER_CONFIG)
		if source.kind==&"well":
			var well: WaterSourceView = WaterSourceView.new()
			well.name = "WaterSource_"+String(source.source_id)
			_world.objects.add_child(well)
			well.configure(source,_world.grid,WATER_CONFIG,false)

func _scenery_hash(cell: Vector2i) -> int:
	return SceneryPlacementRules.cell_hash(_scenery_config, cell)

func _add_scenery_sprite(entry: Dictionary, cell: Vector2i, index: int) -> void:
	var root: SuppliedSceneryView = SuppliedSceneryView.new()
	if not root.configure(entry):
		root.free()
		return
	root.name = "%s_%d_%d" % [entry.kind, index, _scenery_hash(cell) % 1000]
	root.set_meta("cell", cell)
	_world_art.add_child(root)
	root.global_position = _world.cell_to_global(cell)
	if bool(entry.blocks):
		_add_large_rock_collision(root)

func _add_large_rock_collision(root: Node2D) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = "WorldStaticCollision"
	body.set_collision_layer_value(1, true)
	body.collision_mask = 0
	body.add_to_group("obstacles")
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 24.0
	shape.shape = circle
	shape.position = Vector2(0, -12)
	body.add_child(shape)
	root.add_child(body)

func _place_anchor(anchor_name: String, cell: Vector2i, kind: StringName, title: String) -> void:
	var anchor: Node2D = _world.objects.get_node(anchor_name) as Node2D
	anchor.global_position = _world.cell_to_global(cell)
	var art: PlaceholderWorld2D = PlaceholderWorld2D.new()
	art.name = "Placeholder"
	anchor.add_child(art)
	_anchor_art[anchor_name] = art
	art.configure(kind,title, PALETTE.call("get_color", &"wood", GameClock.season))

func configure_player_appearance(customization: Dictionary) -> void:
	var appearance: Resource = CHARACTER_CATALOG.call("get_default_player_appearance")
	var profile: Dictionary = appearance.call("to_builder_dictionary")
	_player_avatar.configure_profile(profile,customization)
	_refresh_anchor_labels()
	_queue_decor_refresh()

func _refresh_anchor_labels() -> void:
	if not is_instance_valid(_main):
		return
	var owner_name: String = String(_main.profile.get("player_name", ""))
	var titles: Dictionary = {"House":tr("UI_NPC_HOME") % owner_name if not owner_name.is_empty() else "","SeedShop":tr("UI_PROMPT_SHOP"),"ShippingBin":tr("UI_PROMPT_SELL")}
	for anchor_name: String in titles:
		var art: PlaceholderWorld2D = _anchor_art.get(anchor_name) as PlaceholderWorld2D
		if not is_instance_valid(art) or not is_instance_valid(art.label):
			continue
		art.label.text = titles[anchor_name]
		art.label.visible = not art.label.text.is_empty()
		# Pill geometry depends on text length, including while cosmetic phases pause.
		art.queue_redraw()

func get_player_avatar() -> PlaceholderAvatar2D:
	return _player_avatar

func get_world_art_root() -> Node2D:
	return _world_art

func get_season_fx() -> Node:
	return _main.weather_fx

func _on_season_changed(season: StringName) -> void:
	_recolor(_world.objects, season)

func _recolor(root: Node, season: StringName) -> void:
	if root is PlaceholderWorld2D:
		var art: PlaceholderWorld2D = root as PlaceholderWorld2D
		art.color = PALETTE.call("get_color", &"foliage" if art.kind == &"tree" else &"wood", season)
	for child: Node in root.get_children():
		_recolor(child, season)
