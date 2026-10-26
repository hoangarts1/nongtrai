extends GutTest

func _service() -> MerchantService:
	var service: MerchantService = MerchantService.new()
	service.offers = [preload("res://data/shops/minh_spring_discount.tres"), preload("res://data/shops/minh_turnip_request.tres")]
	return service

func test_daily_offer_is_seeded_and_prices_never_change() -> void:
	var service: MerchantService = _service()
	var ids: Array[StringName] = []
	for day: int in range(12):
		ids.append(service.get_offer(day, &"spring").offer_id)
	var restored: MerchantService = _service()
	restored.deserialize(service.serialize())
	for day: int in range(12):
		assert_eq(restored.get_offer(day, &"spring").offer_id, ids[day])
	assert_true(ids.has(&"minh_spring_discount"))
	assert_true(ids.has(&"minh_turnip_request"))
	var rng: RandomNumberGenerator = DetRandom.make_rng(0, 2, DetRandom.TAG_MERCHANT)
	assert_eq(rng.seed, 1466485800, "Golden seed calculated independently with integer modular arithmetic")

func test_discount_is_atomic_and_stock_stays_consumed_after_load() -> void:
	var service: MerchantService = _service()
	service.offers = [preload("res://data/shops/minh_spring_discount.tres")]
	var inventory: InventoryState = InventoryState.new(1)
	var wallet: WalletState = WalletState.new(100)
	var price_before: int = int(DataRegistry.get_item(&"spring_carrot_seed").get("buy_price"))
	assert_false(service.confirm_trade(2, &"spring", false, inventory, wallet))
	inventory.add_item(&"turnip", 1)
	assert_false(service.confirm_trade(2, &"spring", true, inventory, wallet))
	assert_eq(wallet.get_coins(), 100)
	inventory.clear()
	assert_true(service.confirm_trade(2, &"spring", true, inventory, wallet))
	assert_eq(wallet.get_coins(), 80)
	assert_eq(inventory.get_quantity(&"spring_carrot_seed"), 2)
	assert_eq(int(DataRegistry.get_item(&"spring_carrot_seed").get("buy_price")), price_before)
	var restored: MerchantService = _service()
	restored.deserialize(service.serialize())
	assert_false(restored.confirm_trade(2, &"spring", true, inventory, wallet))

func test_request_deducts_only_enough_items_on_confirmation() -> void:
	var service: MerchantService = _service()
	service.offers = [preload("res://data/shops/minh_turnip_request.tres")]
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(0)
	inventory.add_item(&"turnip", 2)
	assert_false(service.confirm_trade(2, &"spring", true, inventory, wallet))
	assert_eq(inventory.get_quantity(&"turnip"), 2)
	inventory.add_item(&"turnip", 1)
	assert_true(service.confirm_trade(2, &"spring", true, inventory, wallet))
	assert_eq(inventory.get_quantity(&"turnip"), 0)
	assert_eq(wallet.get_coins(), 96)
