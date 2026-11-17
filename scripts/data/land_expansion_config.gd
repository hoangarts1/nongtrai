## LandExpansionConfig — ownership regions, trusted map context and integer pricing.
class_name LandExpansionConfig
extends Resource
@export var initial_region: Rect2i
@export var parcels: Array[ExpansionParcelData] = []
@export var base_cost: int = 0
@export var growth_numerator: int = 0
@export var growth_denominator: int = 0
@export var rounding_step: int = 0
@export var world: IsometricWorldConfig
@export var npc_world: NpcWorldData
