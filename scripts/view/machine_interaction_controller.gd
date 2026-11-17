## MachineInteractionController — selects a placed machine by mouse cell and opens operation UI.
## API:
##   func configure(world: GrayBoxWorld, placements: MachinePlacementState, panel: Control) -> void
class_name MachineInteractionController
extends Node

var _world: GrayBoxWorld
var _placements: MachinePlacementState
var _panel: Control
var _selected_cell: Vector2i
var _has_selection: bool = false

func configure(world: GrayBoxWorld, placements: MachinePlacementState, panel: Control) -> void:
	_world = world
	_placements = placements
	_panel = panel

func _process(_delta: float) -> void:
	if _world == null or _placements == null:
		return
	var picked: Variant = _world.pick_cell(get_viewport().get_mouse_position())
	if picked is Vector2i:
		var cell: Vector2i = picked
		_has_selection = not _placements.get_placement(cell).is_empty()
		_selected_cell = cell
	else:
		_has_selection = false

func _unhandled_input(event: InputEvent) -> void:
	if _panel == null or not _has_selection or not event.is_action_pressed("interact"):
		return
	if GameClock.is_sleeping() or not _world.player.movement_enabled:
		return
	_panel.call("open_machine", _selected_cell)
	get_viewport().set_input_as_handled()
