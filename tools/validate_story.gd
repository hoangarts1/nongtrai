extends SceneTree
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var config: StoryConfig = CONFIG.frozen_copy()
	for argument: String in OS.get_cmdline_user_args():
		if argument=="--fixture=cycle": config.pages[0].requires_pages = PackedStringArray([String(config.pages[0].page_id)])
		else: print("[validate_story] unknown fixture"); quit(1); return
	var errors: PackedStringArray = StoryCatalogValidator.validate(config)
	print("[validate_story] PASS" if errors.is_empty() else "[validate_story] rejected: "+str(errors))
	quit(0 if errors.is_empty() else 1)
