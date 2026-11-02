## SoilPresentation — replaceable 2D furrow and moisture decoration, without plot state.
class_name SoilPresentation
extends RefCounted

const CATALOG: FarmingArtCatalog = preload("res://data/art/farming/chibi_farming_catalog.tres")
static func render(soil: Polygon2D, tilled: bool, watered: bool, _cell: Vector2i) -> void:
	for child: Node in soil.get_children():
		child.free()
	soil.color = Color.TRANSPARENT
	if not tilled:
		return
	for index: int in range(3):
		var furrow: Line2D = Line2D.new()
		furrow.name = "SoilFurrow_%d" % index
		var offset: Vector2 = Vector2(-10 + index * 10, -5 + index * 5)
		furrow.points = PackedVector2Array([offset + Vector2(-9, 4), offset + Vector2(9, -5)])
		furrow.width = 2
		furrow.default_color = CATALOG.furrow_color
		soil.add_child(furrow)
	if watered:
		var sheen: Polygon2D = Polygon2D.new()
		sheen.name = "MoistureSheen"
		sheen.polygon = IsometricGrid.diamond(Vector2(26, 13))
		sheen.color = Color(CATALOG.water_effect_color, 0.28)
		soil.add_child(sheen)
