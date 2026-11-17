extends GutTest
var main: Node
var viewport: SubViewport
var clock: Dictionary
var paused: bool
var accumulator: float
var speed: float
var locale: String
var settings_bytes: PackedByteArray
var settings_existed: bool
var drawn: Dictionary = {}

func before_each() -> void:
	clock = GameClock.serialize()
	paused = GameClock.paused
	accumulator = float(GameClock.get("_real_seconds_accumulator"))
	speed = GameClock.time_speed
	locale = TranslationServer.get_locale()
	settings_existed = FileAccess.file_exists(Settings.SETTINGS_PATH)
	settings_bytes = FileAccess.get_file_as_bytes(Settings.SETTINGS_PATH) if settings_existed else PackedByteArray()
	GameClock.paused = true
	Settings.set_locale("vi")
	viewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	main = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game","Mây 7","Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
	_toasts().clear()
	await _settle()

func after_each() -> void:
	viewport.free()
	GameClock.deserialize(clock)
	GameClock.set("_real_seconds_accumulator",accumulator)
	GameClock.time_speed = speed
	GameClock.paused = paused
	if settings_existed:
		var file: FileAccess = FileAccess.open(Settings.SETTINGS_PATH,FileAccess.WRITE)
		file.store_buffer(settings_bytes)
		file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Settings.SETTINGS_PATH))
	Settings.set("_config",ConfigFile.new())
	Settings.call("_ready")
	TranslationServer.set_locale(locale)
	SaveService.delete_save(1)
	SaveService.delete_save(2)

func test_same_main_locale_changes_refresh_labels_and_redraw_paused_art_without_owner_changes() -> void:
	for art: PlaceholderWorld2D in _art():
		art.draw.connect(_drawn.bind(art.get_instance_id()))
	_check_labels()
	await _capture("vi_1152_initial")
	var before: Dictionary = _owners()
	var appearance: Array = _appearance()
	for step: Dictionary in [{"locale":"en","size":1152},{"locale":"vi","size":1152},{"locale":"vi","size":1600},{"locale":"en","size":1600}]:
		var changed: bool = TranslationServer.get_locale()!=step.locale
		var same_size: bool = viewport.size.x==int(step.size)
		drawn.clear()
		Settings.set_locale(step.locale)
		viewport.size = Vector2i(step.size,int(step.size)*9/16)
		_check_labels()
		await _capture("%s_%d_live" % [step.locale,step.size])
		if changed and same_size and DisplayServer.get_name()!="headless":
			for art: PlaceholderWorld2D in _art():
				assert_gt(int(drawn.get(art.get_instance_id(),0)),0,"Locale refresh redraws the paused label pill")
		assert_eq(_appearance(),appearance,"No label refresh rebuilds or resets art")
		assert_eq(_owners(),before)
	assert_eq(main.profile.player_name,"Mây 7","Player-authored names are never translated")

func test_supported_settings_apply_same_locale_and_new_game_load_title_guards() -> void:
	for unconfigured: Node in [WorldPresentation.new(),NpcSystem.new()]:
		unconfigured.notification(Node.NOTIFICATION_TRANSLATION_CHANGED)
		unconfigured.free()
	var before: Dictionary = _owners()
	main.pause_menu.open()
	await _settle()
	var screen: LifePauseShell = main.pause_menu.shell
	screen.settings.game.set_locale("en")
	main.pause_menu.presenter.apply()
	assert_eq(Settings.get_locale(),"en")
	_check_labels()
	assert_eq(_owners(),before)
	_toasts().clear()
	_toasts().show_message(tr("UI_SAVED"))
	var card: Node = _toasts().get_child(0)
	var timer: Timer = _timer(card)
	var remaining: float = timer.time_left
	main.pause_menu.presenter.apply()
	assert_same(_toasts().get_child(0),card,"Applying the same locale preserves existing feedback")
	assert_lte(timer.time_left,remaining)
	main.pause_menu.close()
	assert_true(main.call("_save_game_to_slot",2))
	main.call("_start_new_game","Tên mới","Garden")
	GameClock.paused = true
	_check_labels()
	assert_true(main.call("_load_game_from_slot",2))
	GameClock.paused = true
	assert_eq(main.profile.player_name,"Mây 7")
	before = _owners()
	Settings.set_locale("vi")
	_check_labels()
	assert_eq(_owners(),before)
	assert_true(main.call("_return_to_start_menu"))
	main.profile.erase("player_name")
	Settings.set_locale("en")
	var house: PlaceholderWorld2D = main.world.objects.get_node("House/Placeholder") as PlaceholderWorld2D
	assert_false(house.label.visible)
	assert_eq(house.label.text,"")

func test_locale_dismissal_keeps_new_feedback_safe_from_old_deferred_timeouts() -> void:
	var before: Dictionary = _owners()
	_toasts().show_message(tr("UI_SAVED"))
	_toasts().show_message(tr("UI_SAVED"))
	assert_eq(_toasts().get_child_count(),2)
	Settings.set_locale("en")
	for old: Control in _toasts().get_children():
		assert_false(old.visible,"Old messages hide during the translation traversal")
	await get_tree().process_frame
	assert_eq(_toasts().get_child_count(),0)
	main.feedback.show_message(tr("UI_SAVED"))
	var old_card: Node = _toasts().get_child(0)
	assert_eq((old_card as LifeHudToastCard).caption.text,tr("UI_SAVED"))
	_timer(old_card).timeout.emit()
	Settings.set_locale("vi")
	assert_false((old_card as Control).visible)
	main.feedback.show_message(tr("UI_SAVED"))
	var replacement: Node = _toasts().get_child(0)
	await get_tree().process_frame
	assert_eq(_toasts().get_child_count(),1)
	assert_same(_toasts().get_child(0),replacement,"An old timeout cannot remove replacement feedback")
	assert_eq((replacement as LifeHudToastCard).caption.text,tr("UI_SAVED"))
	_timer(replacement).timeout.emit()
	await get_tree().process_frame
	assert_eq(_toasts().get_child_count(),0)
	assert_eq(_owners(),before,"Locale and toast lifetimes do not replay gameplay events")

func _toasts() -> LifeHudToastStack:
	return main.hud_presenter.root.toasts

func _timer(card: Node) -> Timer:
	for child: Node in card.get_children():
		if child is Timer:
			return child as Timer
	return null

func _art() -> Array[PlaceholderWorld2D]:
	var result: Array[PlaceholderWorld2D] = []
	for anchor_name: String in ["House","SeedShop","ShippingBin"]:
		result.append(main.world.objects.get_node(anchor_name+"/Placeholder") as PlaceholderWorld2D)
	for home: PlaceholderWorld2D in main.npc_system.homes.values():
		result.append(home)
	return result

func _check_labels() -> void:
	var art: Array[PlaceholderWorld2D] = _art()
	var owner: String = String(main.profile.get("player_name",""))
	assert_eq(art[0].label.text,tr("UI_NPC_HOME") % owner)
	assert_eq(art[1].label.text,tr("UI_PROMPT_SHOP"))
	assert_eq(art[2].label.text,tr("UI_PROMPT_SELL"))
	for id: StringName in main.npc_system.homes:
		var npc: NpcData = main.npc_system.state.get_npc(id)
		var home: PlaceholderWorld2D = main.npc_system.homes[id]
		assert_eq(home.label.text,tr("UI_NPC_HOME") % tr(String(npc.display_name_key)))

func _appearance() -> Array:
	var result: Array = []
	for art: PlaceholderWorld2D in _art():
		result.append([art.get_instance_id(),art.label.get_instance_id(),art.global_transform,art.kind,art.color,art.get("_phase"),art.get("_accum")])
	var avatar: PlaceholderAvatar2D = main.presentation.get_player_avatar()
	result.append([avatar.get_instance_id(),avatar.skin,avatar.hair,avatar.outfit,avatar.get_hair_style(),avatar.get("_phase")])
	var scenery: Node = main.presentation.get_world_art_root()
	for child: Node in scenery.get_children():
		result.append(child.get_instance_id())
	return result

func _owners() -> Dictionary:
	return {"clock":GameClock.serialize(),"bag":main.inventory.serialize(),"wallet":main.wallet.serialize(),"farm":main.farm_state.serialize(),"jobs":main.machine_operations.serialize(),"social":main.npc_system.state.serialize(),"profile":main.profile.duplicate(true),"save":SaveService.load_game(1)}

func _drawn(id: int) -> void:
	drawn[id] = int(drawn.get(id,0))+1

func _capture(stem: String) -> void:
	await _settle()
	var before: Dictionary = _owners()
	if DisplayServer.get_name()!="headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://d72_c4_%s.png" % stem),OK)
	assert_eq(_owners(),before)

func _settle() -> void:
	for frame: int in range(90):
		await get_tree().process_frame
		if not main.ui_coordinator._layout_queued and not main.inventory_panel.controller._queued:
			return
	assert_true(false,"Locale layout did not settle")
