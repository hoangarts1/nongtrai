## LifeDayEndPresenter — localized snapshot formatting, no state mutation.
class_name LifeDayEndPresenter
extends RefCounted

const REASON_KEYS: Dictionary = {
	"sell_produce":&"END_SALE","buy_seed":&"END_BUY_SEED","refund":&"END_REFUND",
	"minh_discount":&"END_MERCHANT_BUY","minh_rollback":&"END_REFUND","minh_request":&"END_MERCHANT_SALE"
}

static func render(panel: LifeDayEndSheet, ledger: DayLedgerState, main: Node, forced: bool) -> void:
	panel.title.text = TranslationServer.translate(&"END_TITLE") % (GameClock.day_index+1)
	var rows: Array[Dictionary] = []
	for entry: Dictionary in ledger.rows():
		var amount: int = int(entry["amount"])
		var key: StringName = REASON_KEYS.get(entry["reason"],&"END_OTHER_IN" if amount > 0 else &"END_OTHER_OUT")
		var title: String = TranslationServer.translate(key)
		var icon: Texture2D = UiIcons.get_icon(&"coin")
		var item: Resource = DataRegistry.get_item(StringName(entry["item_id"])) if not String(entry["item_id"]).is_empty() else null
		if item != null:
			title = TranslationServer.translate(StringName(item.get("display_name_key")))
			icon = UiIcons.for_item(StringName(entry["item_id"]))
		rows.append({"title":title,"quantity":int(entry["quantity"]),"amount":amount,"icon":icon})
	panel.ledger_view.display(rows,ledger.totals(),ledger.complete)
	var forecast: Array = main.weather_state.get("forecast")
	var weather: StringName = StringName(forecast[0]) if not forecast.is_empty() else &""
	var days: int = int(DataRegistry.get_season(GameClock.season).get("days_in_season"))
	var date: String = TranslationServer.translate(&"END_TOMORROW") % [TranslationServer.translate(StringName("HUD_WEEKDAY_%d" % posmod(GameClock.day_index+1,7))),posmod(GameClock.get_day_in_season(),days)+1]
	var completed: int = 0
	for index: int in range(main.quest_panel.STEP_KEYS.size()):
		if main.quest_state.is_step_completed(index):
			completed += 1
	panel.tomorrow.display(date,TranslationServer.translate(StringName("WEATHER_"+String(weather).to_upper())) if not weather.is_empty() else TranslationServer.translate(&"END_FORECAST_UNKNOWN"),weather,completed,main.quest_panel.STEP_KEYS.size())
	var unwatered: int = 0
	for plot: Dictionary in main.farm_state.serialize()["plots"]:
		if not String(plot.get("crop_id","")).is_empty() and not bool(plot.get("watered",false)) and not bool(plot.get("withered",false)):
			unwatered += 1
	panel.warning.display(unwatered,forced)
	panel.set_forced(forced)
