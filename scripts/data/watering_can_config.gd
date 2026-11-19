## WateringCanConfig - data-owned capacity and first-upgrade terms.
class_name WateringCanConfig
extends Resource

# External JSON precision bound, not a gameplay capacity or balance value.
const MAX_JSON_INTEGER: int = 9007199254740991
@export var base_capacity: int = 0
@export var upgrade_capacity: int = 0
@export var upgrade_price: int = 0
@export var manual_charge_cost: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if base_capacity<=0 or base_capacity>MAX_JSON_INTEGER:
		errors.append("watering can base capacity must be a positive JSON-safe integer")
	if upgrade_capacity<=base_capacity or upgrade_capacity>MAX_JSON_INTEGER:
		errors.append("watering can upgrade must increase capacity within JSON precision")
	if upgrade_price<=0 or upgrade_price>MAX_JSON_INTEGER:
		errors.append("watering can upgrade price must be a positive JSON-safe integer")
	if manual_charge_cost<=0 or manual_charge_cost>base_capacity:
		errors.append("watering can manual charge must be positive and fit base capacity")
	return errors
