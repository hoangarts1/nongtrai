## LifeMachineScreen — reference10 wood/paper composition of small components.
class_name LifeMachineScreen
extends LifeHudFrame

signal closed()
signal selected(id: StringName)
signal requested(action: StringName)
var banner: LifeBanner
var land_button: Button
var close_button: Button
var details: LifeMachineDetails
var catalog: LifeMachineCatalog
var footer: LifeMachineFooter
var tabs: Array[Button] = []
var body: HBoxContainer
var header: LifeMachineHeader

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	column.theme_type_variation = &"LifeInvColumn"
	header = preload("res://ui/machine/machine_header.tscn").instantiate() as LifeMachineHeader
	column.add_child(header)
	banner = header.banner
	land_button = header.land_button
	close_button = header.close_button
	header.land_requested.connect(func() -> void: requested.emit(&"land"))
	header.closed.connect(func() -> void: closed.emit())
	body = HBoxContainer.new()
	body.theme_type_variation = &"LifeInvColumns"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	details = preload("res://ui/machine/machine_details.tscn").instantiate() as LifeMachineDetails
	details.size_flags_stretch_ratio = 0.9
	body.add_child(details)
	var right: VBoxContainer = LifeHudParts.column(body)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.7
	var modes: HBoxContainer = HBoxContainer.new()
	modes.theme_type_variation = &"LifeHudRow"
	right.add_child(modes)
	for key: StringName in [&"UI_BUY",&"MUI_SELL",&"MUI_BUYBACK"]:
		var tab: Button = LifeMachinePresenter.button(modes,key,"tab:"+String(key),&"LifePrimary" if tabs.is_empty() else &"LifeSecondary")
		tab.disabled = not tabs.is_empty()
		tabs.append(tab)
	catalog = preload("res://ui/machine/machine_catalog.tscn").instantiate() as LifeMachineCatalog
	right.add_child(catalog)
	catalog.selected.connect(func(id: StringName) -> void: selected.emit(id))
	footer = preload("res://ui/machine/machine_footer.tscn").instantiate() as LifeMachineFooter
	column.add_child(footer)
	footer.requested.connect(func(action: StringName) -> void: requested.emit(action))

func display(model: Dictionary, feedback: Dictionary) -> void:
	header.display(bool(model.operation))
	tabs[0].text = tr("MUI_RECIPES" if bool(model.operation) else "UI_BUY")
	tabs[1].text = tr("MUI_SELL")
	tabs[2].text = tr("MUI_BUYBACK")
	for index: int in range(tabs.size()):
		tabs[index].tooltip_text = tabs[index].text if index==0 else tr("MUI_UNAVAILABLE")
	details.display(model,bool(model.operation))
	var rows: Array[Dictionary] = []
	rows.assign(model.rows)
	catalog.display(rows,StringName(model.recipe.id) if bool(model.operation) else StringName(model.id),bool(model.operation))
	footer.display(model,feedback)
