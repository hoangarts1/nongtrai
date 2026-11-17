## LifeMachineSnapshot — detached view data from existing machine/inventory owners.
class_name LifeMachineSnapshot
extends RefCounted

const SHOP: MachineShopData = preload("res://data/machine_shop.tres")

static func capture(main: Node, selected: StringName, recipe_id: StringName, operation: bool, cell: Vector2i) -> Dictionary:
	var placement: Dictionary = main.machine_placements.get_placement(cell) if operation else {}
	if operation and placement.is_empty():
		return {"valid":false}
	var id: StringName = StringName(placement.machine_id) if operation else selected
	if not SHOP.sells(id):
		id = StringName(SHOP.machine_ids[0])
	var machine: MachineData = DataRegistry.get_machine(id)
	var state: MachineState = main.machine_operations.get_state(cell) if operation else null
	var rows: Array[Dictionary] = []
	var recipes: Array[Dictionary] = []
	for resource: Resource in DataRegistry.get_recipes_for_machine(id):
		var recipe: RecipeData = resource as RecipeData
		var reason: StringName = &""
		if state!=null and state.status!=MachineState.STATUS_IDLE:
			reason = &"machine_busy"
		elif maxi(machine.unlock_house_level,recipe.unlock_house_level)>1:
			reason = &"house_level_locked"
		else:
			for input: Dictionary in recipe.input_entries():
				if not main.inventory.has_item(StringName(input.item_id),int(input.quantity)):
					reason = &"missing_input"
		var data: Dictionary = {"key":StringName("recipe:"+String(recipe.recipe_id)),"id":recipe.recipe_id,"kind":&"recipe","inputs":recipe.input_entries(),"outputs":recipe.output_entries(),"days":recipe.duration_days,"reason":reason}
		recipes.append(data)
	if recipes.is_empty():
		return {"valid":false}
	var chosen: Dictionary = recipes[0]
	for recipe: Dictionary in recipes:
		if recipe.id==recipe_id:
			chosen = recipe
	if operation:
		rows = recipes
	else:
		for shop_id: String in SHOP.machine_ids:
			var data: MachineData = DataRegistry.get_machine(StringName(shop_id))
			rows.append({"key":StringName("machine:"+shop_id),"id":data.machine_id,"kind":&"machine","name":data.display_name_key,"price":data.purchase_price,"level":data.unlock_house_level,"owned":main.machine_inventory.get_quantity(data.machine_id)})
		for placed: Dictionary in main.machine_placements.get_all_placements():
			var data: MachineData = DataRegistry.get_machine(StringName(placed.machine_id))
			rows.append({"key":StringName("placement:%s" % placed.cell),"id":data.machine_id,"kind":&"placement","name":data.display_name_key,"cell":placed.cell})
	var buy_reason: StringName = &"house_level_locked" if machine.unlock_house_level>1 else (&"insufficient_coins" if main.wallet.get_coins()<machine.purchase_price else &"")
	return {"valid":true,"id":id,"name":machine.display_name_key,"price":machine.purchase_price,"level":machine.unlock_house_level,"owned":main.machine_inventory.get_quantity(id),"coins":main.wallet.get_coins(),"rows":rows,"recipe":chosen,"cell":cell,"operation":operation,"state":state.status if state!=null else MachineState.STATUS_IDLE,"remaining":state.days_remaining if state!=null else 0,"output_id":state.output_item_id if state!=null else &"","output_quantity":state.output_quantity if state!=null else 0,"collect":main.machine_operations.can_collect_output(cell) if operation else {},"buy_reason":buy_reason,"return":main.machine_placement_request.can_return(cell,main.world.player.get_cell()) if operation else {},"move":main.machine_placement_request.can_begin_move(cell,main.world.player.get_cell()) if operation else {},"texture":LifeMachinePresenter.art(machine,state!=null and state.status==MachineState.STATUS_WORKING)}
