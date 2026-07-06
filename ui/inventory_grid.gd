extends GridContainer
class_name InventoryGrid

signal item_selected(item: ItemData)

const SLOT_SCENE := preload("res://ui/inventory_slot.tscn")


func populate(items: Array) -> void:
	for child in get_children():
		child.queue_free()

	for item in items:
		var slot: InventorySlot = SLOT_SCENE.instantiate()
		add_child(slot)
		slot.set_item(item)
		slot.slot_pressed.connect(_on_slot_pressed)


func _on_slot_pressed(item: ItemData) -> void:
	item_selected.emit(item)
