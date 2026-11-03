## LifeInventoryTheme — shared inventory styles, rebuilt by the existing theme tool.
class_name LifeInventoryTheme
extends RefCounted

static func apply(theme: Theme) -> void:
	theme.set_type_variation(&"LifeInvOuterMargin",&"MarginContainer")
	for side: StringName in [&"margin_left",&"margin_right",&"margin_top",&"margin_bottom"]:
		theme.set_constant(side,&"LifeInvOuterMargin",8)
	for type: StringName in [&"LifeInvRow",&"LifeInvColumn",&"LifeInvColumns",&"LifeInvGrid"]:
		theme.set_type_variation(type,&"GridContainer" if type==&"LifeInvGrid" else (&"VBoxContainer" if type==&"LifeInvColumn" else &"HBoxContainer"))
		theme.set_constant(&"separation",type,8 if type!=&"LifeInvColumns" else 20)
		theme.set_constant(&"h_separation",type,8)
		theme.set_constant(&"v_separation",type,8)
	for type: StringName in [&"LifeInvTab",&"LifeInvFilter",&"LifeInvFilterActive",&"LifeInvSlot",&"LifeInvSlotSelected",&"LifeInvAction"]:
		theme.set_type_variation(type,&"Button")
		var selected: bool = type in [&"LifeInvFilterActive",&"LifeInvSlotSelected",&"LifeInvAction"]
		LifeThemeFactory._button(theme,type,LifeThemeFactory.COLORS[&"yellow"] if selected else Color("dfc08c"),8)
		if type==&"LifeInvFilterActive":
			LifeThemeFactory._button(theme,type,LifeThemeFactory.COLORS[&"green"],8)
			for state: StringName in [&"font_color",&"font_hover_color",&"font_pressed_color",&"font_focus_color"]:
				theme.set_color(state,type,Color("fff8df"))
		theme.set_font_size(&"font_size",type,16 if type in [&"LifeInvFilter",&"LifeInvFilterActive"] else 18)
		if type in [&"LifeInvSlot",&"LifeInvSlotSelected"]:
			theme.set_constant(&"icon_max_width",type,52)
		if type==&"LifeInvTab":
			theme.set_font(&"font",type,theme.get_font(&"font",&"LifeHeading"))
		for state: StringName in [&"normal",&"hover",&"pressed",&"disabled",&"focus"]:
			var box: StyleBoxFlat = theme.get_stylebox(state,type) as StyleBoxFlat
			box.content_margin_left = 6
			box.content_margin_right = 6
			if type in [&"LifeInvSlot",&"LifeInvSlotSelected"]:
				box.set_content_margin_all(5)
				if state==&"disabled":
					box.bg_color = Color("decaa0")
	for type: StringName in [&"LifeInvTitle",&"LifeInvNote"]:
		theme.set_type_variation(type,&"Label")
		theme.set_font_size(&"font_size",type,24 if type==&"LifeInvTitle" else 16)
		theme.set_font(&"font",type,theme.get_font(&"font",&"LifeHeading") if type==&"LifeInvTitle" else theme.default_font)
	theme.set_type_variation(&"LifeInvInset",&"PanelContainer")
	theme.set_stylebox(&"panel",&"LifeInvInset",LifeThemeFactory._box(Color("f2dba5"),10,14))
