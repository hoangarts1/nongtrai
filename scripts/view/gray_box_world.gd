## GrayBoxWorld — 2D isometric world; gameplay state stays in existing domain services.
## API:
##   func pick_cell(screen_position: Vector2) -> Variant
##   func cell_to_global(cell: Vector2i) -> Vector2
##   func get_player_cell() -> Vector2i
##   static func is_player_near_interactable(player_cell: Vector2, target_cell: Vector2, reach: float) -> bool
class_name GrayBoxWorld
extends Node2D

const CONFIG: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
signal shipping_bin_interacted()
signal seed_shop_interacted()

@onready var ground: TileMapLayer = %Ground
@onready var farmland: TileMapLayer = %Farmland
@onready var objects: Node2D = %Objects
@onready var player: Player = %Player
@onready var camera_rig: CameraRig = %CameraRig
@onready var bed_marker: Marker2D = %BedMarker
@onready var shipping_bin_marker: Marker2D = %ShippingBinMarker
@onready var seed_shop_marker: Marker2D = %SeedShopMarker
@onready var interaction_prompt: InteractionPrompt = $InteractionLayer/InteractionPrompt
@onready var world_tint: CanvasModulate = %WorldTint
@onready var house_light: PointLight2D = %HouseLight
var camera: Camera2D
var grid: IsometricGrid
var _day_night_profile: Resource = preload("res://data/day_night_profile.tres")
var _weather_darkness: float = 0.0

func _ready() -> void:
	_build_tiles()
	grid = IsometricGrid.new(ground)
	player.grid = grid
	player.map_min = Vector2(CONFIG.player_region.position)
	player.map_max = Vector2(CONFIG.player_region.end - Vector2i.ONE)
	player.move_to_cell(CONFIG.spawn_cell)
	camera = player.camera
	camera_rig.set_target(player)
	_place_marker(bed_marker, CONFIG.house_cell)
	_place_marker(shipping_bin_marker, CONFIG.shipping_bin_cell)
	_place_marker(seed_shop_marker, CONFIG.shop_cell)
	%PlayerSpawn.global_position = cell_to_global(CONFIG.spawn_cell)
	_build_obstacles()
	GameClock.sleep_started.connect(_on_sleep_started)
	GameClock.sleep_finished.connect(_on_sleep_finished)
	GameClock.time_changed.connect(_on_time_changed)
	Events.weather_changed.connect(_on_weather_changed)
	_apply_day_night(GameClock.minute)

func _build_tiles() -> void:
	var tiles: TileSet = TileSet.new()
	tiles.tile_size = CONFIG.tile_size
	tiles.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tiles.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture_region_size = CONFIG.tile_size
	var texture_image: Image = Image.create(CONFIG.tile_size.x * 4, CONFIG.tile_size.y, false, Image.FORMAT_RGBA8)
	texture_image.fill(Color.TRANSPARENT)
	var colors: Array[Color] = [CONFIG.ground_color, CONFIG.dry_soil_color, CONFIG.wet_soil_color, CONFIG.ground_color.darkened(0.12)]
	for tile_index: int in range(colors.size()):
		for y: int in range(CONFIG.tile_size.y):
			for x: int in range(CONFIG.tile_size.x):
				var diamond_distance: float = absf((float(x) + 0.5) / float(CONFIG.tile_size.x) * 2.0 - 1.0) + absf((float(y) + 0.5) / float(CONFIG.tile_size.y) * 2.0 - 1.0)
				if diamond_distance <= 1.0:
					var color: Color = colors[tile_index]
					if diamond_distance > 0.92:
						color = color.darkened(0.10)
					texture_image.set_pixel(tile_index * CONFIG.tile_size.x + x, y, color)
	atlas.texture = ImageTexture.create_from_image(texture_image)
	for tile_index: int in range(colors.size()):
		atlas.create_tile(Vector2i(tile_index, 0))
	tiles.add_source(atlas, 0)
	ground.tile_set = tiles
	farmland.tile_set = tiles
	for y: int in range(CONFIG.map_region.position.y, CONFIG.map_region.end.y):
		for x: int in range(CONFIG.map_region.position.x, CONFIG.map_region.end.x):
			ground.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
	ground.update_internals()

func _build_obstacles() -> void:
	var locations: WorldLocations = (preload("res://data/npcs/phase8_world.tres") as NpcWorldData).locations
	for index: int in range(locations.solid_rects.size()):
		var region: Rect2i = locations.solid_rects[index]
		# The farm is a navigation exclusion for NPCs, not a player collision wall.
		if region == Rect2i(0, 0, 6, 6):
			continue
		var body: StaticBody2D = StaticBody2D.new()
		body.name = "Obstacle_%d" % index
		body.set_collision_layer_value(1, true)
		body.collision_mask = 0
		body.add_to_group("obstacles")
		objects.add_child(body)
		var corners: PackedVector2Array = PackedVector2Array()
		for cell: Vector2i in [region.position, Vector2i(region.end.x - 1, region.position.y), region.end - Vector2i.ONE, Vector2i(region.position.x, region.end.y - 1)]:
			var center: Vector2 = grid.cell_to_global(cell)
			for offset: Vector2 in IsometricGrid.diamond(Vector2(CONFIG.tile_size) * 0.82):
				corners.append(body.to_local(center + offset))
		var collider: CollisionPolygon2D = CollisionPolygon2D.new()
		collider.polygon = Geometry2D.convex_hull(corners)
		body.add_child(collider)

func _place_marker(marker: Marker2D, cell: Vector2i) -> void:
	marker.global_position = cell_to_global(cell)
	marker.set_meta("cell", cell)

func cell_to_global(cell: Vector2i) -> Vector2:
	return grid.cell_to_global(cell)

func get_player_cell() -> Vector2i:
	return player.get_cell()

func pick_cell(screen_position: Vector2) -> Variant:
	return grid.screen_to_cell(screen_position)

func _process(_delta: float) -> void:
	_update_interaction_prompt()

func _near(marker: Marker2D) -> bool:
	return grid != null and is_player_near_interactable(Vector2(get_player_cell()), Vector2(marker.get_meta("cell", Vector2i.ZERO)), CONFIG.interaction_reach)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameClock.is_sleeping() or not player.movement_enabled:
		return
	if _near(shipping_bin_marker):
		shipping_bin_interacted.emit()
		get_viewport().set_input_as_handled()
	elif _near(seed_shop_marker):
		seed_shop_interacted.emit()
		get_viewport().set_input_as_handled()
	elif GameClock.can_sleep() and _near(bed_marker):
		if GameClock.try_sleep():
			_on_sleep_started()
			get_viewport().set_input_as_handled()

func _update_interaction_prompt() -> void:
	if grid == null:
		return
	if GameClock.is_sleeping():
		interaction_prompt.show_prompt(tr("UI_SLEEP_PENDING"))
	elif _near(shipping_bin_marker):
		interaction_prompt.show_prompt(tr("UI_PROMPT_SELL"))
	elif _near(seed_shop_marker):
		interaction_prompt.show_prompt(tr("UI_PROMPT_SHOP"))
	elif GameClock.can_sleep() and _near(bed_marker):
		interaction_prompt.show_prompt(tr("UI_SLEEP_HINT"))
	else:
		interaction_prompt.hide_prompt()

func _on_sleep_started() -> void:
	player.movement_enabled = false
	interaction_prompt.show_prompt(tr("UI_SLEEP_PENDING"))

func _on_sleep_finished(_day_index: int) -> void:
	player.movement_enabled = true
	_update_interaction_prompt()

func _on_time_changed(_day_index: int, minute: int) -> void:
	_apply_day_night(minute)

func _apply_day_night(minute: int) -> void:
	var lighting: Dictionary = get_day_night_lighting(minute)
	var ambient: Color = lighting.get("ambient_color", Color.WHITE)
	var daylight: float = clampf(float(lighting.get("sun_energy", 0.0)) / 1.2, 0.0, 1.0)
	world_tint.color = ambient.lerp(Color.WHITE, daylight).darkened(_weather_darkness * 0.5)
	house_light.visible = minute >= 1080 or minute < 360

func get_day_night_lighting(minute: int) -> Dictionary:
	return _day_night_profile.call("sample", minute)

func _on_weather_changed(weather_id: StringName) -> void:
	var profile: Resource = preload("res://data/weather_profile.tres")
	var entry: Dictionary = profile.call("get_entry", weather_id)
	_weather_darkness = float(entry.get("darkness", 0.0))
	_apply_day_night(GameClock.minute)

static func is_player_near_interactable(player_cell: Vector2, target_cell: Vector2, reach: float) -> bool:
	return reach >= 0.0 and player_cell.distance_squared_to(target_cell) <= reach * reach
