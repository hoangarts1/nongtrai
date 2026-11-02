## ToolActionController — connects hotbar tools, mouse targeting and farm actions.
class_name ToolActionController
extends Node

const TOOL_DRAG_STROKE: Script = preload("res://scripts/view/tool_drag_stroke.gd")

var _world: GrayBoxWorld
var _farm_state: FarmGridState
var _inventory: InventoryState
var _farm_view: Node
var _player: Player
var _inventory_panel: InventoryPanel
var _debug_menu: DebugMenu
var _feedback: Node
var _audio: Node
var _selected_tool: StringName = &"hoe"
var _selected_crop: StringName = &"turnip"
var _hovered_cell: Vector2i
var _hovered_valid: bool = false

var _hotbar_panel: HotbarPanel = null
var _shipping_bin_panel: Control = null
var _seed_shop_panel: Control = null
var _crop_inspector: CropInspector
var _drag_stroke: Variant = TOOL_DRAG_STROKE.new()

func configure_crop_inspector(inspector: CropInspector) -> void:
	_crop_inspector = inspector
	_crop_inspector.action_requested.connect(perform_crop_action)

func perform_crop_action(cell: Vector2i, action_id: StringName) -> void:
	if _is_input_locked() or not _player.movement_enabled or not action_id in [&"water", &"harvest"]:
		return
	var player_cell: Vector2i = _player.get_cell()
	if not ToolAction.is_in_reach(player_cell, cell, _reach_for_selected_tool()):
		_show_feedback("UI_CROP_OUT_OF_REACH")
		return
	var previous_cell: Vector2i = _hovered_cell
	var previous_tool: StringName = _selected_tool
	_hovered_cell = cell
	_selected_tool = action_id
	_use_selected_tool()
	_hovered_cell = previous_cell
	_selected_tool = previous_tool

func configure(
	world: GrayBoxWorld,
	farm_state: FarmGridState,
	inventory: InventoryState,
	farm_view: Node,
	player: Player,
	inventory_panel: InventoryPanel,
	debug_menu: DebugMenu,
	feedback: Node = null,
	audio: Node = null,
	hotbar_panel: HotbarPanel = null,
	shipping_bin_panel: Control = null,
	seed_shop_panel: Control = null
) -> void:
	_world = world
	_farm_state = farm_state
	_inventory = inventory
	_farm_view = farm_view
	_player = player
	_inventory_panel = inventory_panel
	_debug_menu = debug_menu
	_feedback = feedback
	_audio = audio
	_hotbar_panel = hotbar_panel
	_shipping_bin_panel = shipping_bin_panel
	_seed_shop_panel = seed_shop_panel
	if _hotbar_panel != null:
		_hotbar_panel.slot_selected.connect(_on_slot_selected)

func _on_slot_selected(slot_index: int) -> void:
	if _inventory == null:
		return
	var slots: Array[Dictionary] = _inventory.get_slots()
	if slot_index >= 0 and slot_index < slots.size():
		var item_id: StringName = slots[slot_index]["item_id"]
		var crop_data: Resource = DataRegistry.get_crop_for_seed(item_id)
		if crop_data != null:
			_selected_tool = &"seed"
			_selected_crop = crop_data.get("crop_id")

func select_tool(tool_id: StringName) -> void:
	if tool_id == &"harvest":
		_selected_tool = &"harvest"
		return
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
	var player_cell: Vector2i = _player.get_cell()
	_hovered_valid = ToolAction.is_in_reach(player_cell, _hovered_cell, reach)
	_farm_view.call("set_hovered_cell", _hovered_cell, true, _hovered_valid)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var handled: bool = _drag_stroke.handle(
			event as InputEventMouse,
			_world,
			_farm_view,
			_farm_state,
			_selected_tool,
			_crop_inspector,
			_can_apply_drag,
			_apply_drag_cell
		)
		if handled:
			get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("use_tool"):
		return
	if not _can_apply_drag() or not _hovered_valid:
		return
	_use_selected_tool()

func _can_apply_drag() -> bool:
	return not _is_input_locked() and _player != null and _player.movement_enabled

func _apply_drag_cell(cell: Vector2i) -> bool:
	if not _can_apply_drag():
		return false
	var player_cell: Vector2i = _player.get_cell()
	if not ToolAction.is_in_reach(player_cell, cell, _reach_for_selected_tool()):
		return false
	_hovered_cell = cell
	_hovered_valid = true
	_use_selected_tool()
	return true

func _use_selected_tool() -> void:
	if _selected_tool == &"harvest":
		_harvest_selected_crop()
		return
	if _selected_tool == &"seed":
		var seed_item_id: StringName = &""
		var crop_id: StringName = &""
		if _hotbar_panel != null:
			var slot: Dictionary = _hotbar_panel.get_selected_slot()
			if not slot.is_empty():
				var candidate_seed: StringName = StringName(slot.get("item_id", ""))
				var candidate_crop: Resource = DataRegistry.get_crop_for_seed(candidate_seed)
				if candidate_crop != null and _inventory.has_item(candidate_seed, 1):
					seed_item_id = candidate_seed
					crop_id = StringName(candidate_crop.get("crop_id"))
		if seed_item_id.is_empty():
			for s_item: Resource in DataRegistry.get_seed_items():
				var s_id: StringName = s_item.get("item_id")
				if _inventory.has_item(s_id, 1):
					var c_data: Resource = DataRegistry.get_crop_for_seed(s_id)
					var seasons: PackedStringArray = c_data.get("seasons") if c_data != null else PackedStringArray()
					if seasons.is_empty() or seasons.has(String(GameClock.season)):
						seed_item_id = s_id
						crop_id = StringName(c_data.get("crop_id"))
						break
			if seed_item_id.is_empty():
				for s_item: Resource in DataRegistry.get_seed_items():
					var s_id: StringName = s_item.get("item_id")
					if _inventory.has_item(s_id, 1):
						var c_data: Resource = DataRegistry.get_crop_for_seed(s_id)
						seed_item_id = s_id
						crop_id = StringName(c_data.get("crop_id")) if c_data != null else &""
						break
		if seed_item_id.is_empty() or not _inventory.has_item(seed_item_id, 1):
			_show_feedback("UI_FEEDBACK_NO_SEEDS")
			return
		var crop_data: Resource = DataRegistry.get_crop(crop_id)
		var crop_seasons: PackedStringArray = crop_data.get("seasons") if crop_data != null else PackedStringArray()
		if not crop_seasons.is_empty() and not crop_seasons.has(String(GameClock.season)):
			_show_feedback("UI_FEEDBACK_OUT_OF_SEASON")
			return
		if not ToolAction.apply(_selected_tool, _farm_state, _hovered_cell, crop_id):
			_show_feedback("UI_FEEDBACK_NOT_READY")
			return
		_inventory.remove_item(seed_item_id, 1)
		_play_character_tool(&"seed")
		_play_sound(&"seed")
		_play_farm_effect(&"seed")
		return
	if not ToolAction.apply(_selected_tool, _farm_state, _hovered_cell, &""):
		_show_feedback("UI_FEEDBACK_NOT_READY")
	else:
		_play_character_tool(_selected_tool)
		_play_sound(&"hoe" if _selected_tool == &"hoe" else &"water")
		_play_farm_effect(_selected_tool)

func _harvest_selected_crop() -> void:
	var payload: Dictionary = _farm_state.get_harvest_payload(_hovered_cell)
	if not bool(payload.get("success", false)):
		var remaining_days: int = _farm_state.get_growth_remaining(_hovered_cell)
		if remaining_days > 0:
			_show_feedback("UI_FEEDBACK_NOT_READY_DAYS", remaining_days)
		else:
			_show_feedback("UI_FEEDBACK_NOT_READY")
		return
	var product_item: StringName = payload.get("product_item", &"")
	var quantity: int = int(payload.get("quantity", 0))
	if not _inventory.can_add_item(product_item, quantity):
		_show_feedback("UI_FEEDBACK_INVENTORY_FULL")
		return
	var result: Dictionary = _farm_state.harvest_cell(_hovered_cell)
	if bool(result.get("success", false)):
		_inventory.add_item(product_item, quantity)
		_play_character_tool(&"harvest")
		_play_sound(&"harvest")
		_play_farm_effect(&"harvest")
	elif _farm_state.get_plot(_hovered_cell).is_empty():
		_show_feedback("UI_FEEDBACK_NOT_READY")

func _show_feedback(key: StringName, format_value: int = -1) -> void:
	if _feedback != null:
		var message: String = tr(String(key))
		if format_value >= 0:
			message = message % format_value
		_feedback.call("show_message", message)

func _play_sound(sound_id: StringName) -> void:
	if _audio != null:
		_audio.call("play_sound", sound_id)

func _play_character_tool(tool_id: StringName) -> void:
	if _player == null:
		return
	var avatar: PlaceholderAvatar2D = _player.get_node_or_null("Visual") as PlaceholderAvatar2D
	if avatar != null:
		avatar.play_tool(tool_id)

func _play_farm_effect(action_id: StringName) -> void:
	if _farm_view != null and _farm_view.has_method(&"play_action_fx"):
		_farm_view.call(&"play_action_fx", _hovered_cell, action_id)

func _reach_for_selected_tool() -> int:
	var tool_id: StringName = &"hoe" if _selected_tool == &"hoe" else &"watering_can"
	var tool_data: Resource = DataRegistry.get_tool(tool_id)
	if tool_data == null:
		return 0
	return int(tool_data.get("reach_cells"))

func _is_input_locked() -> bool:
	return GameClock.is_sleeping() or _inventory_panel.visible or _debug_menu.visible or (_shipping_bin_panel != null and _shipping_bin_panel.visible) or (_seed_shop_panel != null and _seed_shop_panel.visible)
