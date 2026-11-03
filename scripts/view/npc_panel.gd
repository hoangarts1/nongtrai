## NpcPanel — scrollable dialogue/journal surface, no gameplay state.
class_name NpcPanel
extends PanelContainer

signal close_requested()
var column: VBoxContainer
var title_label: Label
var close_button: Button
var tabs: LifeInventoryTabs
var book: LifeQuestBook
var book_controller: LifeQuestBookController
var _outer: VBoxContainer
var _legacy_margin: MarginContainer

func _ready() -> void:
	visible = false
	LifeTheme.bind(self,&"LifeCompactPanel")
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left = -260.0
	offset_right = 260.0
	offset_top = -150.0
	offset_bottom = 150.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	var margin: MarginContainer = MarginContainer.new()
	_legacy_margin = margin
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var outer: VBoxContainer = VBoxContainer.new()
	_outer = outer
	margin.add_child(outer)
	title_label = Label.new()
	title_label.theme_type_variation = &"LifeHeading"
	outer.add_child(title_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	scroll.add_child(column)
	close_button = Button.new()
	close_button.text = tr("UI_NPC_CLOSE")
	close_button.pressed.connect(func() -> void: close_requested.emit())
	outer.add_child(close_button)

func enable_tabs() -> void:
	if tabs!=null:
		return
	tabs = preload("res://ui/inventory/common_tabs.tscn").instantiate() as LifeInventoryTabs
	_outer.add_child(tabs)
	_outer.move_child(tabs,0)
	tabs.set_active(2)
	tabs.close_requested.connect(func() -> void: close_requested.emit())
	close_button.hide()

func enable_quest_book(main: Node) -> void:
	if book!=null:
		return
	_legacy_margin.hide()
	LifeTheme.bind(self,&"LifeHudClearPanel")
	var inset: MarginContainer = MarginContainer.new()
	inset.theme_type_variation = &"LifeInvOuterMargin"
	add_child(inset)
	book = preload("res://ui/quests/quest_book.tscn").instantiate() as LifeQuestBook
	inset.add_child(book)
	tabs = book.tabs
	tabs.close_requested.connect(func() -> void: close_requested.emit())
	book_controller = LifeQuestBookController.new()
	add_child(book_controller)
	book_controller.configure(self,main)

func show_quest_book() -> void:
	title_label.text = tr("UI_NPC_JOURNAL")
	show()
	book_controller.queue_render()
	tabs.buttons[2].call_deferred("grab_focus")

func show_content(title: String, body: String, actions: Array[Dictionary] = []) -> void:
	title_label.text = title
	for child: Node in column.get_children():
		column.remove_child(child)
		child.queue_free()
	var text: Label = Label.new()
	text.text = body
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(text)
	for action: Dictionary in actions:
		var button: Button = Button.new()
		button.name = String(action.get("id", "Action"))
		button.text = String(action["text"])
		button.disabled = not bool(action.get("enabled", true))
		button.pressed.connect(action["callback"] as Callable)
		column.add_child(button)
	visible = true
	close_button.grab_focus()
