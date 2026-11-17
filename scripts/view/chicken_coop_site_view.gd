## ChickenCoopSiteView — projected presentation/collision of the actual purchased coop.
class_name ChickenCoopSiteView
extends Node2D
var world: GrayBoxWorld
var holding: ChickenCoopHoldingState
var config: ChickenCoopSiteConfig
var body: StaticBody2D
var caption: Label
var _phase: float = 0.0

func configure(source: GrayBoxWorld, state: ChickenCoopHoldingState, data: ChickenCoopSiteConfig) -> void:
	world = source
	holding = state
	config = data
	global_position = world.cell_to_global(config.footprint.end-Vector2i.ONE)
	caption = Label.new()
	caption.theme = LifeTheme.get_theme()
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.position = Vector2(-150,-250)
	caption.size = Vector2(300,40)
	LifeTheme.bind(caption,&"LifeSecondaryText")
	add_child(caption)
	refresh()

func refresh() -> void:
	if body!=null:
		remove_child(body)
		body.queue_free()
		body = null
	if holding.is_owned():
		body = StaticBody2D.new()
		body.name = "OwnedCollision"
		body.collision_layer = 1
		body.collision_mask = 0
		body.add_to_group("obstacles")
		add_child(body)
		var corners: PackedVector2Array = []
		for y: int in range(config.footprint.position.y,config.footprint.end.y):
			for x: int in range(config.footprint.position.x,config.footprint.end.x):
				for offset: Vector2 in IsometricGrid.diamond(Vector2(world.CONFIG.tile_size)*0.82):
					corners.append(body.to_local(world.cell_to_global(Vector2i(x,y))+offset))
		var collision: CollisionPolygon2D = CollisionPolygon2D.new()
		collision.polygon = Geometry2D.convex_hull(corners)
		body.add_child(collision)
	caption.text = tr("COOP_TITLE" if holding.is_owned() else "COOP_SITE")
	queue_redraw()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED and caption!=null:
		caption.text = tr("COOP_TITLE" if holding.is_owned() else "COOP_SITE")

func _process(delta: float) -> void:
	if holding!=null and holding.is_owned() and not GameClock.paused:
		_phase += delta
		queue_redraw()

func _draw() -> void:
	if config==null or world.grid==null:
		return
	var corners: PackedVector2Array = []
	for y: int in range(config.footprint.position.y,config.footprint.end.y):
		for x: int in range(config.footprint.position.x,config.footprint.end.x):
			for offset: Vector2 in IsometricGrid.diamond(Vector2(world.CONFIG.tile_size)*0.94):
				corners.append(to_local(world.cell_to_global(Vector2i(x,y))+offset))
	var hull: PackedVector2Array = Geometry2D.convex_hull(corners)
	draw_colored_polygon(hull,Color("cdbd83") if holding.is_owned() else Color("b8c98d"))
	draw_polyline(hull,Color("7c8152"),3,true)
	if not holding.is_owned():
		draw_line(Vector2(-42,-48),Vector2(-42,-125),Color("755335"),10)
		draw_style_box(_sign(),Rect2(-95,-132,106,38))
		return
	# Canvas-space illustration, grounded by actual TileMap projection above.
	draw_colored_polygon(PackedVector2Array([Vector2(-116,-84),Vector2(-116,-185),Vector2(-20,-145),Vector2(-20,-44)]),Color("bd9059"))
	draw_colored_polygon(PackedVector2Array([Vector2(-20,-44),Vector2(-20,-145),Vector2(62,-187),Vector2(62,-88)]),Color("976a43"))
	for i: int in range(4):
		draw_line(Vector2(-112,-170+i*22),Vector2(-24,-133+i*22),Color("9d7048"),3)
	draw_colored_polygon(PackedVector2Array([Vector2(-134,-185),Vector2(-45,-244),Vector2(79,-191),Vector2(-19,-129)]),Color("a45741"))
	draw_polyline(PackedVector2Array([Vector2(-134,-185),Vector2(-45,-244),Vector2(79,-191),Vector2(-19,-129),Vector2(-134,-185)]),Color("6e4734"),5,true)
	draw_rect(Rect2(-2,-121,35,53),Color("483b2e"))
	draw_circle(Vector2(-73,-150),17,Color("ffe3a0"))
	var actual: Dictionary = holding.coop.serialize()
	for i: int in range(int(actual.hen_count)):
		var origin: Vector2 = Vector2(-82+i*35,-22-absi(i%2)*18)
		origin.y += sin(_phase*2+i)*2
		_draw_hen(origin,Color("fff0cb"))
		if i<int(actual.fed_hens):
			draw_circle(origin+Vector2(0,-23),3,Color("6f9b54"))

func _draw_hen(origin: Vector2, color: Color) -> void:
	draw_set_transform(origin,0,Vector2(1,0.8))
	draw_circle(Vector2.ZERO,13,color)
	draw_circle(Vector2(9,-8),8,color)
	draw_circle(Vector2(9,-17),4,Color("b85d44"))
	draw_circle(Vector2(12,-10),1.6,Color("453c30"))
	draw_colored_polygon(PackedVector2Array([Vector2(16,-9),Vector2(23,-6),Vector2(16,-3)]),Color("d7a34a"))
	draw_set_transform(Vector2.ZERO)

func _sign() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("eddaaa")
	style.border_color = Color("99724b")
	style.set_border_width_all(4)
	return style
