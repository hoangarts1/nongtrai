extends GutTest

const VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1920, 1080)
]

func test_hotbar_labels_fit_inside_each_slot_without_overlap() -> void:
	for viewport_size: Vector2i in VIEWPORT_SIZES:
		get_tree().root.size = viewport_size
		get_viewport().size = viewport_size
		var main: Node = preload("res://scenes/main/main.tscn").instantiate()
		get_tree().root.add_child(main)
		main.set("_game_started", true)
		main.start_menu.hide()
		main.tutorial_panel.close_help()
		main.ui_coordinator.close_active()
		await get_tree().process_frame
		await get_tree().process_frame
		var hotbar: Control = main.get_node("HotbarPanel")
		var slot_row: HBoxContainer = hotbar.get_node("MarginContainer/Content/HBoxContainer")
		for slot: Button in slot_row.get_children():
			var slot_rect: Rect2 = slot.get_global_rect()
			var labels: Array[Label] = []
			_collect_labels(slot, labels)
			for label: Label in labels:
				assert_true(slot_rect.encloses(label.get_global_rect()), "Label outside %s at %s: slot=%s label=%s" % [slot.name, viewport_size, slot_rect, label.get_global_rect()])
				assert_true(label.get_line_count() <= 2, "Label wraps too many lines in %s at %s" % [slot.name, viewport_size])
			for first_index: int in range(labels.size()):
				for second_index: int in range(first_index + 1, labels.size()):
					assert_false(labels[first_index].get_global_rect().intersects(labels[second_index].get_global_rect()), "Labels overlap in %s at %s" % [slot.name, viewport_size])
		main.queue_free()

func test_tool_labels_fit_inside_buttons_without_character_wrapping() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var hotbar: Control = main.get_node("HotbarPanel")
	var tool_row: HBoxContainer = hotbar.get_node("MarginContainer/Content/ToolRow")
	for button: Button in tool_row.get_children():
		var label: Label = button.get_node("ToolLabel")
		assert_true(button.get_global_rect().encloses(label.get_global_rect()))
		assert_true(label.get_line_count() <= 2)
		assert_true(label.get_line_count() == 1, "Tool label is split into multiple lines: %s" % label.text)
	main.queue_free()

func _collect_labels(node: Node, labels: Array[Label]) -> void:
	for child: Node in node.get_children():
		if child is Label and (child as Label).visible:
			labels.append(child as Label)
		_collect_labels(child, labels)
