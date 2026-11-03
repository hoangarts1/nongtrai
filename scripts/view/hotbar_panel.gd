## HotbarPanel — request adapter; the eight-slot view owns no inventory.
## API:
##   func configure(inventory: InventoryState) -> void
##   func get_selected_slot() -> Dictionary
##   func select_slot(slot_index: int) -> void
class_name HotbarPanel
extends PanelContainer

signal slot_selected(slot_index: int)
var toolbar: LifeHudToolbar
var _inventory: InventoryState
var _selected_slot_index: int = -1
var _active_tool: StringName = &"hoe"
var _window_start: int = 0
var _slot_row: HBoxContainer
var _tool_row: HBoxContainer
var _callbacks: Dictionary = {}

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudClearPanel")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Keep documented legacy child paths hidden for public API compatibility.
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.hide()
	add_child(margin)
	var content: VBoxContainer = LifeHudParts.column(margin)
	content.name = "Content"
	var caption: Label = LifeHudParts.label(content)
	caption.name = "SelectionCaption"
	caption.hide()
	_slot_row = HBoxContainer.new()
	_slot_row.name = "HBoxContainer"
	_slot_row.hide()
	content.add_child(_slot_row)
	_tool_row = HBoxContainer.new()
	_tool_row.name = "ToolRow"
	_tool_row.hide()
	content.add_child(_tool_row)
	for index: int in range(9):
		var button: Button = Button.new()
		_slot_row.add_child(button)
		button.pressed.connect(_select_slot.bind(index))
	toolbar = preload("res://ui/hud/toolbar.tscn").instantiate() as LifeHudToolbar
	add_child(toolbar)
	toolbar.tool_requested.connect(_activate_tool)
	toolbar.item_requested.connect(_select_slot)

func configure(inventory: InventoryState) -> void:
	_inventory = inventory
	if not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)
	_render_slots()

func get_selected_slot() -> Dictionary:
	if _inventory == null or _selected_slot_index < 0:
		return {}
	var slots: Array[Dictionary] = _inventory.get_slots()
	return slots[_selected_slot_index] if _selected_slot_index < slots.size() else {}

func register_tool(tool_id: StringName, label: String, callback: Callable) -> Button:
	_callbacks[tool_id] = callback
	var button: Button = Button.new()
	button.name = "Tool_%s" % tool_id
	button.tooltip_text = label
	_tool_row.add_child(button)
	button.pressed.connect(_activate_tool.bind(tool_id))
	return button

func refresh_readability() -> void:
	_render_slots()

func select_slot(slot_index: int) -> void:
	_select_slot(slot_index)

func _select_slot(slot_index: int) -> void:
	if _inventory == null or slot_index < 0 or slot_index >= _inventory.get_slots().size():
		return
	_selected_slot_index = slot_index
	_active_tool = &""
	_window_start = (slot_index / 5)*5
	slot_selected.emit(slot_index)
	_render_slots()

func _activate_tool(tool_id: StringName) -> void:
	_active_tool = tool_id
	var callback: Callable = _callbacks.get(tool_id,Callable())
	if callback.is_valid():
		callback.call()
	_render_slots()

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	if _inventory.get_slots().size() <= _selected_slot_index:
		_selected_slot_index = -1
		_active_tool = &"hoe"
		_window_start = 0
	_render_slots()

func _render_slots() -> void:
	if toolbar != null and _inventory != null:
		toolbar.display(_inventory.get_slots(),_selected_slot_index,_active_tool,_window_start)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_render_slots()

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or event.is_echo() or GameClock.is_sleeping():
		return
	for index: int in range(8):
		if event.is_action_pressed("hotbar_%d" % (index+1)):
			toolbar.request(index)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("hotbar_9"):
		_select_slot(8)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tool_next") or event.is_action_pressed("tool_prev"):
		toolbar.request(posmod(toolbar.active_index+(1 if event.is_action_pressed("tool_next") else -1),8))
		get_viewport().set_input_as_handled()
