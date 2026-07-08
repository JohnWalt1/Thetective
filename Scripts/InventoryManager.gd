extends Node

signal usable_inventory_changed
signal equipable_inventory_changed
signal equipment_slot_changed(slot_index:int,item:ItemData)

var usable_items:Array[ItemData]=[]
var equipable_items: Array[ItemData]=[]
var equipped_slots:Array=[null,null,null,null]

func add_item(item:ItemData)->void:
	if item.item_type==ItemData.ItemType.USABLE:
		usable_items.append(item)
		usable_inventory_changed.emit()
	else:
		equipable_items.append(item)
		equipable_inventory_changed.emit()
		
func remove_usable_item(item:ItemData)->void:
	usable_items.erase(item)
	usable_inventory_changed.emit()
	
func equip_item(slot_idx:int,item:ItemData)->void:
	if slot_idx<0 or slot_idx>3:
		return
	if equipped_slots[slot_idx]!=null:
		unequip_slot(slot_idx)
	equipable_items.erase(item)
	equipable_inventory_changed.emit()
	equipped_slots[slot_idx]=item
	equipment_slot_changed.emit(slot_idx,item)
	

func unequip_slot(slot_idx: int) -> void:
	if slot_idx < 0 or slot_idx > 3:
		return
	var item=equipped_slots[slot_idx]
	if item!=null:
		equipable_items.append(item)
		equipable_inventory_changed.emit()
		equipped_slots[slot_idx] = null
		equipment_slot_changed.emit(slot_idx, null)
