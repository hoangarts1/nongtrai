## EcologySnapshot — detached actual owner metrics and current garden counts.
## API: static capture(main:Node)->Dictionary; valid(snapshot:Dictionary)->bool.
class_name EcologySnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	if not is_instance_valid(main):
		return {"ok": false, "reason": &"missing_owner"}
	var state: EcologyState = main.get("ecology_state") as EcologyState
	var runtime: LifeEcologyRuntime = main.get("ecology_runtime") as LifeEcologyRuntime
	if state == null or runtime == null or state.is_busy() or runtime.busy or state.get_day_index() != GameClock.day_index:
		return {"ok": false, "reason": &"unavailable_owner"}
	var farm: FarmGridState = main.get("farm_state") as FarmGridState
	var land: LandOwnershipState = main.get("land_ownership") as LandOwnershipState
	if farm == null or land == null:
		return {"ok": false, "reason": &"missing_garden"}
	var sample: Dictionary = EcologySampler.sample(LifeEcologyRuntime.SAMPLING, farm.serialize(), DataRegistry.get_all_crops(), land.get_owned_regions(), state.get_metrics())
	if not sample.ok:
		return {"ok": false, "reason": &"invalid_garden"}
	var result: Dictionary = {"ok": true, "state": state.serialize(), "sample": sample,
		"goals": {"mature_fruit_trees": LifeEcologyRuntime.SAMPLING.mature_tree_goal, "species": LifeEcologyRuntime.SAMPLING.species_goal}}
	return result if valid(result) else {"ok": false, "reason": &"invalid_readout"}

static func valid(snapshot: Dictionary) -> bool:
	if not snapshot.get("ok") is bool or not snapshot.ok:
		return false
	if not EcologySnapshotCodec.decode(LifeEcologyRuntime.PROFILE, snapshot.get("state")).ok:
		return false
	var sample: Variant = snapshot.get("sample")
	var goals: Variant = snapshot.get("goals")
	if not sample is Dictionary or not goals is Dictionary or not sample.get("ok") is bool or not sample.ok:
		return false
	if not EcologySnapshotCodec.decode_metrics(LifeEcologyRuntime.PROFILE, sample.get("targets")).ok:
		return false
	var counts: Variant = sample.get("counts")
	var available: Variant = sample.get("available")
	if not counts is Dictionary or counts.size() != 3 or not available is Dictionary or available.size() != 3 or goals.size() != 2:
		return false
	for field: String in ["mature_fruit_trees", "healthy_plants", "species"]:
		if not counts.get(field) is int or int(counts[field]) < 0:
			return false
	for field: String in ["mature_fruit_trees", "species"]:
		if not goals.get(field) is int or int(goals[field]) <= 0 or int(goals[field]) > EcologySampler.INT32_MAX:
			return false
	for field: String in ["tree_cover", "biodiversity", "water_clarity"]:
		if not available.get(field) is bool or bool(available[field]) != (field != "water_clarity"):
			return false
	return int(counts.healthy_plants) >= int(counts.species) and int(counts.healthy_plants) >= int(counts.mature_fruit_trees)
