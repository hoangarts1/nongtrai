## WorldSeasonFx -- bounded, deterministic C3 seasonal ambience with no gameplay state.
## API:
##   func configure(weather_state: Object, catalog: Resource) -> void
##   func get_active_effect_count() -> int
##   func get_current_mode() -> StringName
class_name WorldSeasonFx
extends Node3D

const DRIFT_POSITIONS: Array[Vector3] = [
	Vector3(-8.5, 2.5, -4.0), Vector3(-6.2, 3.0, 5.0), Vector3(-3.6, 2.2, 8.5),
	Vector3(7.0, 2.8, -5.8), Vector3(8.8, 2.4, 4.2), Vector3(5.7, 3.4, 8.0),
	Vector3(-9.3, 2.7, 2.3), Vector3(9.4, 3.1, -1.9), Vector3(-4.0, 2.5, -7.2),
	Vector3(2.8, 3.2, -8.6), Vector3(10.1, 2.6, 7.0), Vector3(-7.0, 3.3, 9.5)
]
const CRITTER_POSITIONS: Array[Vector3] = [
	Vector3(-7.2, 2.5, 2.6), Vector3(-5.5, 3.1, 4.7), Vector3(7.1, 2.7, -4.8),
	Vector3(8.6, 3.2, 2.0), Vector3(-3.8, 2.8, 8.0), Vector3(4.6, 2.5, -7.0)
]
const RIPPLE_POSITIONS: Array[Vector3] = [
	Vector3(-8.7, 0.09, 2.8), Vector3(-7.6, 0.09, 3.2), Vector3(-8.1, 0.09, 4.0),
	Vector3(-9.0, 0.09, 3.8), Vector3(-7.3, 0.09, 2.6), Vector3(-8.3, 0.09, 2.3)
]

var _catalog: Resource
var _weather_state: Object
var _effect_root: Node3D
var _animated_nodes: Array[Dictionary] = []
var _current_mode: StringName = &""
var _current_season: StringName = &"spring"
var _was_night: bool = false
var _elapsed: float = 0.0

func configure(weather_state: Object, catalog: Resource) -> void:
	_weather_state = weather_state
	_catalog = catalog
	_current_season = GameClock.season
	_was_night = _is_night()
	if _effect_root == null:
		_effect_root = Node3D.new()
		_effect_root.name = "SeasonalEffects"
		add_child(_effect_root)
	if not GameClock.season_changed.is_connected(_on_season_changed):
		GameClock.season_changed.connect(_on_season_changed)
	if not Events.weather_changed.is_connected(_on_weather_changed):
		Events.weather_changed.connect(_on_weather_changed)
	_rebuild()

func get_active_effect_count() -> int:
	if _effect_root == null:
		return 0
	var count: int = 0
	for group: Node in _effect_root.get_children():
		count += group.get_child_count()
	return count

func get_current_mode() -> StringName:
	return _current_mode

func _process(delta: float) -> void:
	if _effect_root == null:
		return
	var is_night_now: bool = _is_night()
	if is_night_now != _was_night:
		_was_night = is_night_now
		_rebuild()
	if GameClock.paused:
		return
	_elapsed += delta
	for motion: Dictionary in _animated_nodes:
		var node: Node3D = motion.get("node") as Node3D
		if node == null:
			continue
		var base: Vector3 = motion.get("base") as Vector3
		var phase: float = float(motion.get("phase", 0.0))
		var sway: float = sin(_elapsed * float(motion.get("speed", 1.0)) + phase)
		var rise: float = cos(_elapsed * 0.72 + phase) * float(motion.get("rise", 0.08))
		node.position = base + Vector3(sway * float(motion.get("sway", 0.10)), rise, cos(_elapsed * 0.61 + phase) * 0.06)
		node.rotation.y = _elapsed * float(motion.get("turn", 0.8)) + phase

func _on_season_changed(season: StringName) -> void:
	_current_season = season
	_rebuild()

func _on_weather_changed(_weather_id: StringName) -> void:
	_rebuild()

func _rebuild() -> void:
	if _effect_root == null:
		return
	for child: Node in _effect_root.get_children():
		child.free()
	_animated_nodes.clear()
	_elapsed = 0.0
	var cap: int = _ambient_cap()
	var used: int = 0
	var rainy: bool = _is_rainy()
	var night: bool = _is_night()
	match _current_season:
		&"spring":
			used = _add_drift(&"SpringPetals", _season_color(), 9, cap, used, 0.16, 0.30)
		&"summer":
			if night:
				used = _add_critters(&"env_firefly", 6, cap, used, 0.25, 1.6)
			else:
				used = _add_critters(&"env_butterfly", 4, cap, used, 0.33, 0.72)
				used = _add_critters(&"env_bird", 2, cap, used, 0.48, 0.42)
		&"autumn":
			used = _add_drift(&"AutumnLeaves", _season_color(), 10, cap, used, 0.20, 0.42)
		&"winter":
			used = _add_drift(&"WinterSnow", _season_color(), 12, cap, used, 0.10, 0.18)
	if rainy:
		used = _add_ripples(cap, used)
	_current_mode = _mode_name(rainy, night)

func _add_drift(group_name: StringName, color: Color, requested: int, cap: int, used: int, sway: float, fall_speed: float) -> int:
	var group: Node3D = Node3D.new()
	group.name = String(group_name)
	_effect_root.add_child(group)
	var count: int = mini(requested, cap - used)
	for index: int in range(count):
		var particle: MeshInstance3D = MeshInstance3D.new()
		particle.name = "Drift_%d" % index
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh.radial_segments = 6
		mesh.rings = 3
		particle.mesh = mesh
		particle.scale = Vector3(0.10 + float(index % 3) * 0.018, 0.045, 0.12)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		particle.material_override = material
		var base: Vector3 = DRIFT_POSITIONS[index % DRIFT_POSITIONS.size()] + Vector3(0.14 * float(index % 4), 0.10 * float(index / 4), 0.10 * float(index % 3))
		particle.position = base
		group.add_child(particle)
		_animated_nodes.append({"node": particle, "base": base, "phase": float(index) * 0.91, "sway": sway, "rise": fall_speed * 0.18, "speed": 0.85 + float(index % 3) * 0.15, "turn": 0.6})
	return used + count

func _add_critters(asset_id: StringName, requested: int, cap: int, used: int, sway: float, speed: float) -> int:
	var group: Node3D = Node3D.new()
	group.name = "%sAmbient" % String(asset_id).to_pascal_case()
	_effect_root.add_child(group)
	var count: int = mini(requested, cap - used)
	for index: int in range(count):
		var critter: Node3D = WorldArtFactory.create_asset(asset_id, _current_season)
		critter.name = "%s_%d" % [String(asset_id).to_pascal_case(), index]
		critter.scale = Vector3.ONE * (0.55 if asset_id == &"env_bird" else 0.40)
		var base: Vector3 = CRITTER_POSITIONS[(index + used) % CRITTER_POSITIONS.size()] + Vector3(0.28 * float(index), 0.12 * float(index % 2), 0.0)
		critter.position = base
		group.add_child(critter)
		_animated_nodes.append({"node": critter, "base": base, "phase": float(index + used) * 0.77, "sway": sway, "rise": 0.12, "speed": speed, "turn": 1.2})
	return used + count

func _add_ripples(cap: int, used: int) -> int:
	var group: Node3D = Node3D.new()
	group.name = "RainRipples"
	_effect_root.add_child(group)
	var count: int = mini(RIPPLE_POSITIONS.size(), cap - used)
	for index: int in range(count):
		var ripple: MeshInstance3D = MeshInstance3D.new()
		ripple.name = "Ripple_%d" % index
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.5
		mesh.height = 1.0
		mesh.radial_segments = 10
		mesh.rings = 3
		ripple.mesh = mesh
		ripple.position = RIPPLE_POSITIONS[index]
		ripple.scale = Vector3(0.28 + float(index % 3) * 0.09, 0.012, 0.20 + float(index % 2) * 0.06)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = _rain_ripple_color()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.52
		ripple.material_override = material
		group.add_child(ripple)
		_animated_nodes.append({"node": ripple, "base": ripple.position, "phase": float(index) * 1.11, "sway": 0.0, "rise": 0.0, "speed": 1.35, "turn": 0.0})
	return used + count

func _ambient_cap() -> int:
	if _catalog == null:
		return 28
	return clampi(int(_catalog.get("ambient_effect_cap")), 1, 64)

func _season_color() -> Color:
	if _catalog != null and _catalog.has_method(&"get_season_effect_color"):
		var value: Variant = _catalog.call(&"get_season_effect_color", _current_season)
		if value is Color:
			return value as Color
	return Color.WHITE

func _rain_ripple_color() -> Color:
	var color: Variant = _catalog.get("rain_ripple_color") if _catalog != null else Color("c6e6ef")
	return color as Color if color is Color else Color("c6e6ef")

func _is_rainy() -> bool:
	return _weather_state != null and _weather_state.has_method(&"is_rainy") and bool(_weather_state.call(&"is_rainy"))

func _is_night() -> bool:
	return GameClock.minute >= 1080 or GameClock.minute < GameClock.MORNING_MINUTE

func _mode_name(rainy: bool, night: bool) -> StringName:
	var base: String = String(_current_season)
	if rainy:
		base += "_rain"
	elif night:
		base += "_night"
	else:
		base += "_day"
	return StringName(base)
