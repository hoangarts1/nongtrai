## LifeDirectorEffectsFlow - refresh derived existing adapters after safe owner commit.
class_name LifeDirectorEffectsFlow
extends Node

var _main: Node

func configure(main: Node) -> void:
	_main = main

func refresh() -> void:
	if not is_instance_valid(_main) or _main.director_runtime.is_busy():
		return
	_main.director_water_bridge.apply()
	_main.director_npc_bridge.apply()
	if _main.ecology_effects_flow != null:
		_main.ecology_effects_flow.refresh()
