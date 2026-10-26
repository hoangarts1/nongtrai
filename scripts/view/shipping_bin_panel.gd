## ShippingBinPanel — modal UI for selling inventory items through the shipping bin.
## API:
##   func configure(inventory, wallet, player: Player, feedback: Node = null) -> void
##   func open() -> void
##   func close() -> void
##   func is_open() -> bool
##   signal item_sold(item_id: StringName, quantity: int, total_price: int)
class_name ShippingBinPanel
extends PanelContainer

signal item_sold(item_id: StringName, quantity: int, total_price: int)
signal panel_toggled(is_open: bool)

var _inventory: InventoryState
var _wallet: WalletState
var _player: Player
var _feedback: Node

var _list_container: VBoxContainer
var _detail_box: VBoxContainer
var _selected_item_id: StringName = &""
var _selected_quantity: int = 1
var _qty_label: Label
var _total_label: Label
var _confirm_button: Button

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func configure(
	inventory,
	wallet,
	player: Player,
	feedback: Node = null
) -> void:
	_inventory = inventory
	_wallet = wallet
	_player = player
	_feedback = feedback
	if _inventory != null:
		_inventory.inventory_changed.connect(_on_inventory_changed)

func open() -> void:
	if GameClock.is_sleeping():
		return
	visible = true
	if _player != null:
		_player.movement_enabled = false
	_selected_item_id = &""
	_selected_quantity = 1
	_render()
	panel_toggled.emit(true)

func close() -> void:
	if not visible:
		return
	visible = false
	if _player != null:
		_player.movement_enabled = true
	panel_toggled.emit(false)

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func is_open() -> bool:
	return visible

func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact")):
		close()
		get_viewport().set_input_as_handled()

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	if visible:
		_render()

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)
	
	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(main_vbox)
	
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	main_vbox.add_child(header)
	
	var title: Label = Label.new()
	title.text = tr("UI_SHIPPING_BIN_TITLE")
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn: Button = Button.new()
	close_btn.text = tr("UI_CLOSE")
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	close_btn.pressed.connect(close)
	header.add_child(close_btn)
	
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 140)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)
	
	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_container.add_theme_constant_override("separation", 4)
	scroll.add_child(_list_container)
	
	_detail_box = VBoxContainer.new()
	_detail_box.add_theme_constant_override("separation", 8)
	main_vbox.add_child(_detail_box)
	
	var qty_row: HBoxContainer = HBoxContainer.new()
	qty_row.add_theme_constant_override("separation", 8)
	_detail_box.add_child(qty_row)
	
	var minus_btn: Button = Button.new()
	minus_btn.text = "-"
	minus_btn.custom_minimum_size = Vector2(32, 32)
	minus_btn.pressed.connect(func() -> void: _change_quantity(-1))
	qty_row.add_child(minus_btn)
	
	_qty_label = Label.new()
	_qty_label.text = "1"
	_qty_label.custom_minimum_size = Vector2(40, 32)
	_qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_qty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	qty_row.add_child(_qty_label)
	
	var plus_btn: Button = Button.new()
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(32, 32)
	plus_btn.pressed.connect(func() -> void: _change_quantity(1))
	qty_row.add_child(plus_btn)
	
	var max_btn: Button = Button.new()
	max_btn.text = tr("UI_MAX")
	max_btn.pressed.connect(_set_max_quantity)
	qty_row.add_child(max_btn)
	
	_total_label = Label.new()
	_total_label.text = tr("UI_TOTAL_PRICE") % 0
	_total_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	_detail_box.add_child(_total_label)
	
	_confirm_button = Button.new()
	_confirm_button.text = tr("UI_CONFIRM_SELL")
	_confirm_button.custom_minimum_size = Vector2(120, 36)
	_confirm_button.pressed.connect(_confirm_sale)
	_detail_box.add_child(_confirm_button)

func _render() -> void:
	if _list_container == null:
		return
	for child: Node in _list_container.get_children():
		child.queue_free()
	
	if _inventory == null:
		return
	
	var sellable_count: int = 0
	var slots: Array[Dictionary] = _inventory.get_slots()
	for slot: Dictionary in slots:
		var item_id: StringName = slot["item_id"]
		var qty: int = slot["quantity"]
		var item_data: Resource = DataRegistry.get_item(item_id)
		if item_data == null:
			continue
		var sell_price: int = int(item_data.get("sell_price"))
		if sell_price <= 0:
			continue
		
		sellable_count += 1
		var item_btn: Button = Button.new()
		item_btn.custom_minimum_size = Vector2(0, 52)
		item_btn.toggle_mode = true
		item_btn.button_pressed = (item_id == _selected_item_id)
		
		var row: HBoxContainer = HBoxContainer.new()
		row.set_anchors_preset(Control.PRESET_FULL_RECT)
		row.offset_left = 6.0
		row.offset_right = -6.0
		row.offset_top = 4.0
		row.offset_bottom = -4.0
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_btn.add_child(row)
		
		var swatch: ColorRect = ColorRect.new()
		swatch.custom_minimum_size = Vector2(16, 16)
		swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		swatch.color = item_data.get("color") if item_data.get("color") != null else Color.WHITE
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(swatch)
		
		var name_lbl: Label = Label.new()
		name_lbl.text = "%s (x%d)" % [tr(String(item_data.get("display_name_key"))), qty]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(name_lbl)
		
		var price_lbl: Label = Label.new()
		price_lbl.text = tr("UI_SELL_PRICE") % sell_price
		price_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(price_lbl)
		
		item_btn.pressed.connect(func() -> void: _select_item(item_id))
		_list_container.add_child(item_btn)
	
	if sellable_count == 0:
		var empty_lbl: Label = Label.new()
		empty_lbl.text = tr("UI_NO_SELLABLE_ITEMS")
		_list_container.add_child(empty_lbl)
		_detail_box.visible = false
	else:
		if _selected_item_id.is_empty() or not _inventory.has_item(_selected_item_id, 1):
			# Auto-select the first available sellable item
			for slot: Dictionary in slots:
				var item_data: Resource = DataRegistry.get_item(slot["item_id"])
				if item_data != null and int(item_data.get("sell_price")) > 0:
					_selected_item_id = slot["item_id"]
					_selected_quantity = 1
					break
		_detail_box.visible = not _selected_item_id.is_empty()
		_update_detail()

func _select_item(item_id: StringName) -> void:
	_selected_item_id = item_id
	_selected_quantity = 1
	_render()

func _change_quantity(delta: int) -> void:
	if _selected_item_id.is_empty() or _inventory == null:
		return
	var max_qty: int = _inventory.get_quantity(_selected_item_id)
	_selected_quantity = clampi(_selected_quantity + delta, 1, maxi(1, max_qty))
	_update_detail()

func _set_max_quantity() -> void:
	if _selected_item_id.is_empty() or _inventory == null:
		return
	_selected_quantity = maxi(1, _inventory.get_quantity(_selected_item_id))
	_update_detail()

func _update_detail() -> void:
	if _selected_item_id.is_empty() or _inventory == null:
		_detail_box.visible = false
		return
	var item_data: Resource = DataRegistry.get_item(_selected_item_id)
	if item_data == null:
		_detail_box.visible = false
		return
	var max_qty: int = _inventory.get_quantity(_selected_item_id)
	_selected_quantity = clampi(_selected_quantity, 1, maxi(1, max_qty))
	var unit_price: int = int(item_data.get("sell_price"))
	var total: int = unit_price * _selected_quantity
	_qty_label.text = str(_selected_quantity)
	_total_label.text = tr("UI_TOTAL_PRICE") % total
	_confirm_button.disabled = (_selected_quantity <= 0 or max_qty <= 0)

func _confirm_sale() -> void:
	if _selected_item_id.is_empty() or _selected_quantity <= 0 or _inventory == null or _wallet == null:
		return
	if not _inventory.has_item(_selected_item_id, _selected_quantity):
		return
	var item_data: Resource = DataRegistry.get_item(_selected_item_id)
	if item_data == null:
		return
	var unit_price: int = int(item_data.get("sell_price"))
	var total_price: int = unit_price * _selected_quantity
	
	if _inventory.remove_item(_selected_item_id, _selected_quantity):
		_wallet.add_coins(total_price, &"sell_produce")
		item_sold.emit(_selected_item_id, _selected_quantity, total_price)
		Events.item_sold.emit(_selected_item_id, _selected_quantity, total_price)
		Events.item_delivered.emit(_selected_item_id, _selected_quantity, &"shipping_bin")
		if _feedback != null:
			_feedback.call("show_message", tr("UI_FEEDBACK_SOLD") % total_price)
		_selected_item_id = &""
		_selected_quantity = 1
		_render()
