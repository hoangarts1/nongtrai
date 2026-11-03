## FeedbackPopup — compatible text adapter into the shared two-message toast stack.
## API:
##   func configure(inventory: InventoryState) -> void
##   func show_message(message: String) -> void
extends Label

signal message_shown(message: String, icon_id: StringName)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()

func configure(_inventory: InventoryState) -> void:
	if not Events.item_added.is_connected(_on_item_added):
		Events.item_added.connect(_on_item_added)

func show_message(message: String) -> void:
	text = message
	message_shown.emit(message,&"journal")
	hide()

func _on_item_added(item_id: StringName, quantity: int) -> void:
	var item_data: Resource = DataRegistry.get_item(item_id)
	if item_data == null:
		return
	text = tr("HUD_ITEM_GAINED") % [quantity,tr(String(item_data.get("display_name_key")))]
	message_shown.emit(text,&"seed")
	hide()
