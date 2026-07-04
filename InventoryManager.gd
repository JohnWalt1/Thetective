extends Node


var items:Array[ItemData]=[]
var equipment :Array[ItemData]=[]
signal inventory_updated

const QUALITY_ORDER={
	"Common":0,"Rare":1,"Epic":2,"Legendary":3
}
func add_item(item:ItemData)->void:
	if item.is_equipment:
		var existing_index=_find_equipment_slot(item.equipment_slot)
		if existing_index!=-1:
			equipment.remove_at(existing_index)
		equipment.append(item)
	else:
		items.append(item)
	sort_inventory()
	inventory_updated.emit()
	
func remove_item(item:ItemData)->void:
	if item.is_equipment:
		equipment.erase(item)
	else:
		items.erase(item)
	sort_inventory()
	inventory_updated.emit()

func _find_equipment_slot(slot: String) -> int:
	for i in range(equipment.size()):
		if equipment[i].equipment_slot == slot:
			return i
	return -1

func sort_inventory() -> void:
	# Sorting: Nama (A-Z, case-insensitive), lalu Quality (rendah ke tinggi)
	items.sort_custom(_sort_items)
	equipment.sort_custom(_sort_items)

func _sort_items(a: ItemData, b: ItemData) -> bool:
	# Bandingkan nama (abaikan huruf besar/kecil)
	if a.name.to_lower() == b.name.to_lower():
		return QUALITY_ORDER[a.quality] < QUALITY_ORDER[b.quality]
	return a.name.to_lower() < b.name.to_lower()
