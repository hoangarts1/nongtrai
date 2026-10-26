## NpcSystem — wires Phase 8 domain, placeholder actors and modal requests.
## API:
##   func configure(main: Node, dialogue: NpcPanel, journal: NpcPanel) -> void
##   func open_journal() -> void
##   func open_dialogue(npc_id: StringName) -> void
##   func close_panels() -> void
##   func restore(data: Dictionary) -> void
class_name NpcSystem
extends Node3D

const WORLD_ART_FACTORY: Script = preload("res://scripts/view/world_art_factory.gd")

var state: NpcSocialState = NpcSocialState.new()
var content: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
var dialogue: NpcPanel
var journal: NpcPanel
var actors: Dictionary = {}
var _main: Node
var _current_npc: StringName = &""
var _previous_pause: bool = false
var _hud_visibility: Dictionary = {}

func configure(main: Node, dialogue_panel: NpcPanel, journal_panel: NpcPanel) -> void:
	_main = main
	dialogue = dialogue_panel
	journal = journal_panel
	state.configure(content)
	state.changed.connect(_state_changed)
	dialogue.close_requested.connect(close_panels)
	journal.close_requested.connect(close_panels)
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		var actor: NpcActor = NpcActor.new()
		actor.name = String(npc.npc_id)
		add_child(actor)
		actor.configure(state, npc)
		actors[npc.npc_id] = actor
		_add_home(npc)
	GameClock.time_changed.connect(_time_changed)
	Events.weather_changed.connect(_weather_changed)
	_refresh_schedule()
	_main.debug_menu.register_action(tr("UI_DEBUG_NPC_VISIT"), debug_visit)
	_main.debug_menu.register_action(tr("UI_DEBUG_NPC_ITEMS"), debug_delivery_items)
	_main.debug_menu.register_action(tr("UI_DEBUG_NPC_JOURNAL"), debug_journal)

func _process(_delta: float) -> void:
	if _main == null:
		return
	var nearest: StringName = _nearest_npc() if _can_open() else &""
	for id: StringName in actors:
		var actor: NpcActor = actors[id]
		actor.name_label.text = tr(String(actor.data.display_name_key))
		if id == nearest:
			actor.name_label.text += "\n" + tr("UI_NPC_TALK_HINT")

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		return
	if not is_open():
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("cancel") or event.is_action_pressed("open_journal"):
		close_panels()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("use_tool") or event.is_action_pressed("interact") or event.is_action_pressed("open_inventory") or event.is_action_pressed("open_help") or event.is_action_pressed("toggle_debug_menu"):
		get_viewport().set_input_as_handled()
	else:
		for slot: int in range(1, 10):
			if event.is_action_pressed("hotbar_%d" % slot):
				get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not _can_open():
		return
	if event.is_action_pressed("open_journal"):
		open_journal()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		var nearest: StringName = _nearest_npc()
		if not nearest.is_empty():
			open_dialogue(nearest)
			get_viewport().set_input_as_handled()

func _can_open() -> bool:
	if _main == null or not bool(_main.get("_game_started")) or GameClock.is_sleeping() or is_open():
		return false
	return bool(_main.world.player.movement_enabled) and not _main.pause_menu.visible and not _main.start_menu.visible

func _nearest_npc() -> StringName:
	var nearest: StringName = &""
	var distance: float = content.interaction_reach
	for id: StringName in actors:
		var actor: NpcActor = actors[id]
		if not actor.visible or state.is_indoors(id):
			continue
		var current: float = _main.world.player.global_position.distance_to(actor.global_position)
		if current < distance:
			distance = current
			nearest = id
	return nearest

func is_open() -> bool:
	return dialogue != null and (dialogue.visible or journal.visible)

func _lock() -> void:
	if not is_open():
		_previous_pause = GameClock.paused
	GameClock.paused = true
	_main.world.player.movement_enabled = false
	_main.quest_panel.visible = false
	for control: Control in [_main.hud_button_bar, _main.hotbar_panel]:
		_hud_visibility[control] = control.visible
		control.hide()

func close_panels() -> void:
	if not is_open():
		return
	dialogue.hide()
	journal.hide()
	GameClock.paused = _previous_pause
	_main.world.player.movement_enabled = not GameClock.is_sleeping() and not _main.start_menu.visible and not _main.pause_menu.visible
	_main.quest_panel.visible = not _main.quest_state.is_complete()
	for control: Control in _hud_visibility:
		control.visible = bool(_hud_visibility[control])
	_hud_visibility.clear()
	_state_changed()

func open_journal() -> void:
	if not _can_open():
		return
	_lock()
	var body: String = tr("UI_NPC_JOURNAL_HINT") + "\n\n"
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		body += tr("UI_NPC_FRIENDSHIP") % [tr(String(npc.display_name_key)), int(state.friendship[npc.npc_id]), npc.friendship_max] + "\n"
	for quest: Resource in DataRegistry.get_all_quests():
		var id: StringName = quest.get("quest_id")
		var status: String = "UI_NPC_QUEST_NEW"
		if state.quests.is_quest_active(id):
			status = "UI_NPC_QUEST_ACTIVE"
		if state.quests.is_quest_completed(id):
			status = "UI_NPC_QUEST_DONE"
		body += "\n" + tr(String(quest.get("title_key"))) + ": " + tr(status) + "\n" + tr(String(quest.get("description_key")))
	journal.show_content(tr("UI_NPC_JOURNAL"), body)

func open_dialogue(npc_id: StringName) -> void:
	if not _can_open() or state.is_indoors(npc_id) or _nearest_npc() != npc_id:
		return
	_current_npc = npc_id
	state.talk(npc_id, GameClock.day_index, GameClock.season)
	_lock()
	_render_dialogue()

func _render_dialogue() -> void:
	var line: DialogueData = state.get_dialogue(_current_npc, GameClock.season)
	var npc: NpcData = state.get_npc(_current_npc)
	if line == null or npc == null:
		close_panels()
		return
	var body: String = tr(String(line.text_key)) + "\n" + tr("UI_NPC_FRIENDSHIP") % [tr(String(npc.display_name_key)), int(state.friendship[npc.npc_id]), npc.friendship_max]
	var actions: Array[Dictionary] = []
	var quest: QuestData = state.quests.get_quest(line.quest_id)
	if quest != null:
		if line.start_quest:
			actions.append({"id": "AcceptQuest", "text": tr("UI_NPC_ACCEPT_QUEST"), "callback": _accept_quest.bind(quest.quest_id)})
		if state.quests.is_quest_active(quest.quest_id):
			body += "\n" + tr("UI_QUEST_REQUIREMENT") % [_item_name(quest.required_item_id), quest.required_item_quantity, _main.inventory.get_quantity(quest.required_item_id)]
			body += "\n" + tr("UI_QUEST_REWARD") % [quest.reward_coins, _item_name(quest.reward_item_id), quest.reward_item_quantity]
			if not state.quests.can_deliver(quest.quest_id, _main.inventory):
				body += "\n" + tr("UI_NPC_DELIVERY_BLOCKED")
			actions.append({"id": "DeliverQuest", "text": tr("UI_CONFIRM_DELIVERY"), "enabled": state.quests.can_deliver(quest.quest_id, _main.inventory), "callback": _deliver.bind(quest.quest_id)})
	if npc.is_merchant:
		var offer: MerchantOfferData = state.merchant.get_offer(GameClock.day_index, GameClock.season)
		if offer != null:
			body += "\n\n" + tr("UI_NPC_OFFER_" + offer.kind.to_upper()) % [_item_name(offer.item_id), offer.quantity, offer.unit_price * offer.quantity]
			actions.append({"id": "ConfirmOffer", "text": tr("UI_NPC_CONFIRM_TRADE"), "enabled": not state.merchant.is_consumed(GameClock.day_index), "callback": _trade})
	dialogue.show_content(tr(String(npc.display_name_key)), body, actions)

func _item_name(id: StringName) -> String:
	var item: Resource = DataRegistry.get_item(id)
	return tr(String(item.get("display_name_key"))) if item != null else ""

func _accept_quest(id: StringName) -> void:
	state.quests.accept_quest(id)
	_render_dialogue()

func _deliver(id: StringName) -> void:
	var success: bool = state.quests.confirm_delivery(id, _main.inventory, _main.wallet)
	_main.feedback.show_message(tr("UI_FEEDBACK_QUEST_COMPLETED" if success else "UI_FEEDBACK_NOT_ENOUGH_ITEMS"))
	_render_dialogue()

func _trade() -> void:
	var available: bool = state.targets.get(&"minh") == &"minh_market" and not state.is_indoors(&"minh")
	var success: bool = state.merchant.confirm_trade(GameClock.day_index, GameClock.season, available, _main.inventory, _main.wallet)
	_main.feedback.show_message(tr("UI_NPC_TRADE_DONE" if success else "UI_NPC_TRADE_BLOCKED"))
	_state_changed()
	_render_dialogue()

func _time_changed(_day: int, _minute: int) -> void:
	_refresh_schedule()

func _weather_changed(_id: StringName) -> void:
	_refresh_schedule()

func _refresh_schedule() -> void:
	if _main != null:
		state.update_schedule(GameClock.day_index, GameClock.minute, GameClock.season, bool(_main.weather_state.call("is_rainy")))

func restore(data: Dictionary) -> void:
	close_panels()
	state.deserialize(data)
	_refresh_schedule()
	for actor: NpcActor in actors.values():
		actor.reset_position()

func _state_changed() -> void:
	if _main != null:
		_main.call("_mark_save_dirty")

func debug_visit() -> void:
	if not bool(_main.get("_game_started")) or GameClock.is_sleeping():
		return
	_main.weather_state.call("force_weather", &"sunny")
	var visit: NpcScheduleEntry = state.get_npc(&"minh").schedule[0] as NpcScheduleEntry
	GameClock.day_index = visit.weekdays[0] - 1
	GameClock.set_time(visit.start_minute / 60, posmod(visit.start_minute, 60))
	_refresh_schedule()
	while not state.paths.get(&"minh", []).is_empty():
		state.advance_step(&"minh")
	(actors[&"minh"] as NpcActor).reset_position()
	_main.world.player.global_position = GridMath.cell_to_world(state.cells[&"minh"] + Vector2i(0, -1))
	_state_changed()

func debug_delivery_items() -> void:
	_main.inventory.add_item(&"turnip", content.debug_delivery_quantity)

func debug_journal() -> void:
	_main.debug_menu.hide()
	_main.world.player.movement_enabled = true
	open_journal()

func _add_home(npc: NpcData) -> void:
	var home: MeshInstance3D = MeshInstance3D.new()
	home.name = "Home_%s" % npc.npc_id
	home.position = GridMath.cell_to_world(state.scheduler.location_cell(npc.home_location)) + Vector3(0, 0.7, 0)
	WORLD_ART_FACTORY.build_cottage(
		home,
		Vector3(1.7, 1.4, 1.5),
		npc.color.lightened(0.24),
		npc.color.darkened(0.20)
	)
	var label: Label3D = Label3D.new()
	label.text = tr("UI_NPC_HOME") % tr(String(npc.display_name_key))
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 1.85
	label.font_size = 64
	label.pixel_size = 0.008
	label.outline_size = 10
	label.font = preload("res://scenes/main/ui_theme.tres").default_font
	home.add_child(label)
	add_child(home)
