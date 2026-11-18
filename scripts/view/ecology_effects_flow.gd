## LifeEcologyEffectsFlow — bounded presentation attached to the existing world grid.
class_name LifeEcologyEffectsFlow
extends Node

const PROFILE: EcologyFeedbackProfile = preload("res://data/ecology_feedback_profile.tres")
var _main: Node
var _profile: EcologyFeedbackProfile
var _critters: Dictionary = {}
var _observed: Dictionary = {}
var _dirty: bool = true
var _elapsed: float = 0.0

func configure(main: Node, source: EcologyFeedbackProfile = PROFILE) -> bool:
	if _main != null:
		return _main == main
	if main == null or source == null or not source.validation_errors(LifeEcologyRuntime.PROFILE).is_empty():
		return false
	_main = main
	_profile = source.duplicate(true) as EcologyFeedbackProfile
	_profile.effects = source.effects.duplicate(true)
	_main.ecology_state.ecology_changed.connect(_changed)
	_main.farm_state.plot_changed.connect(_changed)
	GameClock.time_changed.connect(_clock_changed)
	Events.weather_changed.connect(_weather_changed)
	refresh()
	return true

func _changed(_value: Variant = null) -> void:
	_dirty = true

func _clock_changed(_day: int, _minute: int) -> void:
	_apply_lighting()

func _weather_changed(_id: StringName) -> void:
	_apply_lighting()

func _available() -> bool:
	return is_instance_valid(_main) and not _main.is_queued_for_deletion() and bool(_main.get("_game_started")) and not _main.start_menu.visible and not _main.ecology_runtime.busy and not _main.ecology_state.is_busy()

func _context() -> Dictionary:
	return {"day": GameClock.day_index, "state": _main.ecology_state.serialize(), "land": _main.land_ownership.serialize()}

func _process(delta: float) -> void:
	if _profile == null:
		return
	if not _available():
		clear()
		return
	_elapsed += maxf(0.0, delta)
	if _dirty or _elapsed >= _profile.refresh_seconds:
		_elapsed = 0.0
		if _dirty or _observed != _context():
			refresh()
	if GameClock.paused or GameClock.is_sleeping() or GameClock.is_day_end_held():
		return
	for critter: LifeEcologyCritter2D in _critters.values():
		critter.advance(delta)

func refresh() -> void:
	if not _available():
		clear()
		return
	var snapshot: Dictionary = EcologySnapshot.capture(_main)
	if not snapshot.get("ok", false):
		clear()
		return
	var selected: Dictionary = EcologyFeedbackSelector.select(_profile, LifeEcologyRuntime.PROFILE, snapshot.state.metrics, snapshot.sample.available)
	var cells: Array[Vector2i] = _owned_cells()
	if not selected.ok or cells.is_empty():
		clear()
		return
	var desired: Dictionary = {}
	for definition: Dictionary in selected.effects:
		for index: int in range(int(definition.count)):
			var key: String = "%s:%d" % [definition.id, index]
			var fraction: float = definition.anchors[index]
			var cell: Vector2i = cells[mini(cells.size() - 1, floori(fraction * float(cells.size())))]
			desired[key] = true
			var critter: LifeEcologyCritter2D = _critters.get(key) as LifeEcologyCritter2D
			if not is_instance_valid(critter):
				critter = LifeEcologyCritter2D.new()
				critter.name = "Ecology_%s_%d" % [definition.id, index]
				critter.configure(definition, fraction * TAU)
				_main.world.objects.add_child(critter)
				_critters[key] = critter
			critter.set_meta(&"cell", cell)
			critter.set_meta(&"effect_id", String(definition.id))
			critter.position = _main.world.objects.to_local(_main.world.grid.cell_to_global(cell))
	for key: String in _critters.keys():
		if not desired.has(key):
			_remove(key)
	_observed = _context()
	_dirty = false
	_apply_lighting()

func _owned_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var seen: Dictionary = {}
	for region: Rect2i in _main.land_ownership.get_owned_regions():
		var clipped: Rect2i = region.intersection(_main.world.CONFIG.map_region)
		for y: int in range(clipped.position.y, clipped.end.y):
			for x: int in range(clipped.position.x, clipped.end.x):
				var cell: Vector2i = Vector2i(x, y)
				if not seen.has(cell):
					seen[cell] = true
					cells.append(cell)
	return cells

func _apply_lighting() -> void:
	if not is_instance_valid(_main) or _profile == null:
		return
	var lighting: Dictionary = _main.world.get_day_night_lighting(GameClock.minute)
	var opacity: float = _profile.night_opacity if float(lighting.get("sun_energy", 0.0)) <= _profile.night_sun_energy else 1.0
	if bool(_main.weather_state.call("is_rainy")):
		opacity *= _profile.rain_opacity
	for critter: LifeEcologyCritter2D in _critters.values():
		critter.self_modulate.a = opacity

func _remove(key: String) -> void:
	var critter: LifeEcologyCritter2D = _critters[key] as LifeEcologyCritter2D
	if is_instance_valid(critter):
		critter.free()
	_critters.erase(key)

func clear() -> void:
	for key: String in _critters.keys():
		_remove(key)
	_observed.clear()
	_dirty = true
	_elapsed = 0.0

func _exit_tree() -> void:
	clear()

func get_presentation_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for key: String in _critters:
		var critter: LifeEcologyCritter2D = _critters[key] as LifeEcologyCritter2D
		rows.append({"key": key, "id": critter.get_meta(&"effect_id"), "cell": critter.get_meta(&"cell"), "instance_id": critter.get_instance_id(), "global_position": critter.global_position, "phase": critter.get_phase(), "opacity": critter.self_modulate.a})
	return rows
