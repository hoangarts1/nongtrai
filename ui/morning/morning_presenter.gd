## MorningPresenter — localized rendering from a read-only morning snapshot.
class_name MorningPresenter
extends RefCounted

static func render(panel: LifeMorningSheet, snapshot: Dictionary) -> void:
	panel.title.text = TranslationServer.translate(&"NEWS_TITLE")
	var season: Resource = DataRegistry.get_season(StringName(snapshot.season))
	var season_text: String = TranslationServer.translate(StringName(season.get("display_name_key"))) if season != null else ""
	panel.date.text = TranslationServer.translate(&"NEWS_DATE") % [
		TranslationServer.translate(StringName("HUD_WEEKDAY_%d" % posmod(int(snapshot.day),7))),
		int(snapshot.day_in_season),season_text,int(snapshot.year)]
	var forecast: Array[StringName] = []
	forecast.assign(snapshot.forecast)
	panel.weather.display(StringName(snapshot.weather),forecast,int(snapshot.day))
	panel.garden.display(snapshot)
	var prices: Array[Dictionary] = []
	prices.assign(snapshot.prices)
	panel.market.display(prices)
	panel.ecology.display(snapshot.get("ecology", {"ok": false}))
	panel.tasks.display(int(snapshot.ready),int(snapshot.water),int(snapshot.empty))
	panel.begin_button.text = TranslationServer.translate(&"NEWS_BEGIN")
