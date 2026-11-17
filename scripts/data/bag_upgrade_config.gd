## BagUpgradeConfig - data-owned first-tier bag terms.
class_name BagUpgradeConfig
extends Resource

# Shared external-save integrity bound; not a purchasable capacity or balance value.
const MAX_CAPACITY: int = 4096

@export var base: InventoryConfig
@export var additional_slots: int = 0
@export var purchase_price: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if base==null:
		errors.append("bag upgrade requires base inventory config")
		return errors
	var dimensions: InventoryConfig = base
	var bound: int = MAX_CAPACITY
	if dimensions.default_capacity<=0 or dimensions.default_capacity>bound or dimensions.columns<=0 or dimensions.columns>bound or dimensions.visible_rows<=0 or dimensions.visible_rows>bound:
		errors.append("bag upgrade base dimensions are invalid")
	elif dimensions.default_capacity!=dimensions.columns*dimensions.visible_rows:
		errors.append("bag upgrade base grid must match capacity")
	if not errors.is_empty():
		return errors
	if additional_slots<=0 or additional_slots>bound-dimensions.default_capacity or purchase_price<=0:
		errors.append("bag upgrade increment/price/target are invalid")
	return errors

