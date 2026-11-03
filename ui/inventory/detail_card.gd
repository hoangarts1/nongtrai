## LifeInventoryDetail — actual metadata and supported requests; no fake item effects.
class_name LifeInventoryDetail
extends VBoxContainer

signal quick_selected()
signal discard_requested()
var name_label: Label
var category_label: Label
var count_label: Label
var description: Label
var price: Label
var image: TextureRect
var quick_button: Button
var discard_button: Button

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	var header: HBoxContainer = HBoxContainer.new()
	header.theme_type_variation = &"LifeInvRow"
	add_child(header)
	image = LifeHudParts.texture(header,null,80)
	var labels: VBoxContainer = LifeHudParts.column(header)
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label = LifeDayEndParts.wrapped(labels,&"LifeInvTitle")
	category_label = LifeDayEndParts.wrapped(labels,&"LifeSmall")
	count_label = LifeDayEndParts.wrapped(labels)
	var paper: PanelContainer = PanelContainer.new()
	paper.theme_type_variation = &"LifeInvInset"
	add_child(paper)
	description = LifeDayEndParts.wrapped(paper,&"LifeSecondaryText")
	price = LifeDayEndParts.wrapped(self)
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spacer)
	quick_button = Button.new()
	quick_button.theme_type_variation = &"LifeInvAction"
	quick_button.custom_minimum_size.y = 48
	quick_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quick_button.pressed.connect(func() -> void: quick_selected.emit())
	add_child(quick_button)
	discard_button = Button.new()
	discard_button.theme_type_variation = &"LifeDanger"
	discard_button.custom_minimum_size.y = 42
	discard_button.pressed.connect(func() -> void: discard_requested.emit())
	add_child(discard_button)

func display(slot: Dictionary) -> void:
	var present: bool = not slot.is_empty()
	quick_button.disabled = not present
	discard_button.disabled = not present
	quick_button.text = tr("INV_QUICK_SELECT")
	discard_button.text = tr("INV_DISCARD")
	name_label.text = tr("INV_SELECT_ITEM")
	category_label.text = ""
	count_label.text = ""
	description.text = tr("INV_EMPTY_DETAIL")
	price.text = ""
	image.texture = null
	if not present:
		return
	var item: ItemData = DataRegistry.get_item(slot["item_id"]) as ItemData
	name_label.text = tr(String(item.display_name_key))
	category_label.text = tr("INV_CATEGORY_"+String(item.category).to_upper())
	count_label.text = tr("INV_QUANTITY") % int(slot["quantity"])
	description.text = tr(String(item.description_key)) if not item.description_key.is_empty() else tr("INV_DESC_OTHER")
	price.text = tr("INV_SELL_PRICE") % LifeDayEndParts.money(item.sell_price)
	image.texture = LifeInventoryIcon.for_item(item.item_id)
