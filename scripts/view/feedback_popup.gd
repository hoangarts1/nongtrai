## FeedbackPopup — short player-facing feedback for domain results.
## API:
##   func show_message(message: String) -> void
extends Label

var _tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func configure(inventory: InventoryState) -> void:
	if not Events.item_added.is_connected(_on_item_added):
		Events.item_added.connect(_on_item_added)

func show_message(message: String) -> void:
	text = message
	visible = true
	modulate.a = 1.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "position:y", position.y - 24.0, 0.55)
	_tween.tween_property(self, "modulate:a", 0.0, 0.55)
	_tween.finished.connect(func() -> void:
		visible = false
		position.y += 24.0
	)

func _on_item_added(item_id: StringName, quantity: int) -> void:
	var item_data: Resource = DataRegistry.get_item(item_id)
	if item_data == null:
		return
	show_message("+%d %s" % [quantity, tr(String(item_data.get("display_name_key")))])
