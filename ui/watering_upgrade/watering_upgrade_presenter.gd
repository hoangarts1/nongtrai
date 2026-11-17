## LifeWateringUpgradePresenter - localized shared-theme presentation only.
class_name LifeWateringUpgradePresenter
extends RefCounted

const REASONS: Dictionary = {
	&"available":&"WATER_UP_AVAILABLE", &"upgraded":&"WATER_UP_SUCCESS",
	&"already_upgraded":&"WATER_UP_COMPLETE", &"insufficient_coins":&"WATER_UP_NO_COINS",
	&"stale_capacity":&"WATER_UP_STALE", &"purchase_busy":&"WATER_UP_BUSY",
	&"grant_rejected":&"WATER_UP_REFUND"
}

static func reason(code: StringName) -> String:
	return TranslationServer.translate(REASONS.get(code,&"WATER_UP_INVALID"))

static func render(panel: LifeWateringUpgradeScreen, model: Dictionary, result: Dictionary) -> void:
	panel.banner.set_caption(&"WATER_UP_TITLE")
	panel.close_button.text = TranslationServer.translate(&"UI_CLOSE")
	panel.summary.display(model)
	panel.footer.display(model,result)
	panel.expected_capacity = int(model.capacity)
