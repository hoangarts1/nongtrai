## LifeDayEndSheet — reference 13 composition; native controls emit requests only.
class_name LifeDayEndSheet
extends LifeHudFrame

signal confirmed()
signal cancelled()
var title: Label
var ledger_view: LifeDayLedgerView
var tomorrow: LifeDayTomorrowCard
var warning: LifeDayFarmWarning
var continue_button: Button
var stay_button: Button
var columns: HBoxContainer

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	var paper: PanelContainer = PanelContainer.new()
	paper.theme_type_variation = &"LifeHudPaper"
	add_child(paper)
	var outer: VBoxContainer = LifeHudParts.column(paper)
	var banner: PanelContainer = PanelContainer.new()
	banner.theme_type_variation = &"LifeBannerBlue"
	outer.add_child(banner)
	title = LifeHudParts.label(banner,&"LifeDayTitle")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columns = HBoxContainer.new()
	columns.theme_type_variation = &"LifeDayColumns"
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(columns)
	var left: VBoxContainer = LifeHudParts.column(columns)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ledger_view = preload("res://ui/day_end/ledger_view.tscn").instantiate() as LifeDayLedgerView
	ledger_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(ledger_view)
	warning = preload("res://ui/day_end/farm_warning.tscn").instantiate() as LifeDayFarmWarning
	left.add_child(warning)
	var right: VBoxContainer = LifeHudParts.column(columns)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tomorrow = preload("res://ui/day_end/tomorrow_card.tscn").instantiate() as LifeDayTomorrowCard
	right.add_child(tomorrow)
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.add_child(spacer)
	continue_button = Button.new()
	continue_button.theme_type_variation = &"LifePrimary"
	continue_button.text = tr("END_NEXT_DAY")
	continue_button.custom_minimum_size.y = 60
	continue_button.pressed.connect(func() -> void: confirmed.emit())
	right.add_child(continue_button)
	stay_button = Button.new()
	stay_button.theme_type_variation = &"LifeSecondary"
	stay_button.text = tr("END_STAY")
	stay_button.custom_minimum_size.y = 44
	stay_button.pressed.connect(func() -> void: cancelled.emit())
	right.add_child(stay_button)

func set_forced(forced: bool) -> void:
	stay_button.visible = not forced
	continue_button.disabled = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and continue_button != null:
		continue_button.text = tr("END_NEXT_DAY")
		stay_button.text = tr("END_STAY")
