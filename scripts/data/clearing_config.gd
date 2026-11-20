## ClearingConfig - DATA for removable supplied debris; no rewards or land grants.
class_name ClearingConfig
extends Resource
@export var world: IsometricWorldConfig
@export var scenery: SceneryArtCatalog
@export var water: WaterSourceConfig
@export var coop: ChickenCoopSiteConfig
@export var land: LandExpansionConfig
@export var story_goal: int = 0
@export var anchor_clearance_squared: int = 0

func validation_errors() -> PackedStringArray:
	if world==null or scenery==null or water==null or coop==null or land==null or land.npc_world==null or land.npc_world.locations==null:
		return PackedStringArray(["clearing requires shared world/scenery/source/site/land DATA"])
	if story_goal<=0 or story_goal>world.player_region.get_area() or anchor_clearance_squared<0 or anchor_clearance_squared>world.player_region.get_area():
		return PackedStringArray(["clearing goal/anchor clearance invalid"])
	if not world.player_region.has_area() or not world.scenery_region.encloses(world.player_region) or land.world!=world or water.world!=world or coop.world!=world:
		return PackedStringArray(["clearing geometry context mismatch"])
	var errors: PackedStringArray = scenery.validation_errors()
	errors.append_array(water.validation_errors())
	errors.append_array(coop.validation_errors())
	return errors
