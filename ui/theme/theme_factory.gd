## LifeThemeFactory — deterministic tooling-only theme builder from the supplied UI kit tokens.
class_name LifeThemeFactory
extends RefCounted

const COLORS: Dictionary = {
	&"ink": Color("3a2412"), &"wood": Color("bc8340"), &"paper": Color("f5e3b0"),
	&"green": Color("5fb230"), &"yellow": Color("f7bc32"), &"red": Color("d6453a"),
	&"sky": Color("6fb7f0"), &"coin": Color("ffd25a")
}

static func build() -> Theme:
	var result: Theme = Theme.new()
	var body: FontVariation = _font("res://assets/fonts/Nunito/Nunito-Variable.ttf", 600)
	var heading: FontVariation = _font("res://assets/fonts/Baloo_2/Baloo2-Variable.ttf", 800)
	var serif: FontVariation = _font("res://assets/fonts/Noto_Serif/NotoSerif-Italic-Variable.ttf", 400)
	result.default_font = body
	result.default_font_size = 18
	for token: StringName in COLORS:
		result.set_color(token, &"LifeTokens", COLORS[token])
	result.set_constant(&"frame_margin", &"LifeTokens", 28)
	result.set_constant(&"icon_size", &"LifeTokens", 32)
	for type: StringName in [&"Label",&"Button",&"CheckButton",&"LineEdit",&"OptionButton",&"TooltipLabel",&"TabBar"]:
		result.set_color(&"font_color",type,COLORS[&"ink"])
		result.set_color(&"font_hover_color",type,COLORS[&"ink"])
		result.set_color(&"font_pressed_color",type,COLORS[&"ink"])
		result.set_color(&"font_focus_color",type,COLORS[&"ink"])
		result.set_color(&"font_disabled_color",type,Color("847d69"))
	result.set_color(&"font_placeholder_color",&"LineEdit",Color("887657"))
	_button(result,&"Button",COLORS[&"wood"])
	_button(result,&"OptionButton",COLORS[&"wood"])
	_button(result,&"CheckButton",COLORS[&"wood"])
	for entry: Dictionary in [
		{"id": &"LifePrimary","color":COLORS[&"green"]},
		{"id": &"LifeSecondary","color":COLORS[&"wood"]},
		{"id": &"LifeDanger","color":COLORS[&"red"]},
		{"id": &"LifeAccent","color":COLORS[&"yellow"]},
		{"id": &"LifeRound","color":COLORS[&"wood"]}
	]:
		var type: StringName = entry["id"]
		result.set_type_variation(type,&"Button")
		_button(result,type,entry["color"],32 if type == &"LifeRound" else 12)
		if type in [&"LifePrimary",&"LifeDanger"]:
			for state: StringName in [&"font_color",&"font_hover_color",&"font_pressed_color",&"font_focus_color"]:
				result.set_color(state,type,Color("fff8df"))
		for state: String in ["Hover","Pressed"]:
			var preview: StringName = StringName("%sPreview%s" % [type,state])
			result.set_type_variation(preview,type)
			result.set_stylebox(&"normal",preview,result.get_stylebox(state.to_lower(),type))
	_panel(result,&"PanelContainer",_box(COLORS[&"paper"],12,0))
	_panel(result,&"Panel",_box(COLORS[&"paper"],12,0))
	_panel_variation(result,&"LifeCompactPanel",&"PanelContainer",_box(COLORS[&"paper"],16,0))
	_panel_variation(result,&"LifeStatus",&"Panel",_box(COLORS[&"paper"],16,0))
	_panel_variation(result,&"LifeWood",&"PanelContainer",_box(COLORS[&"paper"],16,28))
	_panel_variation(result,&"LifePill",&"PanelContainer",_box(COLORS[&"paper"],20,8))
	_panel_variation(result,&"LifeKeyHint",&"PanelContainer",_box(COLORS[&"paper"],8,6))
	for tone: String in ["Green","Red","Blue"]:
		var type: StringName = StringName("LifeBanner"+tone)
		var color: Color = COLORS[&"green"] if tone == "Green" else (COLORS[&"red"] if tone == "Red" else COLORS[&"sky"])
		_panel_variation(result,type,&"PanelContainer",_box(color,10,10))
	for tone: String in ["New","Main"]:
		_panel_variation(result,StringName("LifeTag"+tone),&"PanelContainer",_box(COLORS[&"red"] if tone=="New" else COLORS[&"green"],8,5))
	for type: StringName in [&"LifeItemSlot",&"LifeItemSlotSelected",&"LifeItemSlotLocked"]:
		result.set_type_variation(type,&"Button")
		_button(result,type,Color("d7b77b"),10)
		if type == &"LifeItemSlotSelected":
			var selected: StyleBoxFlat = _box(COLORS[&"paper"],10,4)
			selected.border_color = COLORS[&"yellow"]
			selected.set_border_width_all(4)
			for state: StringName in [&"normal",&"hover",&"pressed",&"focus"]:
				result.set_stylebox(state,type,selected)
		if type == &"LifeItemSlotLocked":
			result.set_stylebox(&"disabled",type,_box(Color("bab198"),10,4))
	for tone: String in ["Green","Blue","Gold"]:
		var type: StringName = StringName("LifeProgress"+tone)
		result.set_type_variation(type,&"ProgressBar")
		result.set_stylebox(&"background",type,_box(Color("796348"),10,0))
		var fill: StyleBoxFlat = _box(COLORS[&"green"] if tone=="Green" else (COLORS[&"sky"] if tone=="Blue" else COLORS[&"yellow"]),8,0)
		fill.set_border_width_all(0)
		fill.shadow_size = 0
		result.set_stylebox(&"fill",type,fill)
		result.set_color(&"font_color",type,COLORS[&"paper"])
	_panel(result,&"TooltipPanel",_box(COLORS[&"paper"],10,10))
	result.set_font_size(&"font_size",&"TooltipLabel",16)
	for state: StringName in [&"normal",&"focus",&"read_only"]:
		result.set_stylebox(state,&"LineEdit",_box(COLORS[&"paper"].lightened(0.08),8,8))
	for size: int in [13,14,15,16,18,20,22,24,28,32,44]:
		var type: StringName = StringName("LifeText%d" % size)
		result.set_type_variation(type,&"Label")
		result.set_font_size(&"font_size",type,size)
	result.set_type_variation(&"LifeHeading",&"Label")
	result.set_font(&"font",&"LifeHeading",heading)
	result.set_font_size(&"font_size",&"LifeHeading",24)
	result.set_type_variation(&"LifeTitle",&"LifeHeading")
	result.set_font(&"font",&"LifeTitle",heading)
	result.set_font_size(&"font_size",&"LifeTitle",44)
	result.set_color(&"font_color",&"LifeTitle",COLORS[&"paper"])
	result.set_color(&"font_outline_color",&"LifeTitle",COLORS[&"ink"])
	result.set_constant(&"outline_size",&"LifeTitle",3)
	result.set_type_variation(&"LifeSecondaryText",&"Label")
	result.set_font(&"font",&"LifeSecondaryText",serif)
	result.set_font_size(&"font_size",&"LifeSecondaryText",16)
	for type: StringName in [&"LifeSmall",&"LifeWorldLabel",&"LifeQuantity"]:
		result.set_type_variation(type,&"Label")
		result.set_font_size(&"font_size",type,13 if type == &"LifeWorldLabel" else 15)
		if type != &"LifeSmall":
			result.set_color(&"font_color",type,COLORS[&"paper"])
			result.set_color(&"font_outline_color",type,COLORS[&"ink"])
			result.set_constant(&"outline_size",type,2)
	result.set_type_variation(&"LifeToggle",&"CheckButton")
	result.set_icon(&"checked",&"LifeToggle",_toggle_icon(true))
	result.set_icon(&"unchecked",&"LifeToggle",_toggle_icon(false))
	result.set_stylebox(&"slider",&"HSlider",_box(Color("796348"),6,0))
	result.set_stylebox(&"grabber_area",&"HSlider",_box(COLORS[&"green"],6,0))
	result.set_stylebox(&"grabber_area_highlight",&"HSlider",_box(COLORS[&"green"].lightened(0.1),6,0))
	result.set_icon(&"grabber",&"HSlider",_knob())
	result.set_icon(&"grabber_highlight",&"HSlider",_knob())
	for state: StringName in [&"normal",&"pressed"]:
		result.set_stylebox(state,&"LifeTab",_box(COLORS[&"paper"] if state == &"pressed" else COLORS[&"wood"],8,8))
	result.set_type_variation(&"LifeTab",&"Button")
	result.set_type_variation(&"LifeGalleryMargin",&"MarginContainer")
	for edge: StringName in [&"margin_left",&"margin_right",&"margin_top",&"margin_bottom"]:
		result.set_constant(edge,&"LifeGalleryMargin",24)
	result.set_type_variation(&"LifeGalleryColumn",&"VBoxContainer")
	result.set_constant(&"separation",&"LifeGalleryColumn",12)
	result.set_type_variation(&"LifeGalleryGrid",&"GridContainer")
	result.set_constant(&"h_separation",&"LifeGalleryGrid",12)
	result.set_constant(&"v_separation",&"LifeGalleryGrid",12)
	result.set_type_variation(&"LifeSlotQuantityInset",&"MarginContainer")
	for edge: StringName in [&"margin_left",&"margin_right",&"margin_top",&"margin_bottom"]:
		result.set_constant(edge,&"LifeSlotQuantityInset",5)
	_hud(result,heading)
	LifeDayEndTheme.apply(result)
	return result

static func _hud(theme: Theme, heading: Font) -> void:
	_panel_variation(theme,&"LifeHudWood",&"PanelContainer",_box(COLORS[&"wood"],18,12))
	_panel_variation(theme,&"LifeHudPaper",&"PanelContainer",_box(COLORS[&"paper"],12,10))
	var quest: StyleBoxFlat = _box(COLORS[&"paper"],4,16)
	quest.border_color = COLORS[&"wood"].darkened(0.3)
	quest.set_border_width_all(4)
	_panel_variation(theme,&"LifeHudQuest",&"PanelContainer",quest)
	_panel_variation(theme,&"LifeHudCaption",&"PanelContainer",_box(COLORS[&"wood"],8,6))
	_panel_variation(theme,&"LifeHudToast",&"PanelContainer",_box(COLORS[&"wood"],24,10))
	theme.set_type_variation(&"LifeHudClearPanel",&"PanelContainer")
	theme.set_stylebox(&"panel",&"LifeHudClearPanel",StyleBoxEmpty.new())
	for type: StringName in [&"LifeHudSlot",&"LifeHudSlotSelected",&"LifeHudRound"]:
		theme.set_type_variation(type,&"Button")
		_button(theme,type,COLORS[&"paper"] if type!=&"LifeHudRound" else COLORS[&"wood"],24 if type==&"LifeHudRound" else 10)
		theme.set_constant(&"icon_max_width",type,30 if type==&"LifeHudRound" else 44)
		for state: StringName in [&"normal",&"hover",&"pressed",&"focus"]:
			var style: StyleBoxFlat = theme.get_stylebox(state,type) as StyleBoxFlat
			style.set_content_margin_all(5)
			if type==&"LifeHudSlotSelected":
				style.border_color = COLORS[&"yellow"]
				style.set_border_width_all(4)
	for type: StringName in [&"LifeHudHeading",&"LifeHudTime",&"LifeHudCoins",&"LifeHudCaptionText",&"LifeHudToastText",&"LifeHudBody",&"LifeHudNote",&"LifeHudKey",&"LifeHudCheck"]:
		theme.set_type_variation(type,&"Label")
		theme.set_font(&"font",type,heading if type not in [&"LifeHudBody",&"LifeHudNote",&"LifeHudKey"] else theme.default_font)
		theme.set_font_size(&"font_size",type,32 if type in [&"LifeHudTime",&"LifeHudCoins"] else (13 if type in [&"LifeHudNote",&"LifeHudKey"] else 18))
		if type in [&"LifeHudCaptionText",&"LifeHudToastText",&"LifeHudCoins"]:
			theme.set_color(&"font_color",type,COLORS[&"coin"] if type==&"LifeHudCoins" else COLORS[&"paper"])
		theme.set_color(&"font_color",&"LifeHudCheck",COLORS[&"green"])
	for type: StringName in [&"LifeHudColumn",&"LifeHudRow"]:
		theme.set_type_variation(type,&"VBoxContainer" if type==&"LifeHudColumn" else &"HBoxContainer")
		theme.set_constant(&"separation",type,6)
	theme.set_type_variation(&"LifeHudShortcutColumn",&"VBoxContainer")
	theme.set_constant(&"separation",&"LifeHudShortcutColumn",3)

static func _font(path: String, weight: int) -> FontVariation:
	var font: FontVariation = FontVariation.new()
	font.base_font = load(path) as Font
	font.fallbacks = [load("res://assets/fonts/Open_Sans/OpenSans-Regular.ttf") as Font]
	font.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):weight}
	return font

static func _box(color: Color, radius: int, margin: int) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = COLORS[&"ink"]
	box.set_border_width_all(3)
	box.set_corner_radius_all(radius)
	box.shadow_color = Color(0.16,0.09,0.03,0.32)
	box.shadow_offset = Vector2(0,4)
	box.shadow_size = 3
	box.set_content_margin_all(float(margin))
	return box

static func _button(theme: Theme, type: StringName, color: Color, radius: int = 12) -> void:
	for state: String in ["normal","hover","pressed","disabled","focus"]:
		var tint: Color = color.lightened(0.12) if state=="hover" else (color.darkened(0.12) if state=="pressed" else color)
		if state=="disabled":
			tint = Color("c6bfa9")
		var style: StyleBoxFlat = _box(tint,radius,0)
		style.content_margin_left = 14
		style.content_margin_right = 14
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		if state=="pressed":
			style.shadow_size = 0
			style.shadow_offset = Vector2(0,1)
		elif state=="focus":
			style.border_color = COLORS[&"yellow"]
		elif state=="disabled":
			style.shadow_size = 0
		theme.set_stylebox(state,type,style)

static func _panel(theme: Theme, type: StringName, style: StyleBoxFlat) -> void:
	theme.set_stylebox(&"panel",type,style)

static func _panel_variation(theme: Theme, type: StringName, base: StringName, style: StyleBoxFlat) -> void:
	theme.set_type_variation(type,base)
	_panel(theme,type,style)

static func _toggle_icon(enabled: bool) -> Texture2D:
	var image: Image = Image.create(48,26,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y: int in range(26):
		for x: int in range(48):
			var center: Vector2 = Vector2(clampf(float(x),13,35),13)
			if Vector2(x,y).distance_to(center) <= 12:
				image.set_pixel(x,y,COLORS[&"green"] if enabled else Color("b7ae94"))
			var knob: Vector2 = Vector2(35 if enabled else 13,13)
			if Vector2(x,y).distance_to(knob) <= 10:
				image.set_pixel(x,y,COLORS[&"paper"])
	return ImageTexture.create_from_image(image)

static func _knob() -> Texture2D:
	var image: Image = Image.create(24,24,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y: int in range(24):
		for x: int in range(24):
			var distance: float = Vector2(x,y).distance_to(Vector2(12,12))
			if distance <= 11:
				image.set_pixel(x,y,COLORS[&"yellow"] if distance < 8 else COLORS[&"ink"])
	return ImageTexture.create_from_image(image)
