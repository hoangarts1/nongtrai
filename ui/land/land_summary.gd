## LifeLandSummary ? owned area and the actual next parcel, no game state.
class_name LifeLandSummary
extends VBoxContainer

var owned: Label
var name_label: Label
var description: Label
var extra: Label
var price: Label
var availability: Label

func _ready() -> void:
	theme_type_variation = &"LifeInvColumn"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	owned = LifePauseParts.label(self,&"",&"LifeInvTitle")
	var card: VBoxContainer = LifePauseParts.paper(self)
	name_label = LifePauseParts.label(card,&"",&"LifeInvTitle")
	description = LifePauseParts.label(card,&"LAND_DESCRIPTION")
	extra = LifePauseParts.label(card,&"")
	price = LifePauseParts.label(card,&"",&"LifeInvTitle")
	availability = LifePauseParts.label(self,&"",&"LifeSecondaryText")

func display(model: Dictionary) -> void:
	owned.text = tr("LAND_OWNED") % int(model.owned)
	name_label.text = tr(String(model.name))
	description.text = tr("LAND_DESCRIPTION")
	description.visible = not StringName(model.id).is_empty()
	extra.text = tr("LAND_EXTRA") % int(model.extra)
	extra.visible = description.visible
	price.text = tr("LAND_PRICE") % int(model.price)
	price.visible = description.visible
	availability.text = LifeLandPresenter.reason(StringName(model.reason))
	availability.visible = not StringName(model.id).is_empty()
