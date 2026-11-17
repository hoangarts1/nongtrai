## LifeBagUpgradeSummary - actual before/after capacity and price.
class_name LifeBagUpgradeSummary
extends VBoxContainer

var capacity: Label
var description: Label
var price: Label
var availability: Label

func _ready() -> void:
	theme_type_variation = &"LifeInvColumn"
	var card: VBoxContainer = LifePauseParts.paper(self)
	capacity = LifePauseParts.label(card,&"",&"LifeInvTitle")
	description = LifePauseParts.label(card,&"BAG_UP_DESCRIPTION")
	price = LifePauseParts.label(card,&"",&"LifeInvTitle")
	availability = LifePauseParts.label(self,&"",&"LifeSecondaryText")

func display(model: Dictionary) -> void:
	capacity.text = tr("BAG_UP_CAPACITY") % [int(model.capacity),int(model.target)]
	description.text = tr("BAG_UP_DESCRIPTION")
	price.text = tr("BAG_UP_PRICE") % int(model.price)
	price.visible = model.reason!=&"already_upgraded"
	availability.text = LifeBagUpgradePresenter.reason(StringName(model.reason))
