extends GutTest

func test_wallet_initial_coins_and_add_remove() -> void:
	var wallet: WalletState = WalletState.new(100)
	assert_eq(wallet.get_coins(), 100)
	
	watch_signals(wallet)
	wallet.add_coins(50, &"sell")
	assert_eq(wallet.get_coins(), 150)
	assert_signal_emitted_with_parameters(wallet, "coins_changed", [150, 50, &"sell"])
	
	var spent: bool = wallet.remove_coins(40, &"buy")
	assert_true(spent)
	assert_eq(wallet.get_coins(), 110)
	assert_signal_emitted_with_parameters(wallet, "coins_changed", [110, -40, &"buy"])
	
	var overspend: bool = wallet.remove_coins(500, &"buy")
	assert_false(overspend, "Should not spend more than current coins")
	assert_eq(wallet.get_coins(), 110)

func test_wallet_can_afford_and_checks() -> void:
	var wallet: WalletState = WalletState.new(50)
	assert_true(wallet.has_coins(0))
	assert_true(wallet.has_coins(50))
	assert_false(wallet.has_coins(51))
	assert_true(wallet.can_afford(30))
	assert_false(wallet.can_afford(60))
	assert_false(wallet.can_afford(-10))

func test_wallet_serialize_and_deserialize() -> void:
	var wallet_a: WalletState = WalletState.new(250)
	var data: Dictionary = wallet_a.serialize()
	assert_eq(data.get("coins"), 250)
	
	var wallet_b: WalletState = WalletState.new(0)
	watch_signals(wallet_b)
	wallet_b.deserialize(data)
	assert_eq(wallet_b.get_coins(), 250)
	assert_signal_emitted(wallet_b, "coins_changed")

func test_wallet_hud_renders_and_updates_on_signal() -> void:
	var wallet: WalletState = WalletState.new(125)
	var hud: WalletHud = WalletHud.new()
	add_child_autofree(hud)
	hud.configure(wallet)
	assert_string_contains(hud.text, "125")
	
	wallet.add_coins(75, &"reward")
	assert_string_contains(hud.text, "200")
