class_name LifeStoryMomentBody
extends VBoxContainer
var title: Label
var scroll: ScrollContainer
var body: Label
var status: Label
func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	title = LifePauseParts.label(self,&"",&"LifeHeading")
	status = LifePauseParts.label(self,&"",&"LifeSecondaryText")
	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	scroll.follow_focus = true
	add_child(scroll)
	body = LifePauseParts.label(scroll,&"",&"LifeText18")
func display(model: Dictionary) -> void:
	title.text = String(model.get("title",""))
	body.text = String(model.get("body",""))
	status.text = String(model.get("status",""))
