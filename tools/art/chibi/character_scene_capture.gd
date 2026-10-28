## Compatibility documentation script for the C1 normal-renderer scene capture.
##
## The capture must start the project's configured main scene, because `Main`
## relies on project autoloads. Use `tools/capture_chibi_characters.bat`; it
## passes `--capture-chibi-characters` to Main.gd, which captures and exits
## without loading or modifying a save slot. This script deliberately does not
## instantiate main.tscn from `-s` mode, where those autoload names are absent.
extends SceneTree

func _init() -> void:
	print("[character_scene_capture] use tools/capture_chibi_characters.bat")
	quit(0)
