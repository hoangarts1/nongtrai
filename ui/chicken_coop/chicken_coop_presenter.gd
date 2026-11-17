## LifeChickenCoopPresenter — localization and rendering, never commands owners.
class_name LifeChickenCoopPresenter
extends RefCounted
static func render(panel: LifeChickenCoopScreen, model: Dictionary, result: Dictionary) -> void:
	panel.banner.set_caption(&"COOP_TITLE")
	panel.close_button.text = TranslationServer.translate(&"UI_CLOSE")
	panel.summary.display(model)
	panel.controls.display(model,result)

static func reason(value: StringName) -> String:
	var keys: Dictionary = {&"ready":&"COOP_READY",&"purchased":&"COOP_PURCHASED",&"fed":&"COOP_FED",&"collected":&"COOP_COLLECTED",&"insufficient_coins":&"COOP_NO_COINS",&"inventory_full":&"COOP_FULL",&"missing_feed":&"COOP_NO_FEED",&"occupied":&"COOP_OCCUPIED",&"already_owned":&"COOP_OWNED",&"not_owned":&"COOP_SITE",&"stale_quantity":&"COOP_CHANGED"}
	return TranslationServer.translate(keys.get(value,&"COOP_CHANGED"))
