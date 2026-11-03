## LifeHudRegions — viewport anchors only; no domain or modal ownership.
class_name LifeHudRegions
extends RefCounted

static func apply(main: Node) -> void:
	var root: LifeHudRoot = main.hud_presenter.root
	_anchor(root.right_column,Vector2(1,0),Vector2(-244,16),Vector2(228,0))
	_anchor(main.quest_panel,Vector2.ZERO,Vector2(16,20),Vector2(254,224))
	_anchor(main.hotbar_panel,Vector2(0.5,1),Vector2(-270,-152),Vector2(540,136))
	_anchor(main.hud_button_bar,Vector2(0,1),Vector2(16,-86),Vector2(216,70))
	_anchor(root.toasts,Vector2(0,1),Vector2(16,-216),Vector2(280,118))
	_anchor(main.crop_inspector,Vector2(0.5,0.5),Vector2(-180,-124),Vector2(360,262))
	_anchor(main.world.interaction_prompt,Vector2(0.5,1),Vector2(-220,-222),Vector2(440,52))
	for control: Control in [main.get_node("ClockHud"),main.weather_hud,main.wallet_hud,main.toast,main.feedback]:
		control.hide()
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE

static func _anchor(control: Control, anchor: Vector2, offset: Vector2, dimensions: Vector2) -> void:
	control.anchor_left = anchor.x
	control.anchor_right = anchor.x
	control.anchor_top = anchor.y
	control.anchor_bottom = anchor.y
	control.offset_left = offset.x
	control.offset_top = offset.y
	control.offset_right = offset.x+dimensions.x
	control.offset_bottom = offset.y+dimensions.y
