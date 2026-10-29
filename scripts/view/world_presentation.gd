## WorldPresentation -- C3 generated scenery that preserves all gameplay anchors.
## API:
##   func configure(main: Node) -> void
##   func configure_player_appearance(customization: Dictionary) -> void
##   func get_player_avatar() -> ChibiAvatar
##   func get_world_art_root() -> Node3D
##   func get_season_fx() -> Node
class_name WorldPresentation
extends Node3D

const WORLD_ART_FACTORY: Script = preload("res://scripts/view/world_art_factory.gd")
const WORLD_SEASON_FX_SCRIPT: Script = preload("res://scripts/view/world_season_fx.gd")
const CHARACTER_CATALOG_PATH: String = "res://data/art/characters/chibi_character_catalog.tres"
const WORLD_CATALOG_PATH: String = "res://data/art/world/chibi_world_catalog.tres"

var _main: Node
var _world: GrayBoxWorld
var _catalog: Resource
var _world_art: Node3D
var _season_fx: Node
var _player_avatar: ChibiAvatar
var _player_profile: Dictionary = {}

func configure(main: Node) -> void:
	name = "WorldPresentation"
	_main = main
	_world = main.world as GrayBoxWorld
	if _world == null:
		return
	_catalog = load(WORLD_CATALOG_PATH) as Resource
	_prepare_player_avatar()
	_clear_c3_children()
	_world_art = Node3D.new()
	_world_art.name = "C3WorldArt"
	add_child(_world_art)
	_decorate_existing_anchors(GameClock.season)
	_place_catalog_art(GameClock.season)
	_tune_lighting(_world)
	_season_fx = WORLD_SEASON_FX_SCRIPT.new() as Node
	if _season_fx != null:
		_season_fx.name = "WorldSeasonFx"
		add_child(_season_fx)
		if _season_fx.has_method(&"configure"):
			_season_fx.call(&"configure", _main.weather_state, _catalog)
	if not GameClock.season_changed.is_connected(_on_season_changed):
		GameClock.season_changed.connect(_on_season_changed)

func configure_player_appearance(customization: Dictionary) -> void:
	if _player_avatar == null:
		return
	if _player_profile.is_empty():
		_player_profile = _default_player_profile()
	if _player_profile.is_empty():
		return
	_player_avatar.configure_profile(_player_profile, customization)

func get_player_avatar() -> ChibiAvatar:
	return _player_avatar

func get_world_art_root() -> Node3D:
	return _world_art

func get_season_fx() -> Node:
	return _season_fx

func _prepare_player_avatar() -> void:
	var player: Player = _world.player
	var visual: MeshInstance3D = player.get_node_or_null("Visual") as MeshInstance3D
	if visual != null:
		visual.hide()
	var existing: ChibiAvatar = player.get_node_or_null("ChibiAvatar") as ChibiAvatar
	if existing != null:
		_player_avatar = existing
	else:
		_player_avatar = ChibiAvatar.new()
		_player_avatar.name = "ChibiAvatar"
		player.add_child(_player_avatar)
	_player_profile = _default_player_profile()
	if _player_profile.is_empty():
		_player_avatar.configure(Color("a7bd88"))
	else:
		_player_avatar.configure_profile(_player_profile)

func _clear_c3_children() -> void:
	for child: Node in get_children():
		if child.name == "C3WorldArt" or child.name == "WorldSeasonFx":
			child.free()
	_world_art = null
	_season_fx = null

func _decorate_existing_anchors(season: StringName) -> void:
	var house: MeshInstance3D = _world.get_node_or_null("House") as MeshInstance3D
	var market: MeshInstance3D = _world.get_node_or_null("SeedShop") as MeshInstance3D
	var shipping_bin: MeshInstance3D = _world.get_node_or_null("ShippingBin") as MeshInstance3D
	WORLD_ART_FACTORY.replace_anchor_visual(house, &"bld_player_cottage", season)
	WORLD_ART_FACTORY.replace_anchor_visual(market, &"bld_seed_market", season)
	WORLD_ART_FACTORY.replace_anchor_visual(shipping_bin, &"bld_shipping_bin", season)
	if _main == null or _main.get("npc_system") == null:
		return
	var npc_system: Node = _main.get("npc_system") as Node
	for npc_id: StringName in [&"minh", &"linh"]:
		var home: MeshInstance3D = npc_system.get_node_or_null("Home_%s" % String(npc_id)) as MeshInstance3D
		WORLD_ART_FACTORY.replace_anchor_visual(home, &"bld_npc_cottage", season)

func _place_catalog_art(season: StringName) -> void:
	if _catalog == null or not _catalog.has_method(&"get_placements"):
		return
	var all_assets: Variant = _catalog.get("asset_ids")
	if not all_assets is PackedStringArray:
		return
	for asset_name: String in all_assets as PackedStringArray:
		var asset_id: StringName = StringName(asset_name)
		var locations: Variant = _catalog.call(&"get_placements", asset_id)
		if not locations is Array:
			continue
		var group_name: String = _group_name(asset_id)
		var group: Node3D = _world_art.get_node_or_null(group_name) as Node3D
		if group == null:
			group = Node3D.new()
			group.name = group_name
			_world_art.add_child(group)
		var index: int = 0
		for location: Variant in locations as Array:
			if not location is Vector3:
				continue
			var asset: Node3D = WORLD_ART_FACTORY.create_asset(asset_id, season)
			asset.name = "%s_%d" % [String(asset_id).to_pascal_case(), index]
			asset.position = location as Vector3
			asset.rotation.y = deg_to_rad(float(posmod(index * 37 + String(asset_id).length() * 11, 360)))
			group.add_child(asset)
			index += 1

func _on_season_changed(season: StringName) -> void:
	if _world_art != null:
		WORLD_ART_FACTORY.apply_season(_world_art, season)
	var house: MeshInstance3D = _world.get_node_or_null("House") as MeshInstance3D
	var market: MeshInstance3D = _world.get_node_or_null("SeedShop") as MeshInstance3D
	var shipping_bin: MeshInstance3D = _world.get_node_or_null("ShippingBin") as MeshInstance3D
	WORLD_ART_FACTORY.apply_season(house, season)
	WORLD_ART_FACTORY.apply_season(market, season)
	WORLD_ART_FACTORY.apply_season(shipping_bin, season)
	if _main != null and _main.get("npc_system") != null:
		var npc_system: Node = _main.get("npc_system") as Node
		for npc_id: StringName in [&"minh", &"linh"]:
			WORLD_ART_FACTORY.apply_season(npc_system.get_node_or_null("Home_%s" % String(npc_id)), season)

func _default_player_profile() -> Dictionary:
	var catalog: Resource = load(CHARACTER_CATALOG_PATH) as Resource
	if catalog == null or not catalog.has_method(&"get_default_player_appearance"):
		return {}
	return _appearance_dictionary(catalog.call(&"get_default_player_appearance"))

func _appearance_dictionary(appearance: Variant) -> Dictionary:
	if appearance is Dictionary:
		return (appearance as Dictionary).duplicate(true)
	if appearance is Resource and (appearance as Resource).has_method(&"to_builder_dictionary"):
		var profile: Variant = (appearance as Resource).call(&"to_builder_dictionary")
		if profile is Dictionary:
			return (profile as Dictionary).duplicate(true)
	return {}

func _tune_lighting(world: GrayBoxWorld) -> void:
	var environment: Environment = world.world_environment.environment
	if environment != null:
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		environment.tonemap_exposure = 1.02
		environment.tonemap_white = 4.6
		environment.adjustment_enabled = true
		environment.adjustment_saturation = 1.08
		environment.adjustment_contrast = 1.03
		environment.glow_enabled = true
		environment.glow_bloom = 0.070
		environment.glow_hdr_scale = 1.0
		environment.fog_enabled = true
		environment.fog_density = 0.0035
		environment.fog_light_color = Color("f4ddb4")
		environment.fog_light_energy = 0.46
		environment.fog_sun_scatter = 0.24
		environment.fog_sky_affect = 0.10
	world.sun.directional_shadow_max_distance = 46.0
	world.sun.directional_shadow_fade_start = 0.78
	world.sun.directional_shadow_blend_splits = true
	world.sun.light_angular_distance = 0.82

func _group_name(asset_id: StringName) -> String:
	match asset_id:
		&"env_round_tree":
			return "C3Trees"
		&"env_cliff_border", &"env_pond_bridge":
			return "C3Terrain"
		&"bld_observatory":
			return "C3Landmarks"
		_:
			return "C3VillageProps"
