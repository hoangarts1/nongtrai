## Conservative DATA verification fixtures, never observed gameplay or extra days.
extends SceneTree
const CONFIG: ClearingConfig = preload("res://data/clearing_config.tres")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	if not OS.get_cmdline_user_args().is_empty(): quit(1); return
	var result: Dictionary = simulate()
	print(JSON.stringify(result))
	quit(0 if result.get("ok",false) else 1)

static func simulate() -> Dictionary:
	var owner: ClearingState = ClearingState.new()
	if not owner.configure(CONFIG): return {"ok":false}
	var scenery: Dictionary = SceneryPlacementRules.compile(CONFIG.scenery)
	var reserved: Dictionary = WaterSourceRules.reserved_cells(CONFIG.water)
	reserved.merge(CONFIG.coop.reserved_cells())
	var solids: Array[Rect2i] = CONFIG.land.npc_world.locations.get_solid_regions()
	solids.erase(CONFIG.land.initial_region)
	solids.append(CONFIG.coop.footprint) # Conservative even before coop purchase.
	var bounds: Rect2i = CONFIG.world.player_region
	var blocked: Dictionary[Vector2i, bool] = {}
	var anchors: Array[Vector2i] = [CONFIG.world.spawn_cell,CONFIG.world.house_cell,CONFIG.world.shipping_bin_cell,CONFIG.world.shop_cell]
	for y: int in range(bounds.position.y,bounds.end.y):
		for x: int in range(bounds.position.x,bounds.end.x):
			var cell: Vector2i = Vector2i(x,y)
			for solid: Rect2i in solids:
				if solid.has_point(cell): blocked[cell] = true
			var reserved_art: bool = reserved.has(cell) or CONFIG.land.initial_region.has_point(cell)
			for anchor: Vector2i in anchors:
				if cell.distance_squared_to(anchor)<=CONFIG.anchor_clearance_squared: reserved_art = true
			if not reserved_art:
				var entry: Dictionary = SceneryPlacementRules.select(scenery,cell,true)
				if not entry.is_empty() and entry.blocks: blocked[cell] = true
	var distance: Dictionary[Vector2i, int] = {CONFIG.world.spawn_cell:0}
	var frontier: Array[Vector2i] = [CONFIG.world.spawn_cell]
	var cursor: int = 0
	while cursor<frontier.size():
		var cell: Vector2i = frontier[cursor]
		cursor += 1
		for direction: Vector2i in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var next: Vector2i = cell+direction
			if bounds.has_point(next) and not blocked.has(next) and not distance.has(next):
				distance[next] = distance[cell]+1
				frontier.append(next)
	var tool: ToolData = load("res://data/tools/shovel.tres") as ToolData
	if tool==null: return {"ok":false}
	# ToolAction's farm dispatcher mentions Events via FarmGridState. Load it only
	# after SceneTree's autoload initialization, never in this CLI's initial parse.
	var tool_action: Script = load("res://scripts/domain/tool_action.gd") as Script
	if tool_action==null: return {"ok":false}
	var reachable: Array[Dictionary] = []
	for row: Dictionary in owner.get_candidates():
		var best: int = bounds.get_area()+1
		var approach: Vector2i = CONFIG.world.spawn_cell
		for cell: Vector2i in distance:
			if cell!=row.cell and bool(tool_action.call("is_in_reach",cell,row.cell,tool.reach_cells)) and distance[cell]<best:
				best = distance[cell]
				approach = cell
		if best<=bounds.get_area(): reachable.append({"cell":row.cell,"asset_id":row.asset_id,"walk_steps":best,"approach":approach})
	reachable.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.walk_steps<b.walk_steps or (a.walk_steps==b.walk_steps and (a.cell.y<b.cell.y or (a.cell.y==b.cell.y and a.cell.x<b.cell.x))))
	if reachable.size()<CONFIG.story_goal: return {"ok":false}
	for index: int in range(CONFIG.story_goal):
		var row: Dictionary = reachable[index]
		var token: RefCounted = owner.reserve(row.cell,row.asset_id).get("token")
		if token==null or not owner.commit(token) or not owner.finish(token): return {"ok":false}
	var restored: ClearingState = ClearingState.new()
	if not restored.configure(CONFIG) or not restored.deserialize(JSON.parse_string(JSON.stringify(owner.serialize()))) or restored.serialize()!=owner.serialize(): return {"ok":false}
	return {"ok":true,"kind":"verification_fixture_not_observed_gameplay","eligible_props":owner.get_candidates().size()+owner.get_count(),"reachable_centers":distance.size(),"reachable_props":reachable.size(),"goal":CONFIG.story_goal,"fixture_cleared":owner.get_count(),"json_match":true,"extra_days":0}
