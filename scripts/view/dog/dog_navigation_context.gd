## DogNavigationContext - sparse snapshots of existing world ownership/footprints.
class_name DogNavigationContext
extends RefCounted
static func capture(main: Node) -> Array[Rect2i]:
	var regions: Array[Rect2i] = main.land_ownership.get_owned_regions()
	for placement: Dictionary in main.machine_placements.get_all_placements():
		# Actual placement owner currently occupies MACHINE_SIZE (not art dimensions).
		regions.append(Rect2i(placement.cell, MachinePlacementState.MACHINE_SIZE))
	if main.chicken_coop.is_owned(): regions.append(main.chicken_coop_runtime.CONFIG.footprint)
	return regions
