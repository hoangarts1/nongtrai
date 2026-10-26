extends GutTest

func test_all_crops_reference_valid_registered_items() -> void:
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	assert_gt(crops.size(), 0, "At least one crop should be registered")
	for crop: Resource in crops:
		var crop_id: StringName = crop.get("crop_id")
		var seed_id: StringName = crop.get("seed_item")
		var prod_id: StringName = crop.get("product_item")
		var seed_item: Resource = DataRegistry.get_item(seed_id)
		var prod_item: Resource = DataRegistry.get_item(prod_id)
		assert_not_null(seed_item, "Crop %s should reference valid seed item %s" % [crop_id, seed_id])
		assert_not_null(prod_item, "Crop %s should reference valid product item %s" % [crop_id, prod_id])
		assert_gt(int(seed_item.get("buy_price")), 0, "Seed %s buy_price must be positive" % seed_id)
		assert_gt(int(prod_item.get("sell_price")), 0, "Product %s sell_price must be positive" % prod_id)
		assert_gt(int(prod_item.get("sell_price")), int(seed_item.get("buy_price")), "Crop %s should be profitable" % crop_id)
		assert_ne(seed_item.get("color"), Color.BLACK, "Seed %s color should not be black" % seed_id)
		assert_ne(prod_item.get("color"), Color.BLACK, "Product %s color should not be black" % prod_id)
		assert_ne(crop.get("color"), Color.BLACK, "Crop %s color should not be black" % crop_id)

func test_crops_with_longer_growth_have_higher_or_equal_prices() -> void:
	var crops: Array[Resource] = DataRegistry.get_all_crops()
	for i: int in range(crops.size()):
		var crop_a: Resource = crops[i]
		var growth_a: int = int(crop_a.get("growth_days"))
		var seed_a: Resource = DataRegistry.get_item(crop_a.get("seed_item"))
		var prod_a: Resource = DataRegistry.get_item(crop_a.get("product_item"))
		for j: int in range(i + 1, crops.size()):
			var crop_b: Resource = crops[j]
			var growth_b: int = int(crop_b.get("growth_days"))
			var seed_b: Resource = DataRegistry.get_item(crop_b.get("seed_item"))
			var prod_b: Resource = DataRegistry.get_item(crop_b.get("product_item"))
			if growth_a > growth_b:
				assert_true(
					int(seed_a.get("buy_price")) >= int(seed_b.get("buy_price")),
					"Seed price for %s (growth %d) should >= %s (growth %d)" % [crop_a.get("crop_id"), growth_a, crop_b.get("crop_id"), growth_b]
				)
				assert_true(
					int(prod_a.get("sell_price")) >= int(prod_b.get("sell_price")),
					"Product price for %s (growth %d) should >= %s (growth %d)" % [crop_a.get("crop_id"), growth_a, crop_b.get("crop_id"), growth_b]
				)

func test_data_validator_detects_bad_crop_references() -> void:
	var bad_crop: CropData = CropData.new()
	bad_crop.crop_id = &"bad_crop"
	bad_crop.seed_item = &"nonexistent_seed"
	bad_crop.product_item = &"nonexistent_product"
	bad_crop.growth_days = 2
	var errors: PackedStringArray = DataValidator.validate_crop_references([bad_crop], DataRegistry.get_all_items())
	assert_gt(errors.size(), 0, "Validator should detect missing item references")
