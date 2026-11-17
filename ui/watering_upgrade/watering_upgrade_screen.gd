## LifeWateringUpgradeScreen - lazy composition of small shared-theme views.
class_name LifeWateringUpgradeScreen
extends LifeHudFrame

signal closed()
signal backed()
signal purchased(expected_capacity: int)
var banner: LifeBanner
var close_button: Button
var summary: LifeWateringUpgradeSummary
var footer: LifeWateringUpgradeFooter
var expected_capacity: int = -1

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

func ensure_built() -> void:
	if summary!=null:
		return
	LifeTheme.bind(self,&"LifeHudWood")
	var column: VBoxContainer = LifePauseParts.paper(self)
	column.theme_type_variation = &"LifeInvColumn"
	var header: HBoxContainer = HBoxContainer.new()
	header.theme_type_variation = &"LifeHudRow"
	column.add_child(header)
	banner = preload("res://ui/components/banner.tscn").instantiate() as LifeBanner
	banner.tone = &"blue"
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(banner)
	close_button = LifePauseParts.button(header,&"UI_CLOSE",&"LifeDanger")
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(func() -> void: closed.emit())
	summary = preload("res://ui/watering_upgrade/watering_upgrade_summary.tscn").instantiate() as LifeWateringUpgradeSummary
	summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(summary)
	footer = preload("res://ui/watering_upgrade/watering_upgrade_footer.tscn").instantiate() as LifeWateringUpgradeFooter
	column.add_child(footer)
	footer.confirmed.connect(func() -> void: purchased.emit(expected_capacity))
	footer.backed.connect(func() -> void: backed.emit())
