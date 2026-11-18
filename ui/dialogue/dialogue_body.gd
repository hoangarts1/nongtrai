## LifeDialogueBody — scrollable actual dialogue/details with exact friendship count.
class_name LifeDialogueBody
extends LifeHudFrame

var text: Label
var details: Label
var friendship: Label
var scroll: ScrollContainer

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	column.add_child(margin)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var content: VBoxContainer = LifeHudParts.column(margin)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var lines: VBoxContainer = LifeHudParts.column(scroll)
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text = LifePauseParts.label(lines, &"", &"LifeText22")
	details = LifePauseParts.label(lines, &"", &"LifeText18")
	friendship = LifePauseParts.label(content, &"", &"LifeText18")

func display(snapshot: Dictionary) -> void:
	text.text = String(snapshot.get("body", ""))
	details.text = String(snapshot.get("details", ""))
	details.visible = not details.text.is_empty()
	friendship.text = tr("UI_NPC_FRIENDSHIP") % [String(snapshot.get("name", "")), int(snapshot.get("friendship", 0)), int(snapshot.get("friendship_max", 0))]
	scroll.scroll_vertical = 0
