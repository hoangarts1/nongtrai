## FarmEffects — bounded transient 2D feedback, triggered only after a successful action.
## API:
##   func play_action(cell: Vector2i, action_id: StringName) -> void
class_name FarmEffects
extends Node2D

const CATALOG: FarmingArtCatalog = preload("res://data/art/farming/chibi_farming_catalog.tres")
const MAX_ACTIVE_EFFECTS: int = 12
const EFFECT_SECONDS: float = 0.48
var grid: IsometricGrid

func play_action(cell: Vector2i, action_id: StringName) -> void:
	if grid == null or get_child_count() >= MAX_ACTIVE_EFFECTS:
		return
	var effect: Node2D = Node2D.new()
	effect.name = "FarmEffect_%s" % action_id
	add_child(effect)
	effect.global_position = grid.cell_to_global(cell)
	effect.set_meta("remaining", EFFECT_SECONDS)
	effect.set_meta("action_id", action_id)
	for index: int in range(4):
		var particle: Polygon2D = Polygon2D.new()
		particle.name = "Particle_%d" % index
		particle.polygon = IsometricGrid.diamond(Vector2(5,5))
		particle.color = _effect_color(action_id)
		var angle: float = TAU * float(index) / 4.0
		particle.set_meta("velocity", Vector2(cos(angle) * 24, -24 + sin(angle) * 16))
		effect.add_child(particle)

func _process(delta: float) -> void:
	for child: Node in get_children():
		var effect: Node2D = child as Node2D
		var remaining: float = float(effect.get_meta("remaining", 0.0)) - delta
		if remaining <= 0:
			effect.queue_free()
			continue
		effect.set_meta("remaining", remaining)
		for part: Node in effect.get_children():
			var particle: Polygon2D = part as Polygon2D
			var speed: Vector2 = particle.get_meta("velocity", Vector2.ZERO)
			particle.position += speed * delta
			particle.modulate.a = remaining / EFFECT_SECONDS

func _effect_color(action_id: StringName) -> Color:
	match action_id:
		&"seed": return CATALOG.seed_effect_color
		&"water", &"watering_can": return CATALOG.water_effect_color
		&"harvest": return CATALOG.harvest_effect_color
		_: return CATALOG.hoe_effect_color
