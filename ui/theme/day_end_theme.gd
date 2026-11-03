## LifeDayEndTheme — tooling-only shared styles for the day-end components.
class_name LifeDayEndTheme
extends RefCounted

static func apply(theme: Theme) -> void:
	for type: StringName in [&"LifeDayHeading",&"LifeDayIncome",&"LifeDayExpense",&"LifeDayTotal",&"LifeDayWeather",&"LifeDayWarningText",&"LifeDayTitle"]:
		theme.set_type_variation(type,&"Label")
		theme.set_font(&"font",type,theme.get_font(&"font",&"LifeHeading"))
		theme.set_font_size(&"font_size",type,28 if type in [&"LifeDayTotal",&"LifeDayWeather",&"LifeDayTitle"] else 20)
		theme.set_color(&"font_color",type,theme.get_color(&"red" if type in [&"LifeDayExpense",&"LifeDayWarningText"] else (&"green" if type==&"LifeDayIncome" else &"ink"),&"LifeTokens"))
	for type: StringName in [&"LifeDayColumns",&"LifeDayRow",&"LifeDayColumn"]:
		theme.set_type_variation(type,&"VBoxContainer" if type==&"LifeDayColumn" else &"HBoxContainer")
		theme.set_constant(&"separation",type,24 if type==&"LifeDayColumns" else 10)
	for type: StringName in [&"LifeDayWarning",&"LifeDayForecast"]:
		theme.set_type_variation(type,&"PanelContainer")
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = theme.get_color(&"sky" if type==&"LifeDayForecast" else &"paper",&"LifeTokens").lightened(0.2)
		style.border_color = theme.get_color(&"red" if type==&"LifeDayWarning" else &"ink",&"LifeTokens")
		style.set_border_width_all(3)
		style.set_corner_radius_all(12)
		style.set_content_margin_all(12)
		theme.set_stylebox(&"panel",type,style)
