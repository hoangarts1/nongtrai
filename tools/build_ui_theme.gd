extends SceneTree

func _initialize() -> void:
	var factory: Script = load("res://ui/theme/theme_factory.gd") as Script
	var theme: Theme = factory.call("build") as Theme
	var result: Error = ResourceSaver.save(theme,"res://ui/theme/the_life_theme.tres")
	if result != OK:
		printerr("[ui_theme] save failed: %s" % error_string(result))
		quit(1)
		return
	print("[ui_theme] wrote ui/theme/the_life_theme.tres")
	quit()
