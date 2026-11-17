## LifeChickenCoopSummary — actual daily herd/output and gentle care guidance.
class_name LifeChickenCoopSummary
extends VBoxContainer
var title: Label
var detail: Label
var counts: Label
var stock: Label
var hint: Label

func _ready() -> void:
	theme_type_variation = &"LifeInvColumn"
	var paper: VBoxContainer = LifePauseParts.paper(self)
	title = LifePauseParts.label(paper,&"",&"LifeInvTitle")
	detail = LifePauseParts.label(paper,&"",&"LifeSecondaryText")
	counts = LifePauseParts.label(paper,&"",&"LifeInvTitle")
	stock = LifePauseParts.label(paper,&"",&"LifeSecondaryText")
	hint = LifePauseParts.label(self,&"COOP_CARE",&"LifeSecondaryText")

func display(model: Dictionary) -> void:
	title.text = tr("COOP_OWNED" if bool(model.owned) else "COOP_SITE")
	detail.text = tr("COOP_DAY") % int(model.day)
	counts.text = tr("COOP_COUNTS") % [int(model.hens),int(model.fed),int(model.eggs)]
	stock.text = tr("COOP_STOCK") % [int(model.food),int(model.coins)]
	hint.text = tr("COOP_CARE") if bool(model.owned) else tr("COOP_BUNDLE") % [int(model.initial_hens),int(model.price)]
