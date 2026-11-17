## LifeBagUpgradePresenter - localized shared-theme presentation only.
class_name LifeBagUpgradePresenter
extends RefCounted

const REASONS: Dictionary = {
	&"available":&"BAG_UP_AVAILABLE", &"upgraded":&"BAG_UP_SUCCESS",
	&"already_upgraded":&"BAG_UP_COMPLETE", &"insufficient_coins":&"BAG_UP_NO_COINS",
	&"stale_capacity":&"BAG_UP_STALE", &"purchase_busy":&"BAG_UP_BUSY",
	&"grant_rejected":&"BAG_UP_REFUND"
}

static func reason(code: StringName) -> String:
	return TranslationServer.translate(REASONS.get(code,&"BAG_UP_INVALID"))

static func render(panel: LifeBagUpgradeScreen, model: Dictionary, result: Dictionary) -> void:
	panel.banner.set_caption(&"BAG_UP_TITLE")
	panel.close_button.text = TranslationServer.translate(&"UI_CLOSE")
	panel.summary.display(model)
	panel.footer.display(model,result)
	panel.expected_capacity = int(model.capacity)
