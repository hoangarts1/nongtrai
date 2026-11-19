## LifeDirectorNpcBridge - optional current-day schedule hint, never stock/teleport.
class_name LifeDirectorNpcBridge
extends Node

var _main: Node

func configure(main: Node) -> void:
	_main = main

func override() -> Dictionary:
	return _main.director_runtime.get_projection().visitor.duplicate(true)

func apply() -> void:
	_main.npc_system.refresh_director_schedule()
