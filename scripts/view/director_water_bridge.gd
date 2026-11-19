## LifeDirectorWaterBridge - fresh application terms before manual water only.
class_name LifeDirectorWaterBridge
extends Node

var _main: Node

func configure(main: Node) -> void:
	_main = main

func apply() -> bool:
	var projection: Dictionary = _main.director_runtime.get_projection(true)
	return _main.watering_runtime.set_director_terms(projection.water)
