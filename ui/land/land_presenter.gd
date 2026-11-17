## LifeLandPresenter ? shared-theme localized land snapshots and command results.
class_name LifeLandPresenter
extends RefCounted

const REASONS: Dictionary = {
	&"available":&"LAND_AVAILABLE", &"purchased":&"LAND_PURCHASED",
	&"insufficient_coins":&"LAND_NO_COINS", &"no_available_parcel":&"LAND_COMPLETE",
	&"already_owned":&"LAND_COMPLETE", &"purchase_busy":&"LAND_BUSY",
	&"not_next_parcel":&"LAND_STALE", &"grant_rejected":&"LAND_REJECTED"
}

static func reason(code: StringName) -> String:
	return TranslationServer.translate(REASONS.get(code,&"LAND_INVALID"))

static func render(panel: LifeLandScreen, model: Dictionary, result: Dictionary) -> void:
	panel.banner.set_caption(&"LAND_TITLE")
	panel.close_button.text = TranslationServer.translate(&"UI_CLOSE")
	panel.summary.display(model)
	panel.footer.display(model,result)
	panel.expected_id = StringName(model.id)
