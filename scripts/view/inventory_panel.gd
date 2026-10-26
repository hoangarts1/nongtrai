## InventoryPanel — fixed header/close button with a scrollable inventory list.
class_name InventoryPanel
extends PanelContainer

signal inventory_toggled(is_open: bool)
var _inventory: InventoryState
var _player: Player
var _list: VBoxContainer

func _ready() -> void:
	visible = false
	_build_ui()

func configure(inventory: InventoryState, player: Player) -> void:
	_inventory = inventory
	_player = player
	_inventory.inventory_changed.connect(_on_inventory_changed)
	_update_list()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory") and _inventory != null:
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

func close_inventory() -> void:
	if visible:
		toggle_inventory()

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	var title: Label = Label.new()
	title.text = tr("UI_INVENTORY_TITLE")
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button: Button = Button.new()
	close_button.name = "CloseInventory"
	close_button.text = tr("UI_CLOSE") + " (Esc)"
	close_button.pressed.connect(close_inventory)
	header.add_child(close_button)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "InventoryScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	if is_node_ready():
		_update_list()

func _update_list() -> void:
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	if _inventory == null or _inventory.get_slots().is_empty():
		var empty: Label = Label.new()
		empty.text = tr("UI_INVENTORY_EMPTY")
		_list.add_child(empty)
		return
	for slot: Dictionary in _inventory.get_slots():
		var item: Resource = DataRegistry.get_item(slot["item_id"])
		var row: HBoxContainer = HBoxContainer.new()
		row.custom_minimum_size.y = 44
		row.add_theme_constant_override("separation", 14)
		var swatch: ColorRect = ColorRect.new()
		swatch.custom_minimum_size = Vector2(24, 24)
		swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		swatch.color = item.get("color")
		row.add_child(swatch)
		var label: Label = Label.new()
		label.text = tr(String(item.get("display_name_key")))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(label)
		var quantity: Label = Label.new()
		quantity.text = "×%d" % int(slot["quantity"])
		row.add_child(quantity)
		_list.add_child(row)
