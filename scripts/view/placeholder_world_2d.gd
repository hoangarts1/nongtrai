## PlaceholderWorld2D — 2D isometric buildings and trees with ground-level pivot and live animations.
class_name PlaceholderWorld2D
extends Node2D

var kind: StringName = &"cottage"
var color: Color = Color("bc8340")
var label: Label
var _phase: float = 0.0
var _accum: float = 0.0

func configure(visual_kind: StringName, title: String, tint: Color) -> void:
	kind = visual_kind
	color = tint
	if label == null:
		label = Label.new()
		label.name = "NameLabel"
		label.position = Vector2(-70, -92)
		label.size = Vector2(140, 24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		LifeTheme.bind(label, &"LifeWorldLabel")
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
	label.text = title
	label.visible = not title.is_empty()
	set_process(kind == &"cottage" or kind == &"tree")
	queue_redraw()

func _process(delta: float) -> void:
	if GameClock.paused or (kind != &"cottage" and kind != &"tree"):
		return
	_phase += delta
	_accum += delta
	if _accum >= 0.15:
		_accum = 0.0
		queue_redraw()

func _draw() -> void:
	var ink: Color = Color("3a2412")
	match kind:
		&"tree":
			_draw_iso_tree(ink)
		&"bin":
			_draw_iso_bin(ink)
		&"market":
			_draw_iso_market(ink)
		_:
			_draw_iso_cottage(ink)
	if label != null and label.visible and not label.text.is_empty():
		var pill_w: float = clampf(float(label.text.length()) * 7.2 + 22.0, 76.0, 148.0)
		var pill_rect: Rect2 = Rect2(-pill_w * 0.5, -93.0, pill_w, 22.0)
		draw_rect(pill_rect.grow(2.0), ink)
		draw_rect(pill_rect, Color(0.96, 0.91, 0.78, 0.92))
		draw_rect(Rect2(pill_rect.position.x + 2.0, pill_rect.position.y + 2.0, pill_rect.size.x - 4.0, 2.0), Color(1.0, 0.98, 0.90, 0.8))

func _draw_iso_tree(ink: Color) -> void:
	var sway: float = sin(_phase * 1.8 + position.x * 0.03) * 1.6 if _phase > 0.0 else 0.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2(0, 4), 24.0, Color(0.1, 0.15, 0.06, 0.25))
	draw_set_transform(Vector2.ZERO)
	# Bark trunk & roots
	draw_colored_polygon(PackedVector2Array([Vector2(-9, 2), Vector2(-5, -36), Vector2(5, -36), Vector2(9, 2)]), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-6, 1), Vector2(-3, -35), Vector2(3, -35), Vector2(6, 1)]), Color("8c5828"))
	draw_line(Vector2(1, -34), Vector2(2, 0), Color("6e431c"), 2.5)
	# Layered lush canopy (matching 03-trong-game-ban-ngay.png)
	var c_dark: Color = color.darkened(0.14)
	var c_light: Color = color.lightened(0.16)
	for cluster: Vector3 in [Vector3(-14 + sway, -42, 16), Vector3(14 + sway, -42, 16), Vector3(sway, -54, 20)]:
		draw_circle(Vector2(cluster.x, cluster.y), cluster.z + 2.2, ink)
	for cluster: Vector3 in [Vector3(-14 + sway, -42, 16), Vector3(14 + sway, -42, 16)]:
		draw_circle(Vector2(cluster.x, cluster.y), cluster.z, c_dark)
	draw_circle(Vector2(sway, -45), 21.0, color)
	draw_circle(Vector2(sway, -54), 20.0, color)
	draw_circle(Vector2(-6 + sway, -58), 9.5, c_light)
	draw_circle(Vector2(9 + sway, -46), 6.5, c_light)
	# Cozy apples / blossoms on canopy
	for pt: Vector2 in [Vector2(-10 + sway, -46), Vector2(8 + sway, -53), Vector2(3 + sway, -39)]:
		draw_circle(pt, 3.3, ink)
		draw_circle(pt, 2.3, Color("e3533e"))

func _draw_iso_bin(ink: Color) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 2), 26.0, Color(0.1, 0.15, 0.06, 0.26))
	draw_set_transform(Vector2.ZERO)
	var wood_left: Color = color.lightened(0.08)
	var wood_right: Color = color.darkened(0.14)
	var lid_color: Color = color.lightened(0.20)
	# Left isometric wall
	var left_wall: PackedVector2Array = PackedVector2Array([Vector2(-24, -10), Vector2(0, 2), Vector2(0, -22), Vector2(-24, -34)])
	# Right isometric wall
	var right_wall: PackedVector2Array = PackedVector2Array([Vector2(0, 2), Vector2(24, -10), Vector2(24, -34), Vector2(0, -22)])
	# Angled isometric lid
	var lid: PackedVector2Array = PackedVector2Array([Vector2(-26, -34), Vector2(0, -21), Vector2(26, -34), Vector2(0, -47)])
	draw_colored_polygon(left_wall, wood_left)
	draw_polyline(left_wall + PackedVector2Array([left_wall[0]]), ink, 2.5, true)
	draw_colored_polygon(right_wall, wood_right)
	draw_polyline(right_wall + PackedVector2Array([right_wall[0]]), ink, 2.5, true)
	draw_colored_polygon(lid, lid_color)
	draw_polyline(lid + PackedVector2Array([lid[0]]), ink, 2.5, true)
	# Golden clasp
	draw_rect(Rect2(-4, -26, 8, 7), ink)
	draw_rect(Rect2(-3, -25, 6, 5), Color("ffd25a"))

func _draw_iso_market(ink: Color) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 2), 36.0, Color(0.1, 0.15, 0.06, 0.26))
	draw_set_transform(Vector2.ZERO)
	var wood_left: Color = Color("c98f4b")
	var wood_right: Color = Color("9e6b30")
	# Counter base (isometric diamond box)
	var left_base: PackedVector2Array = PackedVector2Array([Vector2(-30, -12), Vector2(0, 3), Vector2(0, -21), Vector2(-30, -36)])
	var right_base: PackedVector2Array = PackedVector2Array([Vector2(0, 3), Vector2(30, -12), Vector2(30, -36), Vector2(0, -21)])
	var counter_top: PackedVector2Array = PackedVector2Array([Vector2(-32, -36), Vector2(0, -20), Vector2(32, -36), Vector2(0, -52)])
	draw_colored_polygon(left_base, wood_left)
	draw_polyline(left_base + PackedVector2Array([left_base[0]]), ink, 2.5, true)
	draw_colored_polygon(right_base, wood_right)
	draw_polyline(right_base + PackedVector2Array([right_base[0]]), ink, 2.5, true)
	draw_colored_polygon(counter_top, Color("f5e3b0"))
	draw_polyline(counter_top + PackedVector2Array([counter_top[0]]), ink, 2.5, true)
	# Produce display on counter
	for item_pt: Vector2 in [Vector2(-10, -35), Vector2(0, -31), Vector2(10, -35)]:
		draw_circle(item_pt, 4.2, ink)
		draw_circle(item_pt, 3.0, Color("e3533e") if item_pt.x < 0 else (Color("f7bc32") if item_pt.x == 0 else Color("5fb230")))
	# Support posts
	draw_line(Vector2(-26, -36), Vector2(-26, -64), ink, 5.0)
	draw_line(Vector2(26, -36), Vector2(26, -64), ink, 5.0)
	# Isometric striped market awning
	var awning_left: PackedVector2Array = PackedVector2Array([Vector2(-36, -54), Vector2(0, -38), Vector2(0, -74), Vector2(-30, -64)])
	var awning_right: PackedVector2Array = PackedVector2Array([Vector2(0, -38), Vector2(36, -54), Vector2(30, -64), Vector2(0, -74)])
	draw_colored_polygon(awning_left, Color("d6453a"))
	draw_colored_polygon(awning_right, Color("b8352b"))
	for stripe: float in [-22.0, -10.0, 10.0, 22.0]:
		draw_line(Vector2(stripe * 0.6, -66), Vector2(stripe, -48), Color("f5e3b0"), 4.5, true)
	draw_polyline(awning_left + PackedVector2Array([awning_left[0]]), ink, 2.5, true)
	draw_polyline(awning_right + PackedVector2Array([awning_right[0]]), ink, 2.5, true)

func _draw_iso_cottage(ink: Color) -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 2), 40.0, Color(0.1, 0.15, 0.06, 0.28))
	draw_set_transform(Vector2.ZERO)
	# Chimney smoke puffs (animated when not paused)
	if _phase > 0.0:
		for puff_i: int in range(2):
			var progress: float = fmod(_phase * 0.55 + float(puff_i) * 0.5, 1.0)
			var puff_pos: Vector2 = Vector2(14.0 + sin(progress * TAU) * 3.0, -76.0 - progress * 14.0)
			draw_circle(puff_pos, 3.5 + progress * 3.0, Color(0.96, 0.94, 0.88, (1.0 - progress) * 0.55))
	# Chimney
	draw_rect(Rect2(8, -78, 11, 20), ink)
	draw_rect(Rect2(10, -76, 7, 16), Color("9e5540"))
	var wall_left_color: Color = Color("f5e3b0")
	var wall_right_color: Color = Color("dfc99b")
	# Left isometric wall & Right isometric wall (fits inside Rect2(-40,-83,80,83))
	var left_wall: PackedVector2Array = PackedVector2Array([Vector2(-34, -14), Vector2(0, 3), Vector2(0, -37), Vector2(-34, -54)])
	var right_wall: PackedVector2Array = PackedVector2Array([Vector2(0, 3), Vector2(34, -14), Vector2(34, -54), Vector2(0, -37)])
	draw_colored_polygon(left_wall, wall_left_color)
	draw_polyline(left_wall + PackedVector2Array([left_wall[0]]), ink, 2.6, true)
	draw_colored_polygon(right_wall, wall_right_color)
	draw_polyline(right_wall + PackedVector2Array([right_wall[0]]), ink, 2.6, true)
	# Gable triangle on left wall
	var gable: PackedVector2Array = PackedVector2Array([Vector2(-34, -54), Vector2(0, -37), Vector2(-17, -72)])
	draw_colored_polygon(gable, wall_left_color.lightened(0.04))
	draw_polyline(gable + PackedVector2Array([gable[0]]), ink, 2.5, true)
	# Isometric roof slope (matching 03-trong-game-ban-ngay.png)
	var roof_tint: Color = Color("c85a40") if color == Color("bc8340") else color
	var roof_main: PackedVector2Array = PackedVector2Array([Vector2(-19, -75), Vector2(17, -82), Vector2(38, -51), Vector2(0, -34)])
	var roof_eave: PackedVector2Array = PackedVector2Array([Vector2(-38, -52), Vector2(-19, -75), Vector2(0, -34)])
	draw_colored_polygon(roof_eave, roof_tint.darkened(0.18))
	draw_polyline(roof_eave + PackedVector2Array([roof_eave[0]]), ink, 2.5, true)
	draw_colored_polygon(roof_main, roof_tint)
	# Roof tile lines
	draw_line(Vector2(-9, -55), Vector2(26, -66), roof_tint.lightened(0.14), 2.2, true)
	draw_line(Vector2(-4, -45), Vector2(32, -57), roof_tint.darkened(0.12), 2.0, true)
	draw_polyline(roof_main + PackedVector2Array([roof_main[0]]), ink, 2.8, true)
	# Wooden door on right wall
	var door: PackedVector2Array = PackedVector2Array([Vector2(10, -2), Vector2(22, -8), Vector2(22, -28), Vector2(10, -22)])
	draw_colored_polygon(door, Color("8c5828"))
	draw_polyline(door + PackedVector2Array([door[0]]), ink, 2.2, true)
	draw_circle(Vector2(19, -14), 1.5, Color("ffd25a"))
	# Isometric window on left wall (glows gold at night)
	var window_color: Color = Color("ffd25a") if (GameClock.minute >= 1080 or GameClock.minute < 360) else Color("8ed2f6")
	var win: PackedVector2Array = PackedVector2Array([Vector2(-24, -27), Vector2(-10, -20), Vector2(-10, -34), Vector2(-24, -41)])
	draw_colored_polygon(win, window_color)
	draw_polyline(win + PackedVector2Array([win[0]]), ink, 2.2, true)
	draw_line(Vector2(-17, -23.5), Vector2(-17, -37.5), ink, 1.5)
	# Window flower box
	draw_line(Vector2(-25, -26), Vector2(-9, -18), Color("5fb230"), 3.5, true)
	draw_circle(Vector2(-20, -24), 2.0, Color("e3533e"))
	draw_circle(Vector2(-14, -21), 2.0, Color("f7bc32"))
