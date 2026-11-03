## LifeProfileParts — localized UI construction, no profile/game ownership.
class_name LifeProfileParts
extends RefCounted

static func frame(parent: Node) -> LifeHudFrame:
	var result: LifeHudFrame = LifeHudFrame.new()
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(result)
	return result

static func banner(parent: Node) -> Label:
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"LifeBannerRed"
	parent.add_child(panel)
	var label: Label = LifeTitleParts.label(panel,&"PROFILE_TITLE",&"LifeDayTitle")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

static func caption(parent: Node) -> Label:
	var result: Label = LifeTitleParts.label(parent,&"",&"LifeText24")
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.max_lines_visible = 2
	result.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return result
