## LifeItemSlot — read-only item view; requests are signals, never inventory mutations.
class_name LifeItemSlot
extends Button

signal slot_requested(item_id: StringName)
enum SlotState { EMPTY, FILLED, SELECTED, LOCKED }
var item_id: StringName = &""
var quantity: int = 0
var state: SlotState = SlotState.EMPTY
var _name_key: StringName = &"UI_KIT_ITEM"
var _icon_texture: Texture2D
var _icon: TextureRect
var _placeholder: LifeIconPlaceholder
var _quantity_label: Label
var _lock: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeItemSlot")
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_icon = TextureRect.new()
	_icon.name = "Icon"
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.custom_minimum_size = Vector2(32,32)
	center.add_child(_icon)
	_placeholder = LifeIconPlaceholder.new()
	center.add_child(_placeholder)
	_quantity_label = Label.new()
	_quantity_label.name = "Quantity"
	_quantity_label.theme_type_variation = &"LifeQuantity"
	_quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var quantity_inset: MarginContainer = MarginContainer.new()
	quantity_inset.name = "QuantityInset"
	quantity_inset.theme_type_variation = &"LifeSlotQuantityInset"
	quantity_inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quantity_inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(quantity_inset)
	quantity_inset.add_child(_quantity_label)
	_lock = Label.new()
	_lock.name = "Lock"
	_lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lock)
	pressed.connect(_request_slot)
	_refresh()

func set_item(id: StringName, count: int, name_key: StringName, texture: Texture2D = null) -> void:
	item_id = id
	quantity = maxi(0,count)
	_name_key = name_key
	_icon_texture = texture
	state = SlotState.FILLED if not item_id.is_empty() and quantity > 0 else SlotState.EMPTY
	_refresh()

func set_state(value: SlotState) -> void:
	state = value
	_refresh()

func _request_slot() -> void:
	if state != SlotState.LOCKED:
		slot_requested.emit(item_id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if _icon == null:
		return
	theme_type_variation = &"LifeItemSlotSelected" if state==SlotState.SELECTED else (&"LifeItemSlotLocked" if state==SlotState.LOCKED else &"LifeItemSlot")
	disabled = state==SlotState.LOCKED
	_icon.texture = _icon_texture
	_icon.visible = state in [SlotState.FILLED,SlotState.SELECTED] and _icon_texture != null
	_placeholder.visible = state in [SlotState.FILLED,SlotState.SELECTED] and _icon_texture == null
	_placeholder.text_key = _name_key
	_placeholder.queue_redraw()
	_quantity_label.text = str(quantity) if state in [SlotState.FILLED,SlotState.SELECTED] else ""
	_lock.text = tr("UI_KIT_LOCKED") if state == SlotState.LOCKED else ""
	tooltip_text = tr(String(_name_key)) if not item_id.is_empty() else tr("UI_KIT_EMPTY")
