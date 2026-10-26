## SeedShopPanel — modal UI for purchasing seeds plantable in the current season.
## API:
##   func configure(inventory, wallet, player: Player, feedback: Node = null) -> void
##   func open() -> void
##   func close() -> void
##   func is_open() -> bool
##   func try_buy_item(item_id: StringName, quantity: int) -> bool
##   signal item_purchased(item_id: StringName, quantity: int, total_price: int)
##   signal panel_toggled(is_open: bool)
class_name SeedShopPanel
extends PanelContainer

signal item_purchased(item_id: StringName, quantity: int, total_price: int)
signal panel_toggled(is_open: bool)

var _inventory: InventoryState
var _wallet: WalletState
var _player: Player
var _feedback: Node

var _list_container: VBoxContainer
var _detail_box: VBoxContainer
var _wallet_label: Label
var _qty_label: Label
var _total_label: Label
var _confirm_button: Button

var _selected_item_id: StringName = &""
var _selected_quantity: int = 1

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
	if _wallet != null and _wallet.has_signal("coins_changed"):
		_wallet.coins_changed.connect(_on_wallet_changed)
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

func _on_wallet_changed(_new_total: int, _delta: int, _reason: StringName) -> void:
	if visible:
		_update_wallet_label()
		_update_detail()

func _on_inventory_changed(_slots: Array[Dictionary]) -> void:
	if visible:
		_update_detail()

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
	title.text = tr("UI_SEED_SHOP_TITLE")
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	_wallet_label = Label.new()
	_wallet_label.text = tr("UI_WALLET_COINS") % 0
	_wallet_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	header.add_child(_wallet_label)
	
	var close_btn: Button = Button.new()
	close_btn.text = tr("UI_CLOSE")
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	close_btn.pressed.connect(close)
	header.add_child(close_btn)
	
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(380, 180)
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
	_confirm_button.text = tr("UI_CONFIRM_BUY")
	_confirm_button.custom_minimum_size = Vector2(140, 36)
	_confirm_button.pressed.connect(_confirm_purchase)
	_detail_box.add_child(_confirm_button)

func _update_wallet_label() -> void:
	if _wallet_label != null and _wallet != null:
		_wallet_label.text = tr("UI_WALLET_COINS") % _wallet.get_coins()

func _render() -> void:
	_update_wallet_label()
	if _list_container == null:
		return
	for child: Node in _list_container.get_children():
		child.queue_free()
	
	var seed_items: Array[Resource] = DataRegistry.get_seed_items()
	var current_season: String = String(GameClock.season)
	
	var in_season_first_id: StringName = &""
	
	for item_data: Resource in seed_items:
		if item_data == null:
			continue
		var seed_id: StringName = item_data.get("item_id")
		var crop_data: Resource = DataRegistry.get_crop_for_seed(seed_id)
		var is_in_season: bool = true
		var seasons_text: String = ""
		
		if crop_data != null and not crop_data.seasons.is_empty():
			is_in_season = crop_data.seasons.has(current_season)
			var s_names: Array[String] = []
			for s: String in crop_data.seasons:
				s_names.append(tr("SEASON_" + s.to_upper()))
			seasons_text = ", ".join(s_names)
		
		if is_in_season and in_season_first_id.is_empty():
			in_season_first_id = seed_id
		
		var buy_price: int = int(item_data.get("buy_price"))
		var item_btn: Button = Button.new()
		item_btn.custom_minimum_size = Vector2(360, 36)
		item_btn.toggle_mode = true
		item_btn.button_pressed = (seed_id == _selected_item_id)
		
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
		var base_name: String = tr(String(item_data.get("display_name_key")))
		if is_in_season:
			name_lbl.text = base_name
		else:
			name_lbl.text = "%s %s" % [base_name, tr("UI_SEASON_NOTE") % seasons_text]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(name_lbl)
		
		var price_lbl: Label = Label.new()
		price_lbl.text = tr("UI_BUY_PRICE") % buy_price
		price_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(price_lbl)
		
		if is_in_season:
			item_btn.pressed.connect(func() -> void: _select_item(seed_id))
		else:
			item_btn.disabled = true
			item_btn.modulate = Color(1, 1, 1, 0.45)
		
		_list_container.add_child(item_btn)
	
	if _selected_item_id.is_empty() or not _is_item_in_season(_selected_item_id):
		_selected_item_id = in_season_first_id
		_selected_quantity = 1
	
	_detail_box.visible = not _selected_item_id.is_empty()
	_update_detail()

func _is_item_in_season(item_id: StringName) -> bool:
	var crop_data: Resource = DataRegistry.get_crop_for_seed(item_id)
	if crop_data == null or crop_data.seasons.is_empty():
		return true
	return crop_data.seasons.has(String(GameClock.season))

func _select_item(item_id: StringName) -> void:
	_selected_item_id = item_id
	_selected_quantity = 1
	_render()

func _change_quantity(delta: int) -> void:
	if _selected_item_id.is_empty():
		return
	var item_data: Resource = DataRegistry.get_item(_selected_item_id)
	if item_data == null:
		return
	var unit_price: int = maxi(1, int(item_data.get("buy_price")))
	var max_affordable: int = 99
	if _wallet != null:
		max_affordable = maxi(1, floori(float(_wallet.get_coins()) / float(unit_price)))
	_selected_quantity = clampi(_selected_quantity + delta, 1, max_affordable)
	_update_detail()

func _set_max_quantity() -> void:
	if _selected_item_id.is_empty():
		return
	var item_data: Resource = DataRegistry.get_item(_selected_item_id)
	if item_data == null:
		return
	var unit_price: int = maxi(1, int(item_data.get("buy_price")))
	var max_affordable: int = 1
	if _wallet != null:
		max_affordable = maxi(1, floori(float(_wallet.get_coins()) / float(unit_price)))
	_selected_quantity = max_affordable
	_update_detail()

func _update_detail() -> void:
	if _selected_item_id.is_empty():
		_detail_box.visible = false
		return
	var item_data: Resource = DataRegistry.get_item(_selected_item_id)
	if item_data == null:
		_detail_box.visible = false
		return
	var unit_price: int = int(item_data.get("buy_price"))
	var total_price: int = unit_price * _selected_quantity
	_qty_label.text = str(_selected_quantity)
	_total_label.text = tr("UI_TOTAL_PRICE") % total_price
	
	var can_afford: bool = (_wallet != null and _wallet.can_afford(total_price))
	var can_store: bool = (_inventory != null and _inventory.can_add_item(_selected_item_id, _selected_quantity))
	_confirm_button.disabled = not (can_afford and can_store)

func _confirm_purchase() -> void:
	if _selected_item_id.is_empty() or _selected_quantity <= 0:
		return
	try_buy_item(_selected_item_id, _selected_quantity)
	_update_detail()

func try_buy_item(item_id: StringName, quantity: int) -> bool:
	if item_id.is_empty() or quantity <= 0:
		return false
	var item_data: Resource = DataRegistry.get_item(item_id)
	if item_data == null:
		return false
	var unit_price: int = int(item_data.get("buy_price"))
	var total_price: int = unit_price * quantity
	
	if _wallet == null or not _wallet.can_afford(total_price):
		if _feedback != null:
			_feedback.call("show_message", tr("UI_FEEDBACK_NOT_ENOUGH_COINS"))
		return false
	
	if _inventory == null or not _inventory.can_add_item(item_id, quantity):
		if _feedback != null:
			_feedback.call("show_message", tr("UI_FEEDBACK_INVENTORY_FULL"))
		return false
	
	# Atomic transaction:
	if _wallet.remove_coins(total_price, &"buy_seed"):
		var added: int = _inventory.add_item(item_id, quantity)
		if added < quantity:
			# Rollback coins if somehow partial add occurred
			var refund: int = (quantity - added) * unit_price
			_wallet.add_coins(refund, &"refund")
		item_purchased.emit(item_id, quantity, total_price)
		Events.item_purchased.emit(item_id, quantity, total_price)
		if _feedback != null:
			_feedback.call("show_message", tr("UI_FEEDBACK_BOUGHT") % [tr(String(item_data.get("display_name_key"))), quantity, total_price])
		_render()
		return true
	return false
