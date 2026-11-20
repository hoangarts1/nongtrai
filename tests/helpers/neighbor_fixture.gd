## NeighborFixture - real route steps + native conversations, isolated saves/clock.
extends "res://tests/helpers/clearing_fixture.gd"
func near(id: StringName) -> void:
	play()
	var weather: Dictionary = main.weather_state.serialize()
	weather.today = "sunny"
	weather.forecast = ["sunny","sunny","sunny"]
	main.weather_state.deserialize(weather)
	GameClock.set_time(10,0)
	main.npc_system.configure_navigation()
	var state: NpcSocialState = main.npc_system.state
	while not state.paths.get(id,[]).is_empty(): state.advance_step(id)
	(main.npc_system.actors[id] as NpcActor).reset_position()
	main.world.player.move_to_cell(state.cells[id]+Vector2i.DOWN)
	main.world.camera_rig.set_target(main.world.player)

func converse(host: Node, id: StringName) -> void:
	near(id)
	await key(host,KEY_E)

func non_social_owners() -> Dictionary:
	var result: Dictionary = owners()
	result.erase("social")
	result.erase("story")
	return result

func mouse(host: Node, position: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	viewport.push_input(motion,true)
	await host.get_tree().process_frame
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = position
		event.global_position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		viewport.push_input(event,true)
		await host.get_tree().process_frame
	await settle(host)
