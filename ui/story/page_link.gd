class_name LifeStoryPageLink
extends Button
signal page_requested(page_id: StringName)
var page_id: StringName
func _ready() -> void:
	theme_type_variation = &"LifeSecondary"
	custom_minimum_size.y = 44
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	pressed.connect(_request)
func display(page: Dictionary) -> void:
	page_id = StringName(page.id)
	text = tr("STORY_PAGE_LINK") % [page.title,page.status]
	tooltip_text = text
	disabled = not page.available
func _request() -> void:
	if not disabled: page_requested.emit(page_id)
