## DogMovementService — adjacent quoted commits and invalid-origin repair, no second cell.
class_name DogMovementService
extends RefCounted

var _config: DogConfig
var _state: DogState
var _navigation: DogNavigation
var _committing: bool = false

func configure(config: DogConfig, state: DogState, navigation: DogNavigation) -> bool:
	if is_busy() or config == null or not config.validation_errors().is_empty() or state == null or state.is_busy() or state.serialize().size() != 3 or navigation == null or navigation.get_revision() <= 0 or navigation.serialize().get("bounds") != DogNavigationCodec.rectangle(config.world.player_region): return false
	_config = config.frozen_copy()
	_state = state
	_navigation = navigation
	return true

func is_busy() -> bool:
	return _committing or (_state != null and _state.is_busy())

func plan(player: Vector2i, following: bool = false) -> Dictionary:
	if not _ready(): return {"ok": false, "reason": &"dog_busy_or_unconfigured"}
	return DogFollowRules.decide(_config, _navigation, _state.get_cell(), player, following)

func quote_step(target: Vector2i) -> Dictionary:
	if not _ready(): return {"ok": false, "reason": &"dog_busy_or_unconfigured"}
	var origin: Vector2i = _state.get_cell()
	if DogFollowRules.distance(origin, target) != 1 or not _navigation.is_walkable(origin) or not _navigation.is_walkable(target): return {"ok": false, "reason": &"blocked_dog_step"}
	return {"ok": true, "origin": origin, "target": target, "owner_revision": _state.get_revision(), "navigation_revision": _navigation.get_revision()}

func step(quote: Dictionary) -> Dictionary:
	if not _ready(): return {"ok": false, "reason": &"dog_busy_or_unconfigured"}
	if quote.size() != 5 or quote.get("ok") != true or not quote.get("ok") is bool or not quote.get("origin") is Vector2i or not quote.get("target") is Vector2i or not quote.get("owner_revision") is int or not quote.get("navigation_revision") is int: return {"ok": false, "reason": &"invalid_dog_step"}
	if quote.origin != _state.get_cell() or quote.owner_revision != _state.get_revision() or quote.navigation_revision != _navigation.get_revision(): return {"ok": false, "reason": &"stale_dog_step"}
	var checked: Dictionary = quote_step(quote.target)
	if not checked.ok: return checked
	_committing = true
	var moved: Dictionary = _state.try_set_cell(quote.target, int(quote.owner_revision))
	_committing = false
	return moved

func repair_invalid_origin() -> Dictionary:
	if not _ready(): return {"ok": false, "reason": &"dog_busy_or_unconfigured"}
	if _navigation.is_walkable(_state.get_cell()): return {"ok": true, "changed": false, "cell": _state.get_cell()}
	var resolved: Dictionary = DogFollowRules.nearest_walkable(_config, _navigation, _state.get_cell())
	if not resolved.ok: return resolved
	_committing = true
	var moved: Dictionary = _state.try_set_cell(resolved.cell, _state.get_revision())
	_committing = false
	if moved.ok: moved["cell"] = _state.get_cell()
	return moved

func _ready() -> bool:
	return not is_busy() and _config != null and _state != null and _navigation != null
