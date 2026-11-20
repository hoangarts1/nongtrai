## ClearingFixture - real Main commands; isolated files, fixed clock/actor ticks.
extends "res://tests/helpers/story_fixture.gd"
const TARGETS: Array[Vector2i] = [Vector2i(3,-1),Vector2i(2,-2),Vector2i(3,-2)]
var _clock_processing: bool
func setup(host: Node) -> void:
	_clock_processing = GameClock.is_processing()
	GameClock.set_process(false)
	super.setup(host)
	for actor: NpcActor in main.npc_system.actors.values(): actor.set_process(false)
func cleanup() -> void:
	super.cleanup()
	GameClock.set_process(_clock_processing)
func owners() -> Dictionary:
	var result: Dictionary = super.owners()
	result["clearing"] = main.clearing_state.serialize()
	return result
func debris(cell: Vector2i) -> Node2D:
	for child: Node in main.presentation.get_world_art_root().get_children():
		if child is SuppliedSceneryView and child.get_meta("cell",null)==cell: return child as Node2D
	return null
func clear_at(cell: Vector2i) -> Dictionary:
	play()
	main.world.player.move_to_cell(cell+Vector2i.DOWN)
	main.tool_controller.select_tool(&"shovel")
	return main.clearing_runtime.clear(cell)
