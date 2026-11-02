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
var _world: GrayBoxWorld
var _main: Node
var _world_art: Node2D
var _player_avatar: PlaceholderAvatar2D

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
	var tree_positions: Variant = CATALOG.call("get_placements", &"env_round_tree")
	if tree_positions is Array:
		var index: int = 0
		for legacy: Variant in tree_positions:
			if not legacy is Vector3:
				continue
			var cell: Vector2i = GridMath.world_to_cell(legacy)
			var tree: PlaceholderWorld2D = PlaceholderWorld2D.new()
			tree.name = "Tree_%d" % index
			tree.set_meta("cell", cell)
			_world_art.add_child(tree)
			tree.global_position = _world.cell_to_global(cell)
			tree.configure(&"tree", "", PALETTE.call("get_color", &"foliage", GameClock.season))
			index += 1
	GameClock.season_changed.connect(_on_season_changed)
	_on_season_changed(GameClock.season)

func _place_anchor(anchor_name: String, cell: Vector2i, kind: StringName, title: String) -> void:
	var anchor: Node2D = _world.objects.get_node(anchor_name) as Node2D
	anchor.global_position = _world.cell_to_global(cell)
	var art: PlaceholderWorld2D = PlaceholderWorld2D.new()
	art.name = "Placeholder"
	anchor.add_child(art)
	art.configure(kind,title, PALETTE.call("get_color", &"wood", GameClock.season))

func configure_player_appearance(customization: Dictionary) -> void:
	var appearance: Resource = CHARACTER_CATALOG.call("get_default_player_appearance")
	var profile: Dictionary = appearance.call("to_builder_dictionary")
	_player_avatar.configure_profile(profile,customization)
	var owner_name: String = String(_main.profile.get("player_name", ""))
	var house: PlaceholderWorld2D = _world.objects.get_node("House/Placeholder") as PlaceholderWorld2D
	house.label.text = tr("UI_NPC_HOME") % owner_name if not owner_name.is_empty() else ""
	house.label.visible = not owner_name.is_empty()

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
