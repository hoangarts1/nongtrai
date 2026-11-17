## LifeWateringUpgradeSummary - actual before/after capacity and price.
class_name LifeWateringUpgradeSummary
extends VBoxContainer

var capacity: Label
var remaining: Label
var description: Label
var price: Label
var availability: Label

func _ready() -> void:
	theme_type_variation = &"LifeInvColumn"
	var card: VBoxContainer = LifePauseParts.paper(self)
	capacity = LifePauseParts.label(card,&"",&"LifeInvTitle")
	remaining = LifePauseParts.label(card,&"",&"LifeInvTitle")
	description = LifePauseParts.label(card,&"WATER_UP_DESCRIPTION")
	price = LifePauseParts.label(card,&"",&"LifeInvTitle")
	availability = LifePauseParts.label(self,&"",&"LifeSecondaryText")

func display(model: Dictionary) -> void:
	capacity.text = tr("WATER_UP_CAPACITY") % [int(model.capacity),int(model.target)]
	remaining.text = tr("WATER_UP_REMAINING") % int(model.charges)
	description.text = tr("WATER_UP_DESCRIPTION")
	price.text = tr("WATER_UP_PRICE") % int(model.price)
	price.visible = model.reason!=&"already_upgraded"
	availability.text = LifeWateringUpgradePresenter.reason(StringName(model.reason))
