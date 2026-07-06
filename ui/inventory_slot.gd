extends Button
class_name InventorySlot

signal slot_pressed(item: ItemData)

var item_data: ItemData = null

@onready var icon_rect: TextureRect = $Icon


func set_item(item: ItemData) -> void:
	item_data = item
	if item_data:
		icon_rect.texture = item_data.icon
		tooltip_text = item_data.item_name
	else:
		icon_rect.texture = null
		tooltip_text = ""


func _pressed() -> void:
	slot_pressed.emit(item_data)
