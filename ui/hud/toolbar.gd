## LifeHudToolbar — eight slots; only emits requests to its adapter.
class_name LifeHudToolbar
extends VBoxContainer

signal tool_requested(tool_id: StringName)
signal item_requested(slot_index: int)
const TOOLS: Array[StringName] = [&"hoe",&"shovel",&"watering_can",&"harvest"]
const TOOL_KEYS: Array[StringName] = [&"UI_TOOL_HOE",&"UI_TOOL_SHOVEL",&"UI_TOOL_WATER",&"UI_TOOL_HARVEST"]
var buttons: Array[LifeHudToolbarSlot] = []
var caption: Label
var water_meter: LifeHudWaterMeter
var _window_start: int = 0
var _slots: Array[Dictionary] = []
var active_index: int = 0

func _ready() -> void:
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var status_row: HBoxContainer = HBoxContainer.new()
	status_row.name = "StatusRow"
	status_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(status_row)
	var caption_panel: PanelContainer = PanelContainer.new()
	caption_panel.name = "CaptionPanel"
	caption_panel.theme_type_variation = &"LifeHudCaption"
	caption_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	status_row.add_child(caption_panel)
	caption = LifeHudParts.label(caption_panel,&"LifeHudCaptionText")
	water_meter = LifeHudWaterMeter.new()
	water_meter.name = "WaterMeter"
	status_row.add_child(water_meter)
	var frame: LifeHudFrame = LifeHudFrame.new()
	add_child(frame)
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	frame.add_child(row)
	for index: int in range(8):
		var button: LifeHudToolbarSlot = preload("res://ui/hud/toolbar_slot.tscn").instantiate() as LifeHudToolbarSlot
		button.name = "Tool_"+String(TOOLS[index]) if index < TOOLS.size() else "Item_%d" % (index-TOOLS.size())
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
		button.pressed.connect(request.bind(index))
		buttons.append(button)

func request(index: int) -> void:
	if index < 0 or index >= buttons.size():
		return
	if index < TOOLS.size():
		tool_requested.emit(TOOLS[index])
	elif _window_start+index-TOOLS.size() < _slots.size():
		item_requested.emit(_window_start+index-TOOLS.size())

func display(slots: Array[Dictionary], selected_inventory: int, active_tool: StringName, window_start: int) -> void:
	if buttons.is_empty():
		return
	_slots = slots
	_window_start = maxi(window_start,0)
	active_index = TOOLS.find(active_tool)
	if active_tool.is_empty():
		var relative: int = selected_inventory-_window_start
		var valid: bool = selected_inventory>=0 and selected_inventory<slots.size() and relative>=0 and relative<buttons.size()-TOOLS.size()
		active_index = TOOLS.size()+relative if valid else -1
	caption.text = tr("UI_TOOL_SEED")
	for index: int in range(buttons.size()):
		var title: String = tr("UI_HOTBAR_EMPTY")
		var texture: Texture2D
		var quantity: int = 0
		if index < TOOLS.size():
			title = tr(String(TOOL_KEYS[index]))
			texture = UiIcons.get_icon(TOOLS[index])
		else:
			var item_index: int = _window_start+index-TOOLS.size()
			if item_index < slots.size():
				var item: Dictionary = slots[item_index]
				var resource: Resource = DataRegistry.get_item(item["item_id"])
				title = tr(String(resource.get("display_name_key")))
				texture = UiIcons.for_item(item["item_id"])
				quantity = int(item["quantity"])
		buttons[index].display(str(index+1),texture,quantity,index==active_index,title)
		if index == active_index:
			caption.text = title
