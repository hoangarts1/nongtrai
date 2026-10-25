## HotbarPanel — selectable view of inventory stacks for tool/item selection.
## API:
##   func configure(inventory: InventoryState) -> void
##   func get_selected_slot() -> Dictionary
class_name HotbarPanel
extends PanelContainer

signal slot_selected(slot_index: int)

var _inventory
var _slot_row: HBoxContainer
var _selected_slot_index: int = -1

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
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 8)
	add_child(margin)
	_slot_row = HBoxContainer.new()
	_slot_row.add_theme_constant_override("separation", 4)
	margin.add_child(_slot_row)

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	_render_slots()

func _render_slots() -> void:
	if _slot_row == null:
		return
	for child: Node in _slot_row.get_children():
		child.queue_free()
	if _inventory == null:
		return
	var slots: Array[Dictionary] = _inventory.get_slots()
	for index: int in range(_inventory.capacity):
		var button: Button = Button.new()
		button.custom_minimum_size = Vector2(68, 52)
		button.toggle_mode = true
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.tooltip_text = tr("UI_HOTBAR_EMPTY") if index >= slots.size() else String(DataRegistry.get_item(slots[index]["item_id"]).get("display_name"))
		if index < slots.size():
			var item_data: Resource = DataRegistry.get_item(slots[index]["item_id"])
			button.text = "%s\nx%d" % [item_data.get("display_name"), slots[index]["quantity"]]
		else:
			button.text = "-"
		button.button_pressed = index == _selected_slot_index
		button.pressed.connect(func() -> void: _select_slot(index))
		_slot_row.add_child(button)

func _select_slot(slot_index: int) -> void:
	if _inventory == null or slot_index >= _inventory.get_slots().size():
		return
	_selected_slot_index = slot_index
	_render_slots()
	slot_selected.emit(slot_index)
