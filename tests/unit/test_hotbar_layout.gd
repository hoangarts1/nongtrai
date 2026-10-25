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
		await get_tree().process_frame
		var hotbar: Control = main.get_node("HotbarPanel")
		var slot_row: HBoxContainer = hotbar.get_node("MarginContainer/Content/HBoxContainer")
		for slot: Button in slot_row.get_children():
			var slot_rect: Rect2 = slot.get_global_rect()
			var labels: Array[Label] = []
			_collect_labels(slot, labels)
			for label: Label in labels:
				assert_true(slot_rect.encloses(label.get_global_rect()), "Label outside %s at %s: slot=%s label=%s" % [slot.name, viewport_size, slot_rect, label.get_global_rect()])
			for first_index: int in range(labels.size()):
				for second_index: int in range(first_index + 1, labels.size()):
					assert_false(labels[first_index].get_global_rect().intersects(labels[second_index].get_global_rect()), "Labels overlap in %s at %s" % [slot.name, viewport_size])
		main.queue_free()

func _collect_labels(node: Node, labels: Array[Label]) -> void:
	for child: Node in node.get_children():
		if child is Label:
			labels.append(child as Label)
		_collect_labels(child, labels)
