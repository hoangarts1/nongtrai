## LifeMachineCard — native selectable catalogue row; display only.
class_name LifeMachineCard
extends Button

var caption: Label
var image: TextureRect

func _ready() -> void:
	custom_minimum_size.y = 84
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var inset: MarginContainer = MarginContainer.new()
	inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inset.add_theme_constant_override("margin_left",12)
	inset.add_theme_constant_override("margin_right",12)
	inset.add_theme_constant_override("margin_top",8)
	inset.add_theme_constant_override("margin_bottom",8)
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(inset)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.add_child(row)
	image = LifeHudParts.texture(row,null,52)
	caption = LifeMachinePresenter.label(row)

func display(data: Dictionary, selected: bool) -> void:
	theme_type_variation = &"LifeInvSlotSelected" if selected else &"LifeInvFilter"
	set_meta(&"machine_action",String(data.key))
	if data.kind==&"recipe":
		caption.text = "%s\n%s" % [LifeMachinePresenter.entries(data.outputs),tr("MUI_DAYS") % int(data.days)]
		var item: ItemData = DataRegistry.get_item(StringName(data.outputs[0].item_id)) as ItemData
		image.texture = UiIcons.for_item(item.item_id)
	else:
		var machine: MachineData = DataRegistry.get_machine(StringName(data.id))
		image.texture = LifeMachinePresenter.art(machine,false)
		caption.text = tr(String(data.name))+"\n"
		if data.kind==&"placement":
			caption.text += tr("MUI_PLACEMENT") % data.cell
		else:
			caption.text += tr("MUI_CARD") % [int(data.price),int(data.level),int(data.owned)]
	tooltip_text = caption.text
