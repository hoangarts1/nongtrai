## MachinePlacementPreview — manifest ghost projected by the existing grid API.
class_name MachinePlacementPreview
extends Control

static var _pivot_loaded: bool = false
static var _shared_pivot: Vector2
var image: TextureRect
var _extent: Vector2
var _color: Color
var _pivot: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	image = LifeHudParts.texture(self,null,0)
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not _pivot_loaded:
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/machines/machines_manifest.json"))
		var pivot: Array = manifest.get("pivot_2x",[])
		_shared_pivot = Vector2(float(pivot[0]),float(pivot[1])) if pivot.size()==2 else Vector2.ZERO
		_pivot_loaded = true
	_pivot = _shared_pivot
	hide()

func display(world: GrayBoxWorld, cell: Vector2i, machine_id: StringName, _rotation: int, valid: bool) -> void:
	var machine: MachineData = DataRegistry.get_machine(machine_id)
	if machine==null:
		hide()
		return
	show()
	position = world.grid.cell_to_screen(cell)
	_extent = Vector2(world.CONFIG.tile_size)*world.camera.zoom
	_color = LifeTheme.get_theme().get_color(&"green" if valid else &"red",&"LifeTokens")
	image.texture = LifeMachinePresenter.art(machine,false)
	if image.texture!=null:
		image.position = -_pivot*world.camera.zoom
		image.size = Vector2(image.texture.get_size())*world.camera.zoom
	image.modulate = Color(_color,0.65)
	queue_redraw()

func _draw() -> void:
	var diamond: PackedVector2Array = IsometricGrid.diamond(_extent)
	draw_colored_polygon(diamond,Color(_color,0.25))
	for index: int in range(diamond.size()):
		draw_line(diamond[index],diamond[(index+1)%diamond.size()],_color,3.0,true)
