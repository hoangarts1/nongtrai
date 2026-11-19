## LifeHudPresenter — binds existing state to the read-only HUD views.
class_name LifeHudPresenter
extends Node

var root: LifeHudRoot
var _main: Node
var _water_queued: bool = false

func configure(main: Node) -> void:
	_main = main
	root = preload("res://ui/hud/hud_root.tscn").instantiate() as LifeHudRoot
	root.name = "HudRoot"
	main.add_child(root)
	GameClock.time_changed.connect(_clock_changed)
	Events.weather_changed.connect(_weather_changed)
	Events.forecast_updated.connect(_forecast_changed)
	main.wallet.coins_changed.connect(_coins_changed)
	main.quest_state.step_changed.connect(_quest_changed)
	main.feedback.message_shown.connect(show_message)
	main.watering_runtime.water_changed.connect(_water_changed)
	main.director_state.director_changed.connect(_queue_water_detail)
	main.director_activity.activity_changed.connect(_queue_water_detail)
	main.ecology_state.ecology_changed.connect(_queue_water_detail)
	main.weather_state.weather_changed.connect(_queue_water_detail)
	_refresh_clock()
	_water_changed(main.watering_can.get_charges(),main.watering_can.get_capacity())
	root.coins.set_coins(main.wallet.get_coins())

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and root != null:
		_refresh_clock()
		_queue_water_detail()

func show_message(message: String, icon_id: StringName = &"journal") -> void:
	root.toasts.show_message(message,icon_id)

func sync(modal: bool, title: bool) -> void:
	root.right_column.visible = not title
	root.toasts.visible = not title
	for control: Control in [_main.get_node("ClockHud"),_main.weather_hud,_main.wallet_hud,_main.toast]:
		control.hide()
	if modal and _main.ui_coordinator.get_active_panel() not in [_main.seed_shop_panel,_main.shipping_bin_panel,_main.npc_system.dialogue]:
		root.toasts.hide()

func _refresh_clock() -> void:
	var forecast: Array = _main.weather_state.get("forecast")
	var next: String = tr("WEATHER_"+String(forecast[0]).to_upper()) if not forecast.is_empty() else ""
	var weather: StringName = StringName(_main.weather_state.get("today"))
	var summary: String = tr("HUD_WEATHER") % [tr("WEATHER_"+String(weather).to_upper()),next]
	var season: Resource = DataRegistry.get_season(GameClock.season)
	root.clock_card.display(GameClock.day_index,GameClock.get_day_in_season(),GameClock.year,tr(String(season.get("display_name_key"))),GameClock.minute,weather,summary)

func _clock_changed(_day: int, _minute: int) -> void:
	_refresh_clock()

func _weather_changed(_weather: StringName) -> void:
	_refresh_clock()

func _forecast_changed(_forecast: Array[StringName]) -> void:
	_refresh_clock()

func _coins_changed(total: int, _delta: int, _reason: StringName) -> void:
	root.coins.set_coins(total)

func _quest_changed(index: int, completed: bool) -> void:
	if completed:
		show_message(tr("HUD_QUEST_DONE") % tr(String(_main.quest_panel.STEP_KEYS[index])),&"journal")

func _water_changed(charges: int, capacity: int) -> void:
	_main.hotbar_panel.toolbar.water_meter.display(charges,capacity)
	_queue_water_detail()

func _queue_water_detail(_value: Variant = null) -> void:
	if not _water_queued:
		_water_queued = true
		call_deferred("_refresh_water_detail")

func _refresh_water_detail() -> void:
	_water_queued = false
	_main.hotbar_panel.toolbar.water_meter.set_cost_detail(LifeDirectorPresenter.water_text(LifeDirectorSnapshot.capture(_main)))
