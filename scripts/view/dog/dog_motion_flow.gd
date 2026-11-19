## DogMotionFlow - transient quoted visual steps, sole cell commits via domain service.
class_name DogMotionFlow
extends RefCounted
var _actor: DogActor2D
var _service: DogMovementService
var _refresh: Callable
var _quote: Dictionary = {}
var following: bool = false
func configure(actor: DogActor2D, service: DogMovementService, refresh: Callable) -> void:
	_actor = actor
	_service = service
	_refresh = refresh
	actor.arrived.connect(_arrived)
func cancel() -> void:
	_quote.clear()
	following = false
	_actor.reset_position()
func advance(delta: float, player: Vector2i, playing: bool) -> void:
	if not playing: return
	if not _actor.is_moving():
		var plan: Dictionary = _service.plan(player, following)
		if not plan.ok: return
		following = plan.following
		if plan.path.size() > 1: begin_step(plan.path[1])
	_actor.advance(delta, true)
func begin_step(target: Vector2i) -> bool:
	if _actor.is_moving(): return false
	var quote: Dictionary = _service.quote_step(target)
	if not quote.ok: return false
	_quote = quote
	if not _actor.begin_step(target):
		_quote.clear()
		return false
	return true
func _arrived(_cell: Vector2i) -> void:
	var quote: Dictionary = _quote.duplicate(true)
	_quote.clear()
	_refresh.call()
	_service.step(quote)
	_actor.reset_position()
