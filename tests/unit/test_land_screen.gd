extends GutTest
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var locale: String

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	locale = TranslationServer.get_locale()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mai","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true

func after_each() -> void:
	await get_tree().process_frame
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.paused = paused
	TranslationServer.set_locale(locale)
	SaveService.delete_save(1)

func test_native_shop_entry_affordability_purchase_and_modal_lifecycle() -> void:
	var flow: LandRuntime = main.land_runtime
	assert_null(flow.panel.summary,"Land contents are lazy")
	main.machine_shop_panel.open()
	await _settle()
	assert_eq(main.machine_shop_panel.screen.tabs.size(),3)
	await _click(main.machine_shop_panel.screen.land_button)
	assert_true(flow.panel.visible)
	assert_false(main.machine_shop_panel.visible)
	assert_eq(main.ui_coordinator.get_active_panel(),flow.panel)
	assert_false(main.world.player.movement_enabled)
	assert_true(GameClock.paused)
	assert_true(flow.panel.footer.buy_button.disabled)
	assert_eq(flow.model.price,500)
	assert_eq(main.wallet.get_coins(),100)
	await _click(flow.panel.footer.buy_button)
	assert_eq(main.wallet.get_coins(),100)
	main.wallet.add_coins(900,&"test")
	await _settle()
	assert_false(flow.panel.footer.buy_button.disabled)
	flow.panel.footer.buy_button.grab_focus()
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),500)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72)
	assert_true(flow.panel.footer.buy_button.disabled)
	await _key(KEY_SPACE)
	assert_eq(main.wallet.get_coins(),500)
	await _key(KEY_ESCAPE)
	assert_false(flow.panel.visible)
	assert_null(main.ui_coordinator.get_active_panel())
	assert_true(main.world.player.movement_enabled)
	flow.purchase(&"farm_east_1")
	assert_eq(main.wallet.get_coins(),500,"Hidden requests are inert")
	main.machine_inventory.add_machine(&"stove",1)
	assert_true(main.machine_build.place(&"stove",Vector2i(2,3),0).ok)
	main.machine_shop_panel.open_machine(Vector2i(2,3))
	await _settle()
	assert_false(main.machine_shop_panel.screen.land_button.visible)
	main.machine_shop_panel.controller.request(&"land")
	assert_false(flow.panel.visible)
	main.land_runtime.restore({})
	main.machine_shop_panel.open()
	flow.open()
	await _settle()
	assert_true(main.land_ownership.grant_next(&"farm_east_1"))
	flow.purchase(&"farm_east_1")
	assert_eq(flow.result.reason,&"already_owned")
	assert_eq(main.wallet.get_coins(),500,"Stale view cannot debit a previously granted parcel")
	main.call("_load_payload",{"land_ownership":42})
	assert_false(flow.panel.visible)
	assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),36)

func test_vi_en_three_sizes_actual_states_fit_and_render_without_mutation() -> void:
	var flow: LandRuntime = main.land_runtime
	for language: String in ["vi","en"]:
		TranslationServer.set_locale(language)
		for dimensions: Vector2i in [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1600,900)]:
			viewport.size = dimensions
			main.land_runtime.restore({})
			main.wallet.deserialize({"coins":100})
			main.machine_shop_panel.open()
			await _settle()
			await _click(main.machine_shop_panel.screen.land_button)
			assert_true(flow.panel.visible)
			await _capture("%s_%d_locked" % [language,dimensions.x])
			main.wallet.add_coins(900,&"test")
			await _settle()
			await _capture("%s_%d_available" % [language,dimensions.x])
			await _click(flow.panel.footer.buy_button)
			assert_eq(main.wallet.get_coins(),500)
			assert_eq(LifeLandSnapshot.owned_cells(main.land_ownership),72)
			await _capture("%s_%d_owned" % [language,dimensions.x])
			await _click(flow.panel.footer.cancel_button)
			assert_false(flow.panel.visible)

func _settle() -> void:
	for frame: int in range(5):
		await get_tree().process_frame

func _click(button: Control) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	viewport.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _key(code: Key) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event,true)
		await get_tree().process_frame
	await _settle()

func _capture(stem: String) -> void:
	await _settle()
	var panel: LifeLandScreen = main.land_runtime.panel
	var bounds: Rect2 = Rect2(Vector2.ZERO,Vector2(viewport.size)).grow(1)
	assert_true(bounds.encloses(panel.get_global_rect()),stem+" screen inside viewport")
	for node: Node in panel.find_children("*","Control",true,false):
		var control: Control = node as Control
		if control.is_visible_in_tree():
			assert_true(panel.get_global_rect().grow(1).encloses(control.get_global_rect()),String(control.name)+" stays within the panel")
	var before: Dictionary = {"wallet":main.wallet.serialize(),"land":main.land_ownership.serialize(),"clock":GameClock.serialize(),"farm":main.farm_state.serialize()}
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://phase64b_%s.png" % stem),OK)
	assert_eq({"wallet":main.wallet.serialize(),"land":main.land_ownership.serialize(),"clock":GameClock.serialize(),"farm":main.farm_state.serialize()},before)
