## HotbarPanel — selectable view of inventory stacks for tool/item selection.
## API:
##   func configure(inventory: InventoryState) -> void
##   func get_selected_slot() -> Dictionary
class_name HotbarPanel
extends PanelContainer

signal slot_selected(slot_index: int)

var _inventory
var _slot_row: HBoxContainer
var _tool_row: HBoxContainer
var _selected_slot_index: int = -1
var _content: VBoxContainer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func configure(inventory) -> void:
	_inventory = inventory
	_inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed(_inventory.get_slots())

func get_selected_slot() -> Dictionary:
	if _inventory == null or _selected_slot_index < 0:
		return {}
	var slots: Array[Dictionary] = _inventory.get_slots()
	if _selected_slot_index >= slots.size():
		return {}
	return slots[_selected_slot_index]

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "MarginContainer"
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 8)
	add_child(margin)
	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.add_theme_constant_override("separation", 4)
	margin.add_child(_content)
	_slot_row = HBoxContainer.new()
	_slot_row.name = "HBoxContainer"
	_slot_row.add_theme_constant_override("separation", 4)
	_content.add_child(_slot_row)
	_tool_row = HBoxContainer.new()
	_tool_row.name = "ToolRow"
	_tool_row.add_theme_constant_override("separation", 4)
	_content.add_child(_tool_row)

func register_tool(tool_id: StringName, label: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.name = "Tool_%s" % tool_id
	button.custom_minimum_size = Vector2(84, 42)
	button.toggle_mode = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	var tool_label: Label = Label.new()
	tool_label.name = "ToolLabel"
	tool_label.text = label
	tool_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tool_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tool_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tool_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(tool_label)
	button.pressed.connect(callback)
	_tool_row.add_child(button)
	return button

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	_render_slots()

func _render_slots() -> void:
	if _slot_row == null:
		return
	for child: Node in _slot_row.get_children():
		_slot_row.remove_child(child)
		child.free()
	if _inventory == null:
		return
	var slots: Array[Dictionary] = _inventory.get_slots()
	for index: int in range(_inventory.capacity):
		var button: Button = Button.new()
		button.name = "Slot_%d" % (index + 1)
		button.custom_minimum_size = Vector2(52, 64)
		button.toggle_mode = true
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		var content: VBoxContainer = VBoxContainer.new()
		content.name = "Content"
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.set_anchors_preset(Control.PRESET_FULL_RECT)
		content.offset_left = 4.0
		content.offset_top = 4.0
		content.offset_right = -4.0
		content.offset_bottom = -6.0
		button.add_child(content)
		var key_label: Label = Label.new()
		key_label.name = "Key"
		key_label.text = str(index + 1) if index < 9 else "-"
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(key_label)
		var name_label: Label = Label.new()
		name_label.name = "Name"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var quantity_label: Label = Label.new()
		quantity_label.name = "Quantity"
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if index < slots.size():
			var item_data: Resource = DataRegistry.get_item(slots[index]["item_id"])
			name_label.text = tr(String(item_data.get("display_name_key")))
			quantity_label.text = "x%d" % slots[index]["quantity"]
			button.tooltip_text = name_label.text
		else:
			name_label.text = tr("UI_HOTBAR_EMPTY")
			quantity_label.text = ""
			button.tooltip_text = tr("UI_HOTBAR_EMPTY")
		content.add_child(name_label)
		content.add_child(quantity_label)
		button.button_pressed = index == _selected_slot_index
		button.pressed.connect(func() -> void: _select_slot(index))
		_slot_row.add_child(button)

func _select_slot(slot_index: int) -> void:
	if _inventory == null or slot_index >= _inventory.get_slots().size():
		return
	_selected_slot_index = slot_index
	call_deferred("_render_slots")
	slot_selected.emit(slot_index)
