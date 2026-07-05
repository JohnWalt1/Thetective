extends Button
class_name EquipmentSlotButton

@export var slot_name:String=""

func set_equipment(item: ItemData):
	if item:
		icon = item.icon
		text = ""  # atau nama pendek
		tooltip_text = item.name + "\n" + item.description
	else:
		icon = null
		text = slot_name
		tooltip_text = slot_name + " (empty)"
