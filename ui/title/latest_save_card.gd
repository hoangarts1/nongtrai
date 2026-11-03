## LifeLatestSaveCard — read-only presentation of the selected saved payload.
class_name LifeLatestSaveCard
extends PanelContainer

var heading: Label
var farm: Label
var player: Label
var day: Label
var coins: Label
var _payload: Dictionary = {}
var _names: ScrollContainer
var _stats: HBoxContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeCompactPanel")
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left","top","right","bottom"]:
		margin.add_theme_constant_override("margin_"+side,12)
	add_child(margin)
	var column: VBoxContainer = LifeHudParts.column(margin)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading = LifeTitleParts.label(column,&"TITLE_LATEST_SAVE",&"LifeText16")
	_names = ScrollContainer.new()
	_names.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_names.custom_minimum_size.y = 78
	column.add_child(_names)
	var names_column: VBoxContainer = LifeHudParts.column(_names)
	names_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	farm = LifeTitleParts.label(names_column,&"",&"LifeText24")
	player = LifeTitleParts.label(names_column,&"")
	_stats = HBoxContainer.new()
	column.add_child(_stats)
	day = LifeTitleParts.label(_stats,&"",&"LifeDayHeading")
	coins = LifeTitleParts.label(_stats,&"",&"LifeDayHeading")
	coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	display({})

func display(payload: Dictionary) -> void:
	_payload = payload.duplicate(true)
	var profile: Dictionary = LifeTitleParts.dictionary(payload.get("profile",{}))
	var clock: Dictionary = LifeTitleParts.dictionary(payload.get("clock",{}))
	var wallet: Dictionary = LifeTitleParts.dictionary(payload.get("wallet",{}))
	heading.text = tr("TITLE_NO_SAVE") if payload.is_empty() else tr("TITLE_LATEST_SAVE")
	farm.text = LifeTitleParts.text(profile,&"farm_name")
	player.text = LifeTitleParts.text(profile,&"player_name")
	farm.visible = not farm.text.is_empty()
	player.visible = not player.text.is_empty()
	var saved_day: int = LifeTitleParts.nonnegative_number(clock.get("day_index",null))
	var saved_coins: int = LifeTitleParts.nonnegative_number(wallet.get("coins",null))
	day.visible = saved_day >= 0
	coins.visible = saved_coins >= 0
	_names.visible = farm.visible or player.visible
	_stats.visible = day.visible or coins.visible
	day.text = tr("TITLE_SAVE_DAY") % (saved_day+1) if day.visible else ""
	coins.text = tr("UI_WALLET_COINS") % saved_coins if coins.visible else ""

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and coins != null:
		display(_payload)
