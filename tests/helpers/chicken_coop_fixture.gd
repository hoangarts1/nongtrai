## ChickenCoopFixture — isolated Main scene and native-input helpers for integration tests.
extends RefCounted
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var locale: String

func setup(host: Node) -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	locale = TranslationServer.get_locale()
	viewport = SubViewport.new()
	viewport.world_2d = World2D.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	host.add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.set_process(false)
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true

func open(coins: int = 1000) -> void:
	main.ui_coordinator.close_active()
	main.wallet.deserialize({"coins":coins})
	main.world.player.move_to_cell(main.chicken_coop_runtime.CONFIG.entrance)
	main.ui_coordinator._sync()
	main.chicken_coop_flow.open()

func cleanup() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)
	for slot: int in [0,1,98]:
		SaveService.delete_save(slot)

func settle(host: Node) -> void:
	for _i: int in range(3):
		await host.get_tree().process_frame

func key(host: Node, code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
		await host.get_tree().process_frame
	await settle(host)

func owners() -> Dictionary:
	return {"coop":main.chicken_coop.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"farm":main.farm_state.serialize(),"water":main.watering_can.serialize(),"clock":GameClock.serialize(),"jobs":main.machine_operations.serialize(),"social":main.npc_system.state.serialize()}
