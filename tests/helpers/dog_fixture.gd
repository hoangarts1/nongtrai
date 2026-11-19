## DogFixture - actual Main and isolated save families; deterministic manual dog ticks.
extends "res://tests/helpers/director_fixture.gd"
func setup(host: Node) -> void:
	super.setup(host)
	main.dog_runtime.set_process(false)
func play() -> void:
	main.ui_coordinator.close_active()
	GameClock.paused = false
func ticks(count: int, delta: float = 0.1) -> void:
	for _index: int in range(count): main.dog_runtime.advance(delta)
func actors() -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in main.world.objects.get_children():
		if child is DogActor2D: result.append(child)
	return result
