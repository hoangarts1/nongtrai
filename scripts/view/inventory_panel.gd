## InventoryPanel — minimal inventory view driven by InventoryState.
class_name InventoryPanel
extends PanelContainer

signal inventory_toggled(is_open: bool)

var _inventory
var _player: Player
var _list: VBoxContainer

func _ready() -> void:
	visible = false
	_build_ui()

func configure(inventory, player: Player) -> void:
	_inventory = inventory
	_player = player
	_inventory.inventory_changed.connect(_on_inventory_changed)
	_on_inventory_changed(_inventory.get_slots())

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_inventory") or _inventory == null:
		return
	toggle_inventory()
	get_viewport().set_input_as_handled()

func toggle_inventory() -> bool:
	if _inventory == null or GameClock.is_sleeping():
		return false
	visible = not visible
	_player.movement_enabled = not visible
	_update_list()
	inventory_toggled.emit(visible)
	return true

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 18)
	add_child(margin)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 6)
	margin.add_child(_list)

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	if is_node_ready():
		_update_list()

func _update_list() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	var title: Label = Label.new()
	title.text = tr("UI_INVENTORY_TITLE")
	title.add_theme_font_size_override("font_size", 24)
	var heading: HBoxContainer = HBoxContainer.new()
	heading.add_theme_constant_override("separation", 12)
	_list.add_child(heading)
	heading.add_child(title)
	var close_button: Button = Button.new()
	close_button.text = tr("UI_CLOSE")
	close_button.tooltip_text = tr("UI_CLOSE")
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	close_button.pressed.connect(toggle_inventory)
	heading.add_child(close_button)
	if _inventory == null or _inventory.get_slots().is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = tr("UI_INVENTORY_EMPTY")
		_list.add_child(empty_label)
		return
	for slot: Dictionary in _inventory.get_slots():
		var item_data: Resource = DataRegistry.get_item(slot["item_id"])
		var row: Label = Label.new()
		row.text = "%s  x%d" % [item_data.get("display_name"), slot["quantity"]]
		_list.add_child(row)
