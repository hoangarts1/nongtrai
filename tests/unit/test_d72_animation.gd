extends GutTest

const MACHINE_CELL: Vector2i = Vector2i(2,3)
const CROP_CELL: Vector2i = Vector2i(1,2)
var _main: Node
var _viewport: SubViewport
var _view: MachinePresentation
var _manifest: Dictionary
var _clock: Dictionary
var _paused: bool
var _accumulator: float
var _speed: float

func before_each() -> void:
	_clock = GameClock.serialize()
	_paused = GameClock.paused
	_accumulator = float(GameClock.get("_real_seconds_accumulator"))
	_speed = GameClock.time_speed
	GameClock.paused = true
	SaveService.delete_save(1)
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1152,648)
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)
	_main = preload("res://scenes/main/main.tscn").instantiate()
	_viewport.add_child(_main)
	_main.call("_start_new_game","Mai","Garden")
	_main.tutorial_panel.close_help()
	_main.ui_coordinator.close_active()
	GameClock.paused = true
	_main.machine_inventory.add_machine(&"stove",1)
	assert_true(_main.machine_build.place(&"stove",MACHINE_CELL,0).ok)
	assert_eq(_main.inventory.add_item(&"carrot",2),2)
	assert_true(_main.machine_operations.start(MACHINE_CELL,&"stove_carrot_meal",1).ok)
	_view = _main.machine_presentation as MachinePresentation
	_view.refresh()
	_manifest = JSON.parse_string(FileAccess.get_file_as_string(MachinePresentation.MANIFEST_PATH)) as Dictionary

func after_each() -> void:
	_viewport.free()
	GameClock.deserialize(_clock)
	GameClock.set("_real_seconds_accumulator",_accumulator)
	GameClock.time_speed = _speed
	GameClock.paused = _paused
	SaveService.delete_save(1)

func test_work_frames_pause_and_refresh_preserve_manifest_anchor_and_domain() -> void:
	assert_eq(_rows().size(),1)
	var sprite: Sprite2D = _machine_sprite()
	assert_not_null(sprite)
	if sprite == null:
		return
	assert_same(_rows()[0].state,_main.machine_operations.get_state(MACHINE_CELL))
	assert_eq(sprite.texture,_texture(1))
	_check_anchor(sprite)
	var before: Dictionary = _owners()
	# Manual cosmetic steps have no awaited frame while the real clock is running.
	GameClock.paused = false
	_view.call("_process",0.2)
	assert_eq(sprite.texture,_texture(1))
	_view.call("_process",0.21)
	assert_eq(sprite.texture,_texture(2))
	_view.call("_process",0.4)
	assert_eq(sprite.texture,_texture(1))
	GameClock.paused = true
	var timer: float = float(_view.get("_anim_timer"))
	_view.call("_process",3.0)
	await get_tree().process_frame
	assert_eq(sprite.texture,_texture(1))
	assert_eq(float(_view.get("_anim_timer")),timer)
	assert_eq(_owners(),before)
	GameClock.paused = false
	_view.call("_process",0.4)
	GameClock.paused = true
	assert_eq(sprite.texture,_texture(2))
	_view.refresh()
	assert_true(sprite.get_parent().is_queued_for_deletion(),"Refresh disposes the old machine root and its sprite")
	assert_eq(_rows().size(),1)
	assert_eq(float(_view.get("_anim_timer")),0.0)
	assert_false(bool(_view.get("_use_frame_b")))
	assert_eq(_machine_sprite().texture,_texture(1))
	_check_anchor(_machine_sprite())
	await get_tree().process_frame
	assert_eq((_view.get("_root") as Node2D).get_child_count(),1)
	assert_eq(_owners(),before)

func test_actual_ready_collection_and_removal_clear_animation_without_extra_progress() -> void:
	var sprite: Sprite2D = _machine_sprite()
	GameClock.paused = false
	_view.call("_process",0.41)
	GameClock.paused = true
	assert_eq(sprite.texture,_texture(2))
	_main.machine_operations.advance_day()
	var state: MachineState = _main.machine_operations.get_state(MACHINE_CELL)
	assert_eq(state.status,MachineState.STATUS_BLOCKED)
	assert_true(_main.machine_operations.can_collect_output(MACHINE_CELL).ok)
	var ready: Dictionary = _owners()
	_view.call("_process",1.0)
	assert_eq(sprite.texture,_texture(0),"A real ready buffer stops working visuals even while paused")
	assert_true(_rows().is_empty())
	assert_false(_view.is_processing())
	assert_eq(float(_view.get("_anim_timer")),0.0)
	_check_anchor(sprite)
	assert_eq(_owners(),ready,"Presentation neither advances jobs nor transfers their output")
	var collected: Dictionary = _main.machine_operations.collect_output_to_inventory(MACHINE_CELL)
	assert_true(collected.ok)
	assert_eq(state.status,MachineState.STATUS_IDLE)
	assert_eq(_main.inventory.get_quantity(collected.item_id),int(collected.quantity))
	var idle: Dictionary = _owners()
	_view.refresh()
	assert_true(_rows().is_empty())
	assert_false(_view.is_processing())
	assert_eq(_machine_sprite().texture,_texture(0))
	assert_eq(_owners(),idle)
	assert_true(_main.machine_build.remove(MACHINE_CELL).ok)
	var removed: Dictionary = _owners()
	_view.refresh()
	assert_true(_rows().is_empty())
	assert_false(_view.is_processing())
	await get_tree().process_frame
	assert_eq((_view.get("_root") as Node2D).get_child_count(),0)
	assert_eq(_owners(),removed)

func test_avatar_world_and_crop_phases_pause_without_changing_gameplay_or_customization() -> void:
	assert_true(_main.farm_state.till_cell(CROP_CELL))
	assert_true(_main.farm_state.plant_crop(CROP_CELL,&"spring_carrot"))
	var farm: FarmView = _main.farm_view as FarmView
	var crop: Sprite2D = farm.get_crop_view(CROP_CELL)
	var avatar: PlaceholderAvatar2D = _main.presentation.get_player_avatar()
	var world_nodes: Array[PlaceholderWorld2D] = []
	world_nodes.append(_main.world.objects.get_node("House/Placeholder") as PlaceholderWorld2D)
	for child: Node in _main.presentation.get_world_art_root().get_children():
		if child is PlaceholderWorld2D and child.kind == &"tree":
			world_nodes.append(child as PlaceholderWorld2D)
	assert_gt(world_nodes.size(),1,"Exercise the actual cottage and tree renderers")
	var appearance: Array = [avatar.get_hair_style(),avatar.skin,avatar.hair,avatar.outfit]
	var offset: Vector2 = crop.offset
	var phase: float = float(avatar.get("_phase"))
	var farm_phase: float = float(farm.get("_phase"))
	var world_phases: Array[float] = []
	for art: PlaceholderWorld2D in world_nodes:
		world_phases.append(float(art.get("_phase")))
	var before: Dictionary = _owners()
	GameClock.paused = false
	avatar.call("_process",0.25)
	farm.call("_process",0.25)
	for art: PlaceholderWorld2D in world_nodes:
		art.call("_process",0.25)
	GameClock.paused = true
	assert_almost_eq(float(avatar.get("_phase")),phase+0.25,0.00001)
	assert_almost_eq(float(farm.get("_phase")),farm_phase+0.25,0.00001)
	assert_ne(crop.skew,0.0)
	var skew: float = crop.skew
	avatar.call("_process",3.0)
	farm.call("_process",3.0)
	for index: int in range(world_nodes.size()):
		world_nodes[index].call("_process",3.0)
		assert_almost_eq(float(world_nodes[index].get("_phase")),world_phases[index]+0.25,0.00001)
	await get_tree().process_frame
	assert_almost_eq(float(avatar.get("_phase")),phase+0.25,0.00001)
	assert_almost_eq(float(farm.get("_phase")),farm_phase+0.25,0.00001)
	assert_eq(crop.skew,skew)
	assert_eq(crop.global_position,_main.world.cell_to_global(CROP_CELL))
	assert_eq(crop.offset,offset)
	assert_eq([avatar.get_hair_style(),avatar.skin,avatar.hair,avatar.outfit],appearance)
	# Existing action/emotion feedback still expires in real time while phases pause.
	avatar.play_tool(&"water")
	assert_true(avatar.show_emotion_bubble(&"heart",0.5))
	avatar.call("_process",1.0)
	assert_eq(avatar.action_id,&"Idle")
	assert_eq(avatar.get_emotion(),&"")
	assert_almost_eq(float(avatar.get("_phase")),phase+0.25,0.00001)
	assert_eq(_owners(),before)

func _rows() -> Array:
	return _view.get("_working_sprites")

func _machine_sprite() -> Sprite2D:
	var root: Node2D = _view.get("_root") as Node2D
	for child: Node in root.get_children():
		if not child.is_queued_for_deletion():
			return child.get_node("Sprite2D") as Sprite2D
	return null

func _texture(index: int) -> Texture2D:
	var files: Array = _manifest.machines.stove.files
	return load("res://assets/machines/stove/%s.png" % String(files[index])) as Texture2D

func _check_anchor(sprite: Sprite2D) -> void:
	var root: Node2D = sprite.get_parent() as Node2D
	var pivot: Array = _manifest.pivot_2x
	assert_eq(root.get_meta("cell"),MACHINE_CELL)
	assert_eq(root.global_position,_main.world.cell_to_global(MACHINE_CELL))
	assert_eq(sprite.position,-Vector2(float(pivot[0]),float(pivot[1])))
	assert_false(sprite.centered)

func _owners() -> Dictionary:
	return {
		"owned":_main.machine_inventory.serialize(),"placed":_main.machine_placements.serialize(),
		"jobs":_main.machine_operations.serialize(),"farm":_main.farm_state.serialize(),
		"bag":_main.inventory.serialize(),"wallet":_main.wallet.serialize(),
		"land":_main.land_ownership.serialize(),"quests":_main.quest_state.serialize(),
		"weather":_main.weather_state.serialize(),"social":_main.npc_system.state.serialize(),
		"ledger":_main.day_end_flow.ledger.serialize(),"day_end":_main.day_end_flow.state.serialize(),
		"profile":_main.profile.duplicate(true),"clock":GameClock.serialize(),
		"clock_accumulator":GameClock.get("_real_seconds_accumulator"),"save":SaveService.load_game(1)
	}
