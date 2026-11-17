## WaterSourceView — procedural source/path art; physics and gameplay live elsewhere.
## API:
##   func configure(data: WaterSourceData, grid: IsometricGrid, config: WaterSourceConfig, floor_only: bool = true) -> void
class_name WaterSourceView
extends Node2D

var source: WaterSourceData
var label: Label
var _grid: IsometricGrid
var _config: WaterSourceConfig
var _floor_only: bool = true
var _phase: float = 0.0
var _path: Array[Vector2i] = []

func configure(data: WaterSourceData, grid: IsometricGrid, config: WaterSourceConfig, floor_only: bool = true) -> void:
	source = data
	_grid = grid
	_config = config
	_floor_only = floor_only
	global_position = grid.cell_to_global(source.label_cell)
	_path = WaterSourceRules.access_cells(source)
	if not floor_only or source.kind!=&"well":
		label = Label.new()
		label.name = "NameLabel"
		label.position = Vector2(-80,-132 if source.kind==&"well" else -36)
		label.size = Vector2(160,28)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.z_index = 0 if source.kind==&"well" else 16
		LifeTheme.bind(label,&"LifeWorldLabel")
		add_child(label)
		_refresh_label()
	set_process(floor_only and source.kind!=&"well")
	queue_redraw()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED:
		_refresh_label()

func _refresh_label() -> void:
	if is_instance_valid(label) and source!=null:
		label.text = tr(String(source.display_name_key))
		queue_redraw()

func _process(delta: float) -> void:
	if GameClock.paused:
		return
	_phase += delta
	queue_redraw()

func _region_polygon(region: Rect2i, scale_factor: float = 1.0) -> PackedVector2Array:
	var points: PackedVector2Array = []
	var corners: Array[Vector2i] = [region.position,Vector2i(region.end.x-1,region.position.y),region.end-Vector2i.ONE,Vector2i(region.position.x,region.end.y-1)]
	for cell: Vector2i in corners:
		var center: Vector2 = _grid.layer.map_to_local(cell)
		for offset: Vector2 in IsometricGrid.diamond(Vector2(_config.world.tile_size)*scale_factor):
			points.append(to_local(_grid.layer.to_global(center+offset)))
	var hull: PackedVector2Array = Geometry2D.convex_hull(points)
	if hull.size()>1 and hull[0]==hull[hull.size()-1]:
		hull.resize(hull.size()-1)
	return hull

func _draw() -> void:
	if source==null or _config==null or _grid==null:
		return
	if not _floor_only:
		_draw_well()
		_draw_label_background()
		return
	for cell: Vector2i in _path:
		draw_colored_polygon(_region_polygon(Rect2i(cell,Vector2i.ONE),0.68),_config.path_color)
	draw_colored_polygon(_region_polygon(source.region.grow(_config.clearance_cells)),_config.shore_color)
	if source.kind==&"well":
		return
	var border: PackedVector2Array = _region_polygon(source.region)
	draw_colored_polygon(border,_config.water_color.darkened(0.18))
	draw_colored_polygon(_region_polygon(source.region,0.86),_config.water_color)
	for y: int in range(source.region.position.y,source.region.end.y):
		for x: int in range(source.region.position.x,source.region.end.x):
			if posmod(x+y,3)!=0:
				continue
			var center: Vector2 = to_local(_grid.cell_to_global(Vector2i(x,y)))
			var wave: float = sin(_phase*1.5+float(x+y))*4.0
			draw_line(center+Vector2(-12+wave,0),center+Vector2(12+wave,0),Color(0.84,0.96,0.96,0.65),1.5)
	_draw_label_background()

func _draw_label_background() -> void:
	if label==null:
		return
	var width: float = clampf(label.get_minimum_size().x+12.0,64.0,168.0)
	var rect: Rect2 = Rect2(Vector2(-width*0.5,label.position.y-2),Vector2(width,26))
	draw_rect(rect.grow(2),Color("3a291d"))
	draw_rect(rect,Color("f4e9ca"))

func _draw_well() -> void:
	var ink: Color = Color("3a291d")
	var stone: Color = _config.well_color
	draw_set_transform(Vector2(0,4),0.0,Vector2(1,0.4))
	draw_circle(Vector2.ZERO,41,Color(0.12,0.17,0.1,0.24))
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	draw_style_box(_stone_box(stone.darkened(0.2),ink),Rect2(-34,-29,68,37))
	draw_set_transform(Vector2(0,-29),0.0,Vector2(1,0.42))
	draw_circle(Vector2.ZERO,35,ink)
	draw_circle(Vector2.ZERO,32,stone.lightened(0.15))
	draw_circle(Vector2.ZERO,23,_config.water_color.darkened(0.45))
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	for x: float in [-25.0,25.0]:
		draw_line(Vector2(x,-20),Vector2(x,-76),ink,9)
		draw_line(Vector2(x,-20),Vector2(x,-76),Color("986340"),5)
	draw_colored_polygon(PackedVector2Array([Vector2(-45,-72),Vector2(0,-95),Vector2(45,-72),Vector2(0,-55)]),ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-39,-72),Vector2(0,-90),Vector2(38,-72),Vector2(0,-59)]),Color("b97847"))
	draw_line(Vector2.ZERO+Vector2(0,-61),Vector2(0,-27),Color("dfc58a"),2)
	draw_rect(Rect2(12,-8,17,15),ink)
	draw_rect(Rect2(14,-6,13,11),Color("a87648"))
	draw_arc(Vector2(20,-7),7,PI,TAU,10,ink,2)

func _stone_box(stone: Color, ink: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = stone
	box.border_color = ink
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	return box
