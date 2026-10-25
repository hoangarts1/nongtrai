## ToolActionController — connects hotbar tools, mouse targeting and farm actions.
class_name ToolActionController
extends Node

var _world: GrayBoxWorld
var _farm_state: FarmGridState
var _inventory: InventoryState
var _farm_view: Node
var _player: Player
var _inventory_panel: InventoryPanel
var _debug_menu: DebugMenu
var _selected_tool: StringName = &"hoe"
var _selected_crop: StringName = &"turnip"
var _hovered_cell: Vector2i
var _hovered_valid: bool = false

func configure(
	world: GrayBoxWorld,
	farm_state: FarmGridState,
	inventory: InventoryState,
	farm_view: Node,
	player: Player,
	inventory_panel: InventoryPanel,
	debug_menu: DebugMenu
) -> void:
	_world = world
	_farm_state = farm_state
	_inventory = inventory
	_farm_view = farm_view
	_player = player
	_inventory_panel = inventory_panel
	_debug_menu = debug_menu

func select_tool(tool_id: StringName) -> void:
	var tool_data: Resource = DataRegistry.get_tool(tool_id)
	if tool_data == null:
		return
	_selected_tool = tool_data.get("action_id")

func select_seed() -> void:
	_selected_tool = &"seed"

func get_selected_tool() -> StringName:
	return _selected_tool

func _process(_delta: float) -> void:
	if _world == null or _farm_view == null:
		return
	var cell_variant: Variant = _world.pick_cell(get_viewport().get_mouse_position())
	if cell_variant == null:
		_farm_view.call("set_hovered_cell", Vector2i.ZERO, false, false)
		_hovered_valid = false
		return
	_hovered_cell = cell_variant as Vector2i
	var reach: int = _reach_for_selected_tool()
	var player_cell: Vector2i = GridMath.world_to_cell(_player.global_position)
	_hovered_valid = ToolAction.is_in_reach(player_cell, _hovered_cell, reach)
	_farm_view.call("set_hovered_cell", _hovered_cell, true, _hovered_valid)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("use_tool"):
		return
	if not _hovered_valid or _is_input_locked():
		return
	_use_selected_tool()

func _use_selected_tool() -> void:
	if _selected_tool == &"harvest":
		_harvest_selected_crop()
		return
	var crop_id: StringName = _selected_crop
	if _selected_tool == &"seed":
		if not _inventory.has_item(&"turnip_seed", 1):
			return
		if not ToolAction.apply(_selected_tool, _farm_state, _hovered_cell, crop_id):
			return
		_inventory.remove_item(&"turnip_seed", 1)
		return
	ToolAction.apply(_selected_tool, _farm_state, _hovered_cell, &"")

func _harvest_selected_crop() -> void:
	var payload: Dictionary = _farm_state.get_harvest_payload(_hovered_cell)
	if not bool(payload.get("success", false)):
		return
	var product_item: StringName = payload.get("product_item", &"")
	var quantity: int = int(payload.get("quantity", 0))
	if not _inventory.can_add_item(product_item, quantity):
		return
	var result: Dictionary = _farm_state.harvest_cell(_hovered_cell)
	if bool(result.get("success", false)):
		_inventory.add_item(product_item, quantity)

func _reach_for_selected_tool() -> int:
	var tool_id: StringName = &"hoe" if _selected_tool == &"hoe" else &"watering_can"
	var tool_data: Resource = DataRegistry.get_tool(tool_id)
	if tool_data == null:
		return 0
	return int(tool_data.get("reach_cells"))

func _is_input_locked() -> bool:
	return GameClock.is_sleeping() or _inventory_panel.visible or _debug_menu.visible
