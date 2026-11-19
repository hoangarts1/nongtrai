## LifeDogRuntime - one cosmetic actor, bounded sparse context polling and lifecycle.
class_name LifeDogRuntime
extends Node
const CONFIG: DogConfig = preload("res://data/dog_config.tres")
const VISUAL: DogVisualProfile = preload("res://data/art/characters/dog_visual_profile.tres")
var actor: DogActor2D
var navigation: DogNavigation = DogNavigation.new()
var lifecycle: DogLifecycle = DogLifecycle.new()
var movement: DogMovementService = DogMovementService.new()
var reactions: DogReactionFlow = DogReactionFlow.new()
var _idle_elapsed: float = 0.0
var _idle_cursor: int = 0
var _idle_walking: bool = false
var motion: DogMotionFlow = DogMotionFlow.new()
var _main: Node
var _elapsed: float = 0.0
func configure(main: Node) -> bool:
	if _main != null: return _main == main
	_main = main
	if not navigation.configure(CONFIG, DogNavigationContext.capture(main)): return false
	var safe: Dictionary = DogFollowRules.nearest_walkable(CONFIG, navigation, main.world.player.get_cell())
	if not safe.ok or not main.dog_state.configure(CONFIG, safe.cell): return false
	if not lifecycle.configure(CONFIG, main.dog_state): return false
	if not movement.configure(CONFIG, main.dog_state, navigation): return false
	actor = DogActor2D.new()
	actor.name = "DogCompanion"
	main.world.objects.add_child(actor)
	if not actor.configure(main.dog_state, main.world.grid, CONFIG, VISUAL): return false
	motion.configure(actor, movement, refresh_context)
	reactions.configure(main,self)
	actor.hide()
	return true
func is_busy() -> bool:
	return movement.is_busy() or (_main != null and _main.dog_state.is_busy())
func can_play() -> bool:
	return _main != null and bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.paused and not GameClock.is_sleeping() and not GameClock.is_day_end_held() and not _main.day_end_flow.is_advancing() and _main.ui_coordinator.get_active_panel() == null and not bool(_main.call("_purchase_in_progress"))
func _process(delta: float) -> void:
	advance(delta)
func advance(delta: float) -> void:
	if actor == null or not is_finite(delta) or delta < 0.0: return
	var active: bool = bool(_main.get("_game_started")) and not _main.start_menu.visible
	actor.visible = active
	if not active: return
	if not can_play(): return
	_elapsed += delta
	if _elapsed >= CONFIG.context_interval:
		_elapsed = 0.0
		refresh_context()

	var player: Vector2i = _main.world.player.get_cell()
	if _idle_walking and DogFollowRules.distance(_main.dog_state.get_cell(),player)>=CONFIG.follow_start_distance:
		motion.cancel()
		_idle_walking = false
	if not actor.is_moving():
		_idle_walking = false
		var plan: Dictionary = movement.plan(player,motion.following)
		if plan.ok and not plan.following:
			_idle_elapsed += delta
			if _idle_elapsed>=CONFIG.idle_wait_seconds:
				_idle_elapsed = 0.0
				var idle: Dictionary = DogFollowRules.idle(CONFIG,navigation,_main.dog_state.get_cell(),player,_idle_cursor)
				_idle_cursor += 1
				if idle.ok: _idle_walking = motion.begin_step(idle.path[1])
		else: _idle_elapsed = 0.0
	motion.advance(delta, player, true)
	reactions.advance(delta,true)
func refresh_context() -> void:
	if is_busy(): return
	if not navigation.set_dynamic_obstacles(DogNavigationContext.capture(_main)): return
	if not navigation.is_walkable(_main.dog_state.get_cell()):
		var repaired: Dictionary = movement.repair_invalid_origin()
		if repaired.ok and repaired.get("changed", false): motion.cancel()
func reset() -> bool:
	if is_busy(): return false
	motion.cancel()
	navigation.set_dynamic_obstacles(DogNavigationContext.capture(_main))
	var safe: Dictionary = DogFollowRules.nearest_walkable(CONFIG, navigation, _main.world.player.get_cell())
	if not safe.ok or not _main.dog_state.configure(CONFIG, safe.cell): return false
	_elapsed = 0.0
	_idle_elapsed = 0.0
	_idle_cursor = 0
	_idle_walking = false
	reactions.reset()
	actor.configure(_main.dog_state, _main.world.grid, CONFIG, VISUAL)
	actor.visible = bool(_main.get("_game_started")) and not _main.start_menu.visible
	return true
func suspend() -> void:
	reactions.reset()
	_idle_elapsed = 0.0
	motion.cancel()
	actor.hide()
func _exit_tree() -> void:
	reactions.dispose()
	if is_instance_valid(actor): actor.free()

func restore(raw: Variant) -> bool:
	if is_busy(): return false
	motion.cancel()
	navigation.set_dynamic_obstacles(DogNavigationContext.capture(_main))
	var prepared: Dictionary = lifecycle.prepare(raw, _main.world.player.get_cell(), navigation)
	if not prepared.ok or not lifecycle.restore(prepared): return false
	_elapsed = 0.0
	_idle_elapsed = 0.0
	_idle_cursor = 0
	_idle_walking = false
	reactions.reset()
	actor.configure(_main.dog_state, _main.world.grid, CONFIG, VISUAL)
	actor.visible = bool(_main.get("_game_started")) and not _main.start_menu.visible
	return true
