## LifeChickenCoopScreen — lazy composition of three small themed scenes.
class_name LifeChickenCoopScreen
extends LifeHudFrame
signal closed()
signal backed()
signal commanded(action: StringName, quantity: int)
var banner: LifeBanner
var close_button: Button
var summary: LifeChickenCoopSummary
var controls: LifeChickenCoopControls

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
	column.add_child(header)
	banner = preload("res://ui/components/banner.tscn").instantiate() as LifeBanner
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(banner)
	banner.set_caption(&"COOP_TITLE")
	close_button = LifePauseParts.button(header,&"UI_CLOSE",&"LifeDanger")
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_button.custom_minimum_size.x = 110
	close_button.pressed.connect(func() -> void: closed.emit())
	summary = preload("res://ui/chicken_coop/chicken_coop_summary.tscn").instantiate() as LifeChickenCoopSummary
	summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(summary)
	controls = preload("res://ui/chicken_coop/chicken_coop_controls.tscn").instantiate() as LifeChickenCoopControls
	column.add_child(controls)
	controls.commanded.connect(func(action: StringName, quantity: int) -> void: commanded.emit(action,quantity))
	controls.backed.connect(func() -> void: backed.emit())
