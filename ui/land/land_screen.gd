## LifeLandScreen ? lazy wood/paper composition; UiCoordinator owns the modal.
class_name LifeLandScreen
extends LifeHudFrame

signal closed()
signal purchased(parcel_id: StringName)
var banner: LifeBanner
var close_button: Button
var summary: LifeLandSummary
var footer: LifeLandFooter
var expected_id: StringName = &""

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
	banner.tone = &"red"
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(banner)
	close_button = LifePauseParts.button(header,&"UI_CLOSE",&"LifeDanger")
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(func() -> void: closed.emit())
	summary = preload("res://ui/land/land_summary.tscn").instantiate() as LifeLandSummary
	summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(summary)
	footer = preload("res://ui/land/land_footer.tscn").instantiate() as LifeLandFooter
	column.add_child(footer)
	footer.confirmed.connect(func() -> void: purchased.emit(expected_id))
	footer.cancelled.connect(func() -> void: closed.emit())
