## LifeHudToolbar — eight slots; only emits requests to its adapter.
class_name LifeHudToolbar
extends VBoxContainer

signal tool_requested(tool_id: StringName)
signal item_requested(slot_index: int)
const TOOLS: Array[StringName] = [&"hoe",&"watering_can",&"harvest"]
const TOOL_KEYS: Array[StringName] = [&"UI_TOOL_HOE",&"UI_TOOL_WATER",&"UI_TOOL_HARVEST"]
var buttons: Array[LifeHudToolbarSlot] = []
var caption: Label
var _window_start: int = 0
var _slots: Array[Dictionary] = []
var active_index: int = 0

func _ready() -> void:
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption_panel: PanelContainer = PanelContainer.new()
	caption_panel.theme_type_variation = &"LifeHudCaption"
	caption_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(caption_panel)
	caption = LifeHudParts.label(caption_panel,&"LifeHudCaptionText")
	var frame: LifeHudFrame = LifeHudFrame.new()
	add_child(frame)
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeHudRow"
	frame.add_child(row)
	for index: int in range(8):
		var button: LifeHudToolbarSlot = preload("res://ui/hud/toolbar_slot.tscn").instantiate() as LifeHudToolbarSlot
		button.name = "Tool_"+String(TOOLS[index]) if index < 3 else "Item_%d" % (index-3)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
		button.pressed.connect(request.bind(index))
		buttons.append(button)

func request(index: int) -> void:
	if index < 0 or index >= 8:
		return
	if index < 3:
		tool_requested.emit(TOOLS[index])
	elif _window_start+index-3 < _slots.size():
		item_requested.emit(_window_start+index-3)

func display(slots: Array[Dictionary], selected_inventory: int, active_tool: StringName, window_start: int) -> void:
	if buttons.is_empty():
		return
	_slots = slots
	_window_start = window_start
	active_index = TOOLS.find(active_tool) if not active_tool.is_empty() else selected_inventory-window_start+3
	for index: int in range(8):
		var title: String = tr("UI_HOTBAR_EMPTY")
		var texture: Texture2D
		var quantity: int = 0
		if index < 3:
			title = tr(String(TOOL_KEYS[index]))
			texture = load("res://assets/icons/ui_%s.svg" % TOOLS[index]) as Texture2D
		else:
			var item_index: int = window_start+index-3
			if item_index < slots.size():
				var item: Dictionary = slots[item_index]
				var resource: Resource = DataRegistry.get_item(item["item_id"])
				title = tr(String(resource.get("display_name_key")))
				texture = UiIcons.for_item(item["item_id"])
				quantity = int(item["quantity"])
		buttons[index].display(str(index+1),texture,quantity,index==active_index,title)
		if index == active_index:
			caption.text = title
	if active_index < 0:
		caption.text = tr("UI_TOOL_SEED")
